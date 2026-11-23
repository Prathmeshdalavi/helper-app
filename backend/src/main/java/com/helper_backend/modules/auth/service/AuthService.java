package com.helper_backend.modules.auth.service;

import java.time.Clock;
import java.time.Duration;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.regex.Pattern;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.common.util.PhoneNumbers;
import com.helper_backend.modules.auth.domain.OtpChallenge;
import com.helper_backend.modules.auth.dto.AuthResponse;
import com.helper_backend.modules.auth.dto.CheckPhoneResponse;
import com.helper_backend.modules.auth.dto.SendOtpResponse;
import com.helper_backend.modules.auth.dto.VerifyOtpRequest;
import com.helper_backend.modules.auth.service.TokenService.TokenPair;
import com.helper_backend.modules.user.domain.User;
import com.helper_backend.modules.user.service.UserService;

/** Orchestrates the phone + OTP sign-in / sign-up flow used by the customer app. */
@Service
public class AuthService {

	// Same rules as the customer app's sign-up screen.
	private static final Pattern EMAIL = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");
	private static final Duration HOUR = Duration.ofHours(1);
	private static final Duration TEN_MIN = Duration.ofMinutes(10);

	private final UserService users;
	private final OtpService otp;
	private final TokenService tokens;
	private final RateLimiter limiter;
	private final Clock clock;

	public AuthService(UserService users, OtpService otp, TokenService tokens, RateLimiter limiter, Clock clock) {
		this.users = users;
		this.otp = otp;
		this.tokens = tokens;
		this.limiter = limiter;
		this.clock = clock;
	}

	public CheckPhoneResponse checkPhone(String phone, String clientIp) {
		limiter.hit("chk-ip", clientIp, 30, TEN_MIN);
		limiter.hit("chk-phone", phone, 10, TEN_MIN);
		return new CheckPhoneResponse(users.findByPhone(PhoneNumbers.toE164(phone)).isPresent());
	}

	public SendOtpResponse sendOtp(String phone, String clientIp) {
		limiter.hit("otp-ip", clientIp, 20, HOUR);
		limiter.hit("otp-phone", phone, 5, HOUR);
		return otp.issue(PhoneNumbers.toE164(phone));
	}

	/**
	 * One transaction: check the code, create the account when the phone is new, consume
	 * the OTP, issue tokens. Failed attempts still commit (noRollbackFor).
	 */
	@Transactional(noRollbackFor = ApiException.class)
	public AuthResponse verifyOtp(VerifyOtpRequest req, String clientIp) {
		limiter.hit("ver-ip", clientIp, 60, HOUR);
		limiter.hit("ver-phone", req.phone(), 15, HOUR);

		String phone = PhoneNumbers.toE164(req.phone());
		OtpChallenge challenge = otp.verifyCode(phone, req.otp());

		Optional<User> existing = users.findByPhone(phone);
		User user;
		boolean isNew;
		if (existing.isPresent()) {
			user = existing.get();
			if (!user.isActive()) {
				throw new ApiException(ErrorCode.FORBIDDEN, "This account is unavailable");
			}
			isNew = false;
		} else {
			String name = cleanName(req.name());
			String email = cleanEmail(req.email());
			user = users.createCustomer(phone, name, email, clock.instant());
			isNew = true;
		}

		otp.consume(challenge);
		TokenPair pair = tokens.issue(user);
		return new AuthResponse(pair.accessToken(), pair.refreshToken(), "Bearer", pair.expiresInSeconds(),
				isNew, users.toResponse(user));
	}

	public AuthResponse refresh(String refreshToken, String clientIp) {
		limiter.hit("ref-ip", clientIp, 120, HOUR);
		TokenPair pair = tokens.rotate(refreshToken);
		return new AuthResponse(pair.accessToken(), pair.refreshToken(), "Bearer", pair.expiresInSeconds(),
				false, null);
	}

	public void logout(String refreshToken, UUID userId) {
		tokens.revoke(refreshToken, userId);
	}

	private static String cleanName(String raw) {
		String name = raw == null ? "" : raw.trim().replaceAll("\\s+", " ");
		if (name.length() < 2 || name.length() > 60 || name.matches(".*[0-9].*")) {
			throw new ApiException(ErrorCode.VALIDATION_FAILED, "Validation failed",
					Map.of("name", "Enter your full name (at least 2 letters, no digits)"));
		}
		return name;
	}

	private static String cleanEmail(String raw) {
		if (raw == null || raw.isBlank()) {
			return null;
		}
		String email = raw.trim();
		if (email.length() > 254 || !EMAIL.matcher(email).matches()) {
			throw new ApiException(ErrorCode.VALIDATION_FAILED, "Validation failed",
					Map.of("email", "Enter a valid email address"));
		}
		return email;
	}
}
