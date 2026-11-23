package com.helper_backend.modules.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.test.util.ReflectionTestUtils;

import com.helper_backend.TestData;
import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.modules.auth.domain.OtpChallenge;
import com.helper_backend.modules.auth.domain.OtpStatus;
import com.helper_backend.modules.auth.repository.OtpChallengeRepository;

class OtpServiceTest {

	private static final String PHONE = "+919876543210";
	private static final Instant NOW = Instant.parse("2026-11-23T10:00:00Z");

	private final OtpChallengeRepository repo = mock(OtpChallengeRepository.class);
	private final SmsSender sms = mock(SmsSender.class);
	private final OtpHasher hasher = new OtpHasher(TestData.props());
	private OtpService service;

	@BeforeEach
	void setUp() {
		service = new OtpService(repo, hasher, sms, TestData.props(), Clock.fixed(NOW, ZoneOffset.UTC));
		when(repo.save(any())).thenAnswer(inv -> inv.getArgument(0));
	}

	private OtpChallenge challenge(String code, Instant expiresAt) {
		return new OtpChallenge(PHONE, hasher.hash(PHONE, code), expiresAt, 5);
	}

	// ---- issue ----

	@Test
	void issueStoresOnlyTheHashAndSendsAFourDigitCode() {
		when(repo.findFirstByPhoneE164OrderByCreatedAtDesc(PHONE)).thenReturn(Optional.empty());

		var response = service.issue(PHONE);

		ArgumentCaptor<OtpChallenge> saved = ArgumentCaptor.forClass(OtpChallenge.class);
		verify(repo).save(saved.capture());
		ArgumentCaptor<String> code = ArgumentCaptor.forClass(String.class);
		verify(sms).sendOtp(eq(PHONE), code.capture());
		verify(repo).invalidateActive(PHONE, NOW);

		assertThat(code.getValue()).matches("^[0-9]{4}$");
		OtpChallenge c = saved.getValue();
		assertThat(c.getCodeHash()).isEqualTo(hasher.hash(PHONE, code.getValue())).doesNotContain(code.getValue());
		assertThat(c.getExpiresAt()).isEqualTo(NOW.plusSeconds(300));
		assertThat(c.getStatus()).isEqualTo(OtpStatus.ACTIVE);
		assertThat(c.getMaxAttempts()).isEqualTo(5);
		assertThat(response.resendAfterSeconds()).isEqualTo(15);
		assertThat(response.expiresInSeconds()).isEqualTo(300);
	}

	@Test
	void issueWithinCooldownIsRejectedAndNothingIsSent() {
		OtpChallenge recent = challenge("1111", NOW.plusSeconds(300));
		ReflectionTestUtils.setField(recent, "createdAt", NOW.minusSeconds(5));
		when(repo.findFirstByPhoneE164OrderByCreatedAtDesc(PHONE)).thenReturn(Optional.of(recent));

		assertThatThrownBy(() -> service.issue(PHONE))
				.isInstanceOf(ApiException.class)
				.satisfies(e -> {
					ApiException ex = (ApiException) e;
					assertThat(ex.getCode()).isEqualTo(ErrorCode.RATE_LIMITED);
					assertThat(ex.getDetails()).containsKey("retryAfterSeconds");
				});
		verify(sms, never()).sendOtp(any(), any());
		verify(repo, never()).save(any());
	}

	@Test
	void issueAfterCooldownReplacesTheOldChallenge() {
		OtpChallenge old = challenge("1111", NOW.plusSeconds(100));
		ReflectionTestUtils.setField(old, "createdAt", NOW.minusSeconds(20));
		when(repo.findFirstByPhoneE164OrderByCreatedAtDesc(PHONE)).thenReturn(Optional.of(old));

		service.issue(PHONE);

		verify(repo).invalidateActive(PHONE, NOW);
		verify(sms).sendOtp(eq(PHONE), any());
	}

	@Test
	void issuePropagatesSmsFailure() {
		when(repo.findFirstByPhoneE164OrderByCreatedAtDesc(PHONE)).thenReturn(Optional.empty());
		org.mockito.Mockito.doThrow(new ApiException(ErrorCode.SMS_UNAVAILABLE, "down"))
				.when(sms).sendOtp(any(), any());

		assertThatThrownBy(() -> service.issue(PHONE))
				.isInstanceOf(ApiException.class)
				.extracting("code").isEqualTo(ErrorCode.SMS_UNAVAILABLE);
	}

	// ---- verifyCode ----

	@Test
	void verifyReturnsTheChallengeForTheRightCode() {
		OtpChallenge c = challenge("4821", NOW.plusSeconds(60));
		when(repo.findActiveForUpdate(PHONE)).thenReturn(Optional.of(c));

		assertThat(service.verifyCode(PHONE, "4821")).isSameAs(c);
		assertThat(c.getAttempts()).isZero();
		assertThat(c.getStatus()).isEqualTo(OtpStatus.ACTIVE);
	}

	@Test
	void wrongCodeCountsAnAttemptAndReportsRemaining() {
		OtpChallenge c = challenge("4821", NOW.plusSeconds(60));
		when(repo.findActiveForUpdate(PHONE)).thenReturn(Optional.of(c));

		assertThatThrownBy(() -> service.verifyCode(PHONE, "0000"))
				.isInstanceOf(ApiException.class)
				.satisfies(e -> {
					ApiException ex = (ApiException) e;
					assertThat(ex.getCode()).isEqualTo(ErrorCode.OTP_INVALID);
					assertThat(ex.getDetails()).containsEntry("remainingAttempts", "4");
				});
		assertThat(c.getAttempts()).isEqualTo(1);
		assertThat(c.getStatus()).isEqualTo(OtpStatus.ACTIVE);
	}

	@Test
	void fifthWrongAttemptLocksTheChallengeEvenForTheRightCodeAfterwards() {
		OtpChallenge c = challenge("4821", NOW.plusSeconds(60));
		when(repo.findActiveForUpdate(PHONE)).thenReturn(Optional.of(c));

		for (int i = 0; i < 4; i++) {
			assertThatThrownBy(() -> service.verifyCode(PHONE, "0000"))
					.extracting("code").isEqualTo(ErrorCode.OTP_INVALID);
		}
		assertThatThrownBy(() -> service.verifyCode(PHONE, "0000"))
				.extracting("code").isEqualTo(ErrorCode.OTP_LOCKED);
		assertThat(c.getStatus()).isEqualTo(OtpStatus.LOCKED);

		// A locked challenge is no longer returned by the "active" lookup.
		when(repo.findActiveForUpdate(PHONE)).thenReturn(Optional.empty());
		assertThatThrownBy(() -> service.verifyCode(PHONE, "4821"))
				.extracting("code").isEqualTo(ErrorCode.OTP_EXPIRED);
	}

	@Test
	void expiredChallengeIsRejectedEvenWithTheRightCode() {
		OtpChallenge c = challenge("4821", NOW.minusSeconds(1));
		when(repo.findActiveForUpdate(PHONE)).thenReturn(Optional.of(c));

		assertThatThrownBy(() -> service.verifyCode(PHONE, "4821"))
				.extracting("code").isEqualTo(ErrorCode.OTP_EXPIRED);
		assertThat(c.getStatus()).isEqualTo(OtpStatus.EXPIRED);
	}

	@Test
	void expiryIsInclusiveAtTheExactInstant() {
		OtpChallenge c = challenge("4821", NOW);
		when(repo.findActiveForUpdate(PHONE)).thenReturn(Optional.of(c));

		assertThatThrownBy(() -> service.verifyCode(PHONE, "4821"))
				.extracting("code").isEqualTo(ErrorCode.OTP_EXPIRED);
	}

	@Test
	void noActiveChallengeMeansExpiredOrNotRequested() {
		when(repo.findActiveForUpdate(PHONE)).thenReturn(Optional.empty());

		assertThatThrownBy(() -> service.verifyCode(PHONE, "4821"))
				.extracting("code").isEqualTo(ErrorCode.OTP_EXPIRED);
	}

	@Test
	void consumeMarksTheChallengeUsed() {
		OtpChallenge c = challenge("4821", NOW.plusSeconds(60));
		service.consume(c);
		assertThat(c.getStatus()).isEqualTo(OtpStatus.CONSUMED);
	}
}
