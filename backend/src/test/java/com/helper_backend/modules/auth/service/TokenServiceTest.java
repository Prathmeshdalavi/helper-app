package com.helper_backend.modules.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.nio.charset.StandardCharsets;
import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import javax.crypto.spec.SecretKeySpec;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import com.helper_backend.TestData;
import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.common.util.Hashes;
import com.helper_backend.modules.auth.domain.RefreshToken;
import com.helper_backend.modules.auth.repository.RefreshTokenRepository;
import com.helper_backend.modules.auth.service.TokenService.TokenPair;
import com.helper_backend.modules.user.domain.User;
import com.helper_backend.modules.user.domain.UserStatus;
import com.helper_backend.modules.user.service.UserService;
import com.nimbusds.jose.jwk.source.ImmutableSecret;

class TokenServiceTest {

	private final SecretKeySpec key = new SecretKeySpec(
			TestData.JWT_SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
	private final RefreshTokenRepository repo = mock(RefreshTokenRepository.class);
	private final UserService users = mock(UserService.class);
	private final UUID userId = UUID.randomUUID();
	private TokenService service;
	private User user;

	@BeforeEach
	void setUp() {
		service = new TokenService(new NimbusJwtEncoder(new ImmutableSecret<>(key)), repo, users,
				TestData.props(), Clock.systemUTC());
		user = User.newCustomer("+919876543210", "Priya Sharma", null, Instant.now());
		ReflectionTestUtils.setField(user, "id", userId);
		when(users.getById(userId)).thenReturn(user);
		when(repo.save(any())).thenAnswer(inv -> {
			RefreshToken t = inv.getArgument(0);
			ReflectionTestUtils.setField(t, "id", UUID.randomUUID());
			return t;
		});
	}

	private RefreshToken storedFor(String raw, Instant expiresAt) {
		return new RefreshToken(userId, UUID.randomUUID(), Hashes.sha256Hex(raw), expiresAt);
	}

	@Test
	void issueGivesAVerifiableAccessTokenAndAHashedRefreshToken() {
		TokenPair pair = service.issue(user);

		Jwt jwt = NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build()
				.decode(pair.accessToken());
		assertThat(jwt.getSubject()).isEqualTo(userId.toString());
		assertThat(jwt.getClaimAsString("iss")).isEqualTo("helper-test");
		assertThat(jwt.getClaimAsStringList("roles")).containsExactly("CUSTOMER");
		assertThat(jwt.getExpiresAt().getEpochSecond() - jwt.getIssuedAt().getEpochSecond()).isEqualTo(900);
		assertThat(pair.expiresInSeconds()).isEqualTo(900);

		ArgumentCaptor<RefreshToken> saved = ArgumentCaptor.forClass(RefreshToken.class);
		verify(repo).save(saved.capture());
		assertThat(ReflectionTestUtils.getField(saved.getValue(), "tokenHash"))
				.isEqualTo(Hashes.sha256Hex(pair.refreshToken()))
				.isNotEqualTo(pair.refreshToken());
		assertThat(pair.refreshToken()).hasSizeGreaterThanOrEqualTo(40);
	}

	@Test
	void accessTokensAreUnique() {
		assertThat(service.issue(user).accessToken()).isNotEqualTo(service.issue(user).accessToken());
	}

	@Test
	void rotateRetiresTheOldTokenAndKeepsTheFamily() {
		RefreshToken old = storedFor("old-token", Instant.now().plusSeconds(3600));
		when(repo.findByTokenHashForUpdate(Hashes.sha256Hex("old-token"))).thenReturn(Optional.of(old));

		TokenPair next = service.rotate("old-token");

		assertThat(next.refreshToken()).isNotEqualTo("old-token");
		assertThat(old.isRevoked()).isTrue();
		ArgumentCaptor<RefreshToken> saved = ArgumentCaptor.forClass(RefreshToken.class);
		verify(repo).save(saved.capture());
		assertThat(saved.getValue().getFamilyId()).isEqualTo(old.getFamilyId());
		verify(repo, never()).revokeFamily(any(), any());
	}

	@Test
	void reusingARetiredTokenRevokesTheWholeFamily() {
		RefreshToken old = storedFor("old-token", Instant.now().plusSeconds(3600));
		old.revoke(Instant.now(), UUID.randomUUID());
		when(repo.findByTokenHashForUpdate(Hashes.sha256Hex("old-token"))).thenReturn(Optional.of(old));

		assertThatThrownBy(() -> service.rotate("old-token"))
				.isInstanceOf(ApiException.class).extracting("code").isEqualTo(ErrorCode.UNAUTHORIZED);
		verify(repo).revokeFamily(eq(old.getFamilyId()), any());
		verify(repo, never()).save(any());
	}

	@Test
	void unknownAndExpiredTokensAreRejected() {
		when(repo.findByTokenHashForUpdate(any())).thenReturn(Optional.empty());
		assertThatThrownBy(() -> service.rotate("nope")).extracting("code").isEqualTo(ErrorCode.UNAUTHORIZED);

		RefreshToken expired = storedFor("exp", Instant.now().minusSeconds(1));
		when(repo.findByTokenHashForUpdate(Hashes.sha256Hex("exp"))).thenReturn(Optional.of(expired));
		assertThatThrownBy(() -> service.rotate("exp")).extracting("code").isEqualTo(ErrorCode.UNAUTHORIZED);
		verify(repo, never()).save(any());
	}

	@Test
	void blockedUsersCannotRefresh() {
		ReflectionTestUtils.setField(user, "status", UserStatus.BLOCKED);
		RefreshToken tok = storedFor("tok", Instant.now().plusSeconds(3600));
		when(repo.findByTokenHashForUpdate(Hashes.sha256Hex("tok"))).thenReturn(Optional.of(tok));

		assertThatThrownBy(() -> service.rotate("tok")).extracting("code").isEqualTo(ErrorCode.UNAUTHORIZED);
		verify(repo).revokeFamily(eq(tok.getFamilyId()), any());
	}

	@Test
	void logoutRevokesOnlyTheCallersOwnFamily() {
		RefreshToken mine = storedFor("mine", Instant.now().plusSeconds(3600));
		when(repo.findByTokenHash(Hashes.sha256Hex("mine"))).thenReturn(Optional.of(mine));

		service.revoke("mine", UUID.randomUUID()); // someone else
		verify(repo, never()).revokeFamily(any(), any());

		service.revoke("mine", userId); // the owner
		verify(repo).revokeFamily(eq(mine.getFamilyId()), any());

		when(repo.findByTokenHash(any())).thenReturn(Optional.empty());
		service.revoke("unknown", userId); // idempotent, no error
	}

	@Test
	void rolesClaimIsAList() {
		TokenPair pair = service.issue(user);
		Jwt jwt = NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build()
				.decode(pair.accessToken());
		assertThat(jwt.<List<String>>getClaim("roles")).isInstanceOf(List.class);
	}
}
