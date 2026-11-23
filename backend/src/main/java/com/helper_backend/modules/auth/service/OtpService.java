package com.helper_backend.modules.auth.service;

import java.security.SecureRandom;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.config.AppProperties;
import com.helper_backend.modules.auth.domain.OtpChallenge;
import com.helper_backend.modules.auth.dto.SendOtpResponse;
import com.helper_backend.modules.auth.repository.OtpChallengeRepository;

/** Issues and checks one-time passcodes. Never logs or returns the code. */
@Service
public class OtpService {

	private final OtpChallengeRepository challenges;
	private final OtpHasher hasher;
	private final SmsSender sms;
	private final AppProperties props;
	private final Clock clock;
	private final SecureRandom random = new SecureRandom();

	public OtpService(OtpChallengeRepository challenges, OtpHasher hasher, SmsSender sms,
			AppProperties props, Clock clock) {
		this.challenges = challenges;
		this.hasher = hasher;
		this.sms = sms;
		this.props = props;
		this.clock = clock;
	}

	/**
	 * Creates a fresh challenge (invalidating any older one) and sends it. If delivery
	 * fails the whole transaction rolls back, so no unusable challenge is left behind.
	 */
	@Transactional
	public SendOtpResponse issue(String phoneE164) {
		Instant now = clock.instant();
		Duration cooldown = props.otp().resendCooldown();

		challenges.findFirstByPhoneE164OrderByCreatedAtDesc(phoneE164).ifPresent(last -> {
			Duration since = Duration.between(last.getCreatedAt(), now);
			if (since.compareTo(cooldown) < 0) {
				long wait = Math.max(1, cooldown.minus(since).toSeconds() + 1);
				throw new ApiException(ErrorCode.RATE_LIMITED, "Please wait before requesting another OTP.",
						Map.of("retryAfterSeconds", String.valueOf(wait)));
			}
		});

		challenges.invalidateActive(phoneE164, now);
		String code = String.format("%04d", random.nextInt(10_000));
		challenges.save(new OtpChallenge(phoneE164, hasher.hash(phoneE164, code),
				now.plus(props.otp().ttl()), props.otp().maxAttempts()));
		sms.sendOtp(phoneE164, code);

		return new SendOtpResponse((int) cooldown.toSeconds(), (int) props.otp().ttl().toSeconds());
	}

	/**
	 * Checks a submitted code against the live challenge, under a row lock. Returns the
	 * challenge when the code is right; the caller consumes it once the sign-in succeeds.
	 * Failed attempts are committed (noRollbackFor) so they always count.
	 */
	@Transactional(noRollbackFor = ApiException.class)
	public OtpChallenge verifyCode(String phoneE164, String code) {
		Instant now = clock.instant();
		OtpChallenge challenge = challenges.findActiveForUpdate(phoneE164)
				.orElseThrow(() -> new ApiException(ErrorCode.OTP_EXPIRED,
						"OTP expired or not requested. Please request a new one."));

		if (!now.isBefore(challenge.getExpiresAt())) {
			challenge.expire();
			throw new ApiException(ErrorCode.OTP_EXPIRED, "OTP expired. Please request a new one.");
		}

		if (!hasher.matches(phoneE164, code, challenge.getCodeHash())) {
			challenge.registerFailedAttempt();
			if (challenge.getAttempts() >= challenge.getMaxAttempts()) {
				challenge.lock();
				throw new ApiException(ErrorCode.OTP_LOCKED,
						"Too many incorrect attempts. Please request a new OTP.");
			}
			throw new ApiException(ErrorCode.OTP_INVALID, "Incorrect OTP. Please try again.",
					Map.of("remainingAttempts",
							String.valueOf(challenge.getMaxAttempts() - challenge.getAttempts())));
		}
		return challenge;
	}

	@Transactional
	public void consume(OtpChallenge challenge) {
		challenge.consume();
	}
}
