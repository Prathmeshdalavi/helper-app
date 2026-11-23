package com.helper_backend.modules.auth.service;

import java.security.SecureRandom;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.common.util.Hashes;
import com.helper_backend.config.AppProperties;
import com.helper_backend.modules.auth.domain.RefreshToken;
import com.helper_backend.modules.auth.repository.RefreshTokenRepository;
import com.helper_backend.modules.user.domain.User;
import com.helper_backend.modules.user.service.UserService;

/**
 * Access tokens: short-lived signed JWTs. Refresh tokens: random opaque strings, stored
 * hashed, replaced on every use. Presenting an already-used refresh token means it was
 * probably stolen, so the whole login (token family) is revoked.
 */
@Service
public class TokenService {

	public record TokenPair(String accessToken, String refreshToken, long expiresInSeconds) {
	}

	private final JwtEncoder jwtEncoder;
	private final RefreshTokenRepository refreshTokens;
	private final UserService users;
	private final AppProperties props;
	private final Clock clock;
	private final SecureRandom random = new SecureRandom();

	public TokenService(JwtEncoder jwtEncoder, RefreshTokenRepository refreshTokens, UserService users,
			AppProperties props, Clock clock) {
		this.jwtEncoder = jwtEncoder;
		this.refreshTokens = refreshTokens;
		this.users = users;
		this.props = props;
		this.clock = clock;
	}

	/** New login: starts a new token family. */
	@Transactional
	public TokenPair issue(User user) {
		return issueInFamily(user, UUID.randomUUID()).pair();
	}

	@Transactional(noRollbackFor = ApiException.class)
	public TokenPair rotate(String presentedRefreshToken) {
		Instant now = clock.instant();
		RefreshToken current = refreshTokens
				.findByTokenHashForUpdate(Hashes.sha256Hex(presentedRefreshToken))
				.orElseThrow(TokenService::invalid);

		if (current.isRevoked()) {
			// Reuse of a retired token: kill the whole family.
			refreshTokens.revokeFamily(current.getFamilyId(), now);
			throw invalid();
		}
		if (!now.isBefore(current.getExpiresAt())) {
			throw invalid();
		}

		User user = users.getById(current.getUserId());
		if (!user.isActive()) {
			refreshTokens.revokeFamily(current.getFamilyId(), now);
			throw invalid();
		}

		Issued next = issueInFamily(user, current.getFamilyId());
		current.revoke(now, next.token().getId());
		return next.pair();
	}

	/** Idempotent. Only the owner can revoke their own login; anything else is ignored. */
	@Transactional
	public void revoke(String presentedRefreshToken, UUID requestingUserId) {
		refreshTokens.findByTokenHash(Hashes.sha256Hex(presentedRefreshToken))
				.filter(t -> t.getUserId().equals(requestingUserId))
				.ifPresent(t -> refreshTokens.revokeFamily(t.getFamilyId(), clock.instant()));
	}

	private record Issued(RefreshToken token, TokenPair pair) {
	}

	private Issued issueInFamily(User user, UUID familyId) {
		Instant now = clock.instant();

		JwtClaimsSet claims = JwtClaimsSet.builder()
				.issuer(props.jwt().issuer())
				.subject(user.getId().toString())
				.issuedAt(now)
				.expiresAt(now.plus(props.jwt().accessTtl()))
				.id(UUID.randomUUID().toString())
				.claim("roles", List.of(user.getRole().name()))
				.build();
		String access = jwtEncoder.encode(
				JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims)).getTokenValue();

		byte[] raw = new byte[32];
		random.nextBytes(raw);
		String refresh = Base64.getUrlEncoder().withoutPadding().encodeToString(raw);
		RefreshToken saved = refreshTokens.save(new RefreshToken(user.getId(), familyId,
				Hashes.sha256Hex(refresh), now.plus(props.jwt().refreshTtl())));

		return new Issued(saved, new TokenPair(access, refresh, props.jwt().accessTtl().toSeconds()));
	}

	private static ApiException invalid() {
		return new ApiException(ErrorCode.UNAUTHORIZED, "Session expired. Please sign in again.");
	}
}
