package com.helper_backend.modules.auth.controller;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.MediaType;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.config.AppProperties;
import com.helper_backend.config.CorsConfig;
import com.helper_backend.config.JsonSecurityHandlers;
import com.helper_backend.config.JwtConfig;
import com.helper_backend.config.SecurityConfig;
import com.helper_backend.modules.auth.dto.AuthResponse;
import com.helper_backend.modules.auth.dto.CheckPhoneResponse;
import com.helper_backend.modules.auth.dto.SendOtpResponse;
import com.helper_backend.modules.auth.service.AuthService;

@WebMvcTest(AuthController.class)
@Import({ SecurityConfig.class, JsonSecurityHandlers.class, JwtConfig.class, CorsConfig.class })
@EnableConfigurationProperties(AppProperties.class)
@TestPropertySource(properties = {
		"app.jwt.secret=test-only-jwt-secret-0123456789-abcdef",
		"app.jwt.issuer=helper-test",
		"app.jwt.access-ttl=15m",
		"app.jwt.refresh-ttl=30d",
		"app.cors.allowed-origins=http://localhost"
})
class AuthControllerTest {

	@Autowired
	MockMvc mvc;

	@MockitoBean
	AuthService auth;

	private static String json(String body) {
		return body;
	}

	// ---- check-phone ----

	@Test
	void checkPhoneIsPublicAndReturnsOnlyRegisteredFlag() throws Exception {
		when(auth.checkPhone(eq("9876543210"), any())).thenReturn(new CheckPhoneResponse(true));

		mvc.perform(post("/api/v1/auth/check-phone").contentType(MediaType.APPLICATION_JSON)
				.content(json("{\"phone\":\"9876543210\"}")))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.success").value(true))
				.andExpect(jsonPath("$.data.registered").value(true))
				.andExpect(jsonPath("$.data.name").doesNotExist());
	}

	@Test
	void checkPhoneRejectsInvalidNumbers() throws Exception {
		for (String bad : new String[] { "", "123", "5876543210", "98765abcde", "98765432101" }) {
			mvc.perform(post("/api/v1/auth/check-phone").contentType(MediaType.APPLICATION_JSON)
					.content(json("{\"phone\":\"" + bad + "\"}")))
					.andExpect(status().isBadRequest())
					.andExpect(jsonPath("$.success").value(false))
					.andExpect(jsonPath("$.error.code").value("VALIDATION_FAILED"))
					.andExpect(jsonPath("$.error.details.phone").exists());
		}
		verifyNoInteractions(auth);
	}

	@Test
	void missingOrMalformedBodyIsABadRequest() throws Exception {
		mvc.perform(post("/api/v1/auth/check-phone").contentType(MediaType.APPLICATION_JSON).content("{}"))
				.andExpect(status().isBadRequest());
		mvc.perform(post("/api/v1/auth/check-phone").contentType(MediaType.APPLICATION_JSON).content("{not json"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.error.code").value("VALIDATION_FAILED"));
		verifyNoInteractions(auth);
	}

	// ---- send-otp ----

	@Test
	void sendOtpReturnsTimings() throws Exception {
		when(auth.sendOtp(eq("9876543210"), any())).thenReturn(new SendOtpResponse(15, 300));

		mvc.perform(post("/api/v1/auth/send-otp").contentType(MediaType.APPLICATION_JSON)
				.content("{\"phone\":\"9876543210\"}"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.data.resendAfterSeconds").value(15))
				.andExpect(jsonPath("$.data.expiresInSeconds").value(300));
	}

	@Test
	void sendOtpMapsServiceErrorsToStatusAndCode() throws Exception {
		when(auth.sendOtp(any(), any())).thenThrow(
				new ApiException(ErrorCode.RATE_LIMITED, "Too many requests", Map.of("retryAfterSeconds", "42")));
		mvc.perform(post("/api/v1/auth/send-otp").contentType(MediaType.APPLICATION_JSON)
				.content("{\"phone\":\"9876543210\"}"))
				.andExpect(status().isTooManyRequests())
				.andExpect(jsonPath("$.error.code").value("RATE_LIMITED"))
				.andExpect(jsonPath("$.error.details.retryAfterSeconds").value("42"));

		// Re-stubbing with when(...) would call the already-throwing mock, so use doThrow.
		org.mockito.Mockito.doThrow(new ApiException(ErrorCode.SMS_UNAVAILABLE, "down"))
				.when(auth).sendOtp(any(), any());
		mvc.perform(post("/api/v1/auth/send-otp").contentType(MediaType.APPLICATION_JSON)
				.content("{\"phone\":\"9876543210\"}"))
				.andExpect(status().isServiceUnavailable())
				.andExpect(jsonPath("$.error.code").value("SMS_UNAVAILABLE"));
	}

	// ---- verify-otp ----

	@Test
	void verifyOtpReturnsTokensAndUser() throws Exception {
		when(auth.verifyOtp(any(), any())).thenReturn(
				new AuthResponse("access.jwt", "refresh-token", "Bearer", 900, true, null));

		mvc.perform(post("/api/v1/auth/verify-otp").contentType(MediaType.APPLICATION_JSON)
				.content("{\"phone\":\"9876543210\",\"otp\":\"4821\",\"name\":\"Priya Sharma\"}"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.data.accessToken").value("access.jwt"))
				.andExpect(jsonPath("$.data.refreshToken").value("refresh-token"))
				.andExpect(jsonPath("$.data.tokenType").value("Bearer"))
				.andExpect(jsonPath("$.data.expiresIn").value(900))
				.andExpect(jsonPath("$.data.isNewUser").value(true));
	}

	@Test
	void verifyOtpValidatesTheRequestShape() throws Exception {
		String[] bodies = {
				"{\"phone\":\"9876543210\",\"otp\":\"12a4\"}",
				"{\"phone\":\"9876543210\",\"otp\":\"123\"}",
				"{\"phone\":\"9876543210\",\"otp\":\"12345\"}",
				"{\"phone\":\"9876543210\"}",
				"{\"phone\":\"9876543210\",\"otp\":\"4821\",\"name\":\"Priya99\"}",
				"{\"phone\":\"1234567890\",\"otp\":\"4821\"}"
		};
		for (String body : bodies) {
			mvc.perform(post("/api/v1/auth/verify-otp").contentType(MediaType.APPLICATION_JSON).content(body))
					.andExpect(status().isBadRequest())
					.andExpect(jsonPath("$.error.code").value("VALIDATION_FAILED"));
		}
		verifyNoInteractions(auth);
	}

	@Test
	void verifyOtpReportsWrongOtpWithRemainingAttempts() throws Exception {
		when(auth.verifyOtp(any(), any())).thenThrow(new ApiException(ErrorCode.OTP_INVALID,
				"Incorrect OTP. Please try again.", Map.of("remainingAttempts", "3")));

		mvc.perform(post("/api/v1/auth/verify-otp").contentType(MediaType.APPLICATION_JSON)
				.content("{\"phone\":\"9876543210\",\"otp\":\"0000\"}"))
				.andExpect(status().isBadRequest())
				.andExpect(jsonPath("$.error.code").value("OTP_INVALID"))
				.andExpect(jsonPath("$.error.details.remainingAttempts").value("3"));
	}

	@Test
	void lockedOtpIs429() throws Exception {
		when(auth.verifyOtp(any(), any())).thenThrow(new ApiException(ErrorCode.OTP_LOCKED, "locked"));

		mvc.perform(post("/api/v1/auth/verify-otp").contentType(MediaType.APPLICATION_JSON)
				.content("{\"phone\":\"9876543210\",\"otp\":\"0000\"}"))
				.andExpect(status().isTooManyRequests())
				.andExpect(jsonPath("$.error.code").value("OTP_LOCKED"));
	}

	// ---- refresh ----

	@Test
	void refreshIsPublicButNeedsATokenInTheBody() throws Exception {
		when(auth.refresh(eq("rt"), any())).thenReturn(new AuthResponse("a", "r", "Bearer", 900, false, null));

		mvc.perform(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
				.content("{\"refreshToken\":\"rt\"}"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.data.accessToken").value("a"));

		mvc.perform(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON).content("{}"))
				.andExpect(status().isBadRequest());
	}

	@Test
	void refreshWithAnInvalidTokenIs401InTheEnvelope() throws Exception {
		when(auth.refresh(any(), any())).thenThrow(new ApiException(ErrorCode.UNAUTHORIZED, "Session expired"));

		mvc.perform(post("/api/v1/auth/refresh").contentType(MediaType.APPLICATION_JSON)
				.content("{\"refreshToken\":\"stolen\"}"))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.error.code").value("UNAUTHORIZED"));
	}

	// ---- logout (authenticated) ----

	@Test
	void logoutWithoutATokenIs401WithTheStandardEnvelope() throws Exception {
		mvc.perform(post("/api/v1/auth/logout").contentType(MediaType.APPLICATION_JSON)
				.content("{\"refreshToken\":\"rt\"}"))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.success").value(false))
				.andExpect(jsonPath("$.error.code").value("UNAUTHORIZED"));
		verifyNoInteractions(auth);
	}

	@Test
	void logoutUsesTheIdentityFromTheToken() throws Exception {
		UUID id = UUID.randomUUID();

		mvc.perform(post("/api/v1/auth/logout")
				.with(jwt().jwt(j -> j.subject(id.toString())))
				.contentType(MediaType.APPLICATION_JSON)
				.content("{\"refreshToken\":\"rt\"}"))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.success").value(true));

		verify(auth).logout("rt", id);
	}

	// ---- cross-cutting security / errors ----

	@Test
	void adminRoutesAreForbiddenForCustomers() throws Exception {
		mvc.perform(get("/api/v1/admin/anything")
				.with(jwt().authorities(new SimpleGrantedAuthority("ROLE_CUSTOMER"))))
				.andExpect(status().isForbidden())
				.andExpect(jsonPath("$.error.code").value("FORBIDDEN"));
	}

	@Test
	void unknownRoutesAreNotFoundNotServerErrors() throws Exception {
		mvc.perform(get("/api/v1/does-not-exist").with(jwt()))
				.andExpect(status().isNotFound())
				.andExpect(jsonPath("$.error.code").value("NOT_FOUND"));
	}

	@Test
	void garbageBearerTokenIs401() throws Exception {
		mvc.perform(get("/api/v1/users/me").header("Authorization", "Bearer not.a.jwt"))
				.andExpect(status().isUnauthorized());
	}
}
