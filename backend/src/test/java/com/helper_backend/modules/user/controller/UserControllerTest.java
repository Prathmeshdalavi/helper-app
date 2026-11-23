package com.helper_backend.modules.user.controller;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.Instant;
import java.util.UUID;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
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
import com.helper_backend.modules.user.domain.User;
import com.helper_backend.modules.user.dto.UserResponse;
import com.helper_backend.modules.user.service.UserService;

@WebMvcTest(UserController.class)
@Import({ SecurityConfig.class, JsonSecurityHandlers.class, JwtConfig.class, CorsConfig.class })
@EnableConfigurationProperties(AppProperties.class)
@TestPropertySource(properties = {
		"app.jwt.secret=test-only-jwt-secret-0123456789-abcdef",
		"app.jwt.issuer=helper-test",
		"app.jwt.access-ttl=15m",
		"app.jwt.refresh-ttl=30d",
		"app.cors.allowed-origins=http://localhost"
})
class UserControllerTest {

	@Autowired
	MockMvc mvc;

	@MockitoBean
	UserService users;

	@Test
	void meRequiresAuthentication() throws Exception {
		mvc.perform(get("/api/v1/users/me"))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.error.code").value("UNAUTHORIZED"));
		verifyNoInteractions(users);
	}

	@Test
	void meReturnsTheProfileOfTheTokenOwnerOnly() throws Exception {
		UUID id = UUID.randomUUID();
		User user = User.newCustomer("+919876543210", "Priya Sharma", "priya@example.com", Instant.now());
		when(users.getById(id)).thenReturn(user);
		when(users.toResponse(user)).thenReturn(
				new UserResponse(id, "Priya Sharma", "9876543210", "priya@example.com", Instant.parse("2026-11-23T10:00:00Z")));

		mvc.perform(get("/api/v1/users/me").with(jwt().jwt(j -> j.subject(id.toString()))))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.data.id").value(id.toString()))
				.andExpect(jsonPath("$.data.name").value("Priya Sharma"))
				.andExpect(jsonPath("$.data.phone").value("9876543210"))
				.andExpect(jsonPath("$.data.email").value("priya@example.com"));

		verify(users).getById(id);
	}

	@Test
	void aTokenWithoutAValidUserIdIsRejected() throws Exception {
		mvc.perform(get("/api/v1/users/me").with(jwt().jwt(j -> j.subject("not-a-uuid"))))
				.andExpect(status().isUnauthorized());
		verifyNoInteractions(users);
	}

	@Test
	void deletedAccountsAreNotFound() throws Exception {
		UUID id = UUID.randomUUID();
		when(users.getById(id)).thenThrow(new ApiException(ErrorCode.NOT_FOUND, "Account not found"));

		mvc.perform(get("/api/v1/users/me").with(jwt().jwt(j -> j.subject(id.toString()))))
				.andExpect(status().isNotFound())
				.andExpect(jsonPath("$.error.code").value("NOT_FOUND"));
	}
}
