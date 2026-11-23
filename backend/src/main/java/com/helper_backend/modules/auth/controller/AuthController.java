package com.helper_backend.modules.auth.controller;

import java.util.UUID;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.helper_backend.common.api.ApiResponse;
import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.modules.auth.dto.AuthResponse;
import com.helper_backend.modules.auth.dto.CheckPhoneRequest;
import com.helper_backend.modules.auth.dto.CheckPhoneResponse;
import com.helper_backend.modules.auth.dto.LogoutRequest;
import com.helper_backend.modules.auth.dto.RefreshRequest;
import com.helper_backend.modules.auth.dto.SendOtpRequest;
import com.helper_backend.modules.auth.dto.SendOtpResponse;
import com.helper_backend.modules.auth.dto.VerifyOtpRequest;
import com.helper_backend.modules.auth.service.AuthService;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

	private final AuthService auth;

	public AuthController(AuthService auth) {
		this.auth = auth;
	}

	@PostMapping("/check-phone")
	public ApiResponse<CheckPhoneResponse> checkPhone(@Valid @RequestBody CheckPhoneRequest req,
			HttpServletRequest http) {
		return ApiResponse.ok(auth.checkPhone(req.phone(), http.getRemoteAddr()));
	}

	@PostMapping("/send-otp")
	public ApiResponse<SendOtpResponse> sendOtp(@Valid @RequestBody SendOtpRequest req,
			HttpServletRequest http) {
		return ApiResponse.ok(auth.sendOtp(req.phone(), http.getRemoteAddr()));
	}

	@PostMapping("/verify-otp")
	public ApiResponse<AuthResponse> verifyOtp(@Valid @RequestBody VerifyOtpRequest req,
			HttpServletRequest http) {
		return ApiResponse.ok(auth.verifyOtp(req, http.getRemoteAddr()));
	}

	@PostMapping("/refresh")
	public ApiResponse<AuthResponse> refresh(@Valid @RequestBody RefreshRequest req,
			HttpServletRequest http) {
		return ApiResponse.ok(auth.refresh(req.refreshToken(), http.getRemoteAddr()));
	}

	@PostMapping("/logout")
	public ApiResponse<Void> logout(@Valid @RequestBody LogoutRequest req, @AuthenticationPrincipal Jwt jwt) {
		UUID userId;
		try {
			userId = UUID.fromString(jwt.getSubject());
		} catch (IllegalArgumentException | NullPointerException e) {
			throw new ApiException(ErrorCode.UNAUTHORIZED, "Authentication required");
		}
		auth.logout(req.refreshToken(), userId);
		return ApiResponse.ok(null);
	}
}
