package com.helper_backend.modules.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.Optional;
import java.util.UUID;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.util.ReflectionTestUtils;

import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.modules.auth.domain.OtpChallenge;
import com.helper_backend.modules.auth.dto.AuthResponse;
import com.helper_backend.modules.auth.dto.VerifyOtpRequest;
import com.helper_backend.modules.auth.service.TokenService.TokenPair;
import com.helper_backend.modules.user.domain.User;
import com.helper_backend.modules.user.domain.UserStatus;
import com.helper_backend.modules.user.dto.UserResponse;
import com.helper_backend.modules.user.service.UserService;

class AuthServiceTest {

	private static final String PHONE = "9876543210";
	private static final String E164 = "+919876543210";
	private static final Instant NOW = Instant.parse("2026-11-23T10:00:00Z");

	private final UserService users = mock(UserService.class);
	private final OtpService otp = mock(OtpService.class);
	private final TokenService tokens = mock(TokenService.class);
	private final RateLimiter limiter = mock(RateLimiter.class);
	private final OtpChallenge challenge = mock(OtpChallenge.class);
	private AuthService service;

	@BeforeEach
	void setUp() {
		service = new AuthService(users, otp, tokens, limiter, Clock.fixed(NOW, ZoneOffset.UTC));
		when(otp.verifyCode(eq(E164), anyString())).thenReturn(challenge);
		when(tokens.issue(any())).thenReturn(new TokenPair("access", "refresh", 900));
		when(users.toResponse(any())).thenAnswer(inv -> {
			User u = inv.getArgument(0);
			return new UserResponse(UUID.randomUUID(), u.getFullName(), PHONE, u.getEmail(), NOW);
		});
	}

	private static VerifyOtpRequest request(String name, String email) {
		return new VerifyOtpRequest(PHONE, "4821", name, email);
	}

	// ---- check-phone ----

	@Test
	void checkPhoneReportsOnlyWhetherTheNumberIsRegistered() {
		when(users.findByPhone(E164)).thenReturn(Optional.of(User.newCustomer(E164, "Anita Rao", null, NOW)));
		assertThat(service.checkPhone(PHONE, "1.2.3.4").registered()).isTrue();

		when(users.findByPhone(E164)).thenReturn(Optional.empty());
		assertThat(service.checkPhone(PHONE, "1.2.3.4").registered()).isFalse();
	}

	@Test
	void checkPhoneIsRateLimitedByIpAndByPhone() {
		service.checkPhone(PHONE, "1.2.3.4");
		verify(limiter).hit(eq("chk-ip"), eq("1.2.3.4"), eq(30), any());
		verify(limiter).hit(eq("chk-phone"), eq(PHONE), eq(10), any());
	}

	@Test
	void rateLimitStopsCheckPhoneBeforeAnyLookup() {
		doThrow(new ApiException(ErrorCode.RATE_LIMITED, "slow down")).when(limiter).hit(eq("chk-ip"), any(), org.mockito.ArgumentMatchers.anyInt(), any());
		assertThatThrownBy(() -> service.checkPhone(PHONE, "1.2.3.4"))
				.extracting("code").isEqualTo(ErrorCode.RATE_LIMITED);
		verifyNoInteractions(users);
	}

	// ---- send-otp ----

	@Test
	void sendOtpIsRateLimitedAndDelegatesWithE164() {
		service.sendOtp(PHONE, "1.2.3.4");
		verify(limiter).hit(eq("otp-ip"), eq("1.2.3.4"), eq(20), any());
		verify(limiter).hit(eq("otp-phone"), eq(PHONE), eq(5), any());
		verify(otp).issue(E164);
	}

	@Test
	void rateLimitStopsSendOtpBeforeAnySms() {
		doThrow(new ApiException(ErrorCode.RATE_LIMITED, "slow down")).when(limiter).hit(eq("otp-phone"), any(), org.mockito.ArgumentMatchers.anyInt(), any());
		assertThatThrownBy(() -> service.sendOtp(PHONE, "1.2.3.4"))
				.extracting("code").isEqualTo(ErrorCode.RATE_LIMITED);
		verifyNoInteractions(otp);
	}

	// ---- verify-otp ----

	@Test
	void existingUserSignsInAndRequestNameIsIgnored() {
		User existing = User.newCustomer(E164, "Anita Rao", "a@x.com", NOW);
		when(users.findByPhone(E164)).thenReturn(Optional.of(existing));

		AuthResponse res = service.verifyOtp(request("Someone Else", "evil@x.com"), "1.2.3.4");

		assertThat(res.isNewUser()).isFalse();
		assertThat(res.user().name()).isEqualTo("Anita Rao");
		assertThat(res.accessToken()).isEqualTo("access");
		assertThat(res.tokenType()).isEqualTo("Bearer");
		verify(users, never()).createCustomer(any(), any(), any(), any());
		verify(otp).consume(challenge);
	}

	@Test
	void newUserIsRegisteredWithCleanedNameAndEmail() {
		when(users.findByPhone(E164)).thenReturn(Optional.empty());
		when(users.createCustomer(any(), any(), any(), any()))
				.thenAnswer(inv -> User.newCustomer(inv.getArgument(0), inv.getArgument(1), inv.getArgument(2), inv.getArgument(3)));

		AuthResponse res = service.verifyOtp(request("  Priya   Sharma ", " priya@example.com "), "1.2.3.4");

		assertThat(res.isNewUser()).isTrue();
		verify(users).createCustomer(E164, "Priya Sharma", "priya@example.com", NOW);
		verify(otp).consume(challenge);
		verify(tokens).issue(any());
	}

	@Test
	void blankEmailIsStoredAsNull() {
		when(users.findByPhone(E164)).thenReturn(Optional.empty());
		when(users.createCustomer(any(), any(), any(), any()))
				.thenAnswer(inv -> User.newCustomer(inv.getArgument(0), inv.getArgument(1), inv.getArgument(2), inv.getArgument(3)));

		service.verifyOtp(request("Priya Sharma", "   "), "1.2.3.4");

		verify(users).createCustomer(E164, "Priya Sharma", null, NOW);
	}

	@Test
	void newUserWithoutAValidNameIsRejectedAndTheOtpIsNotConsumed() {
		when(users.findByPhone(E164)).thenReturn(Optional.empty());

		for (String bad : new String[] { null, "", " ", "P", "Priya99" }) {
			assertThatThrownBy(() -> service.verifyOtp(request(bad, null), "1.2.3.4"))
					.isInstanceOf(ApiException.class)
					.satisfies(e -> {
						ApiException ex = (ApiException) e;
						assertThat(ex.getCode()).isEqualTo(ErrorCode.VALIDATION_FAILED);
						assertThat(ex.getDetails()).containsKey("name");
					});
		}
		verify(otp, never()).consume(any());
		verify(users, never()).createCustomer(any(), any(), any(), any());
		verifyNoInteractions(tokens);
	}

	@Test
	void newUserWithAnInvalidEmailIsRejected() {
		when(users.findByPhone(E164)).thenReturn(Optional.empty());

		assertThatThrownBy(() -> service.verifyOtp(request("Priya Sharma", "not-an-email"), "1.2.3.4"))
				.isInstanceOf(ApiException.class)
				.satisfies(e -> assertThat(((ApiException) e).getDetails()).containsKey("email"));
		verify(otp, never()).consume(any());
	}

	@Test
	void wrongOtpNeverReachesAccountCreation() {
		when(otp.verifyCode(eq(E164), anyString()))
				.thenThrow(new ApiException(ErrorCode.OTP_INVALID, "Incorrect OTP"));

		assertThatThrownBy(() -> service.verifyOtp(request("Priya Sharma", null), "1.2.3.4"))
				.extracting("code").isEqualTo(ErrorCode.OTP_INVALID);
		verifyNoInteractions(users);
		verifyNoInteractions(tokens);
	}

	@Test
	void blockedAccountsCannotSignIn() {
		User blocked = User.newCustomer(E164, "Anita Rao", null, NOW);
		ReflectionTestUtils.setField(blocked, "status", UserStatus.BLOCKED);
		when(users.findByPhone(E164)).thenReturn(Optional.of(blocked));

		assertThatThrownBy(() -> service.verifyOtp(request(null, null), "1.2.3.4"))
				.extracting("code").isEqualTo(ErrorCode.FORBIDDEN);
		verifyNoInteractions(tokens);
		verify(otp, never()).consume(any());
	}

	@Test
	void verifyIsRateLimitedBeforeTheCodeIsChecked() {
		doThrow(new ApiException(ErrorCode.RATE_LIMITED, "slow down")).when(limiter).hit(eq("ver-phone"), any(), org.mockito.ArgumentMatchers.anyInt(), any());

		assertThatThrownBy(() -> service.verifyOtp(request("Priya Sharma", null), "1.2.3.4"))
				.extracting("code").isEqualTo(ErrorCode.RATE_LIMITED);
		verifyNoInteractions(otp);
	}

	// ---- refresh / logout ----

	@Test
	void refreshReturnsATokenPairWithoutUserData() {
		when(tokens.rotate("old")).thenReturn(new TokenPair("a2", "r2", 900));

		AuthResponse res = service.refresh("old", "1.2.3.4");

		assertThat(res.accessToken()).isEqualTo("a2");
		assertThat(res.refreshToken()).isEqualTo("r2");
		assertThat(res.user()).isNull();
		assertThat(res.isNewUser()).isFalse();
	}

	@Test
	void logoutPassesTheAuthenticatedUserId() {
		UUID id = UUID.randomUUID();
		service.logout("tok", id);
		verify(tokens).revoke("tok", id);
	}
}
