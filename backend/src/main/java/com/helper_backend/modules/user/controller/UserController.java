package com.helper_backend.modules.user.controller;

import java.util.UUID;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.helper_backend.common.api.ApiResponse;
import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.modules.user.dto.UserResponse;
import com.helper_backend.modules.user.service.UserService;

@RestController
@RequestMapping("/api/v1/users")
public class UserController {

	private final UserService users;

	public UserController(UserService users) {
		this.users = users;
	}

	/** The caller is always taken from the verified token, never from a request field. */
	@GetMapping("/me")
	public ApiResponse<UserResponse> me(@AuthenticationPrincipal Jwt jwt) {
		UUID id;
		try {
			id = UUID.fromString(jwt.getSubject());
		} catch (IllegalArgumentException | NullPointerException e) {
			throw new ApiException(ErrorCode.UNAUTHORIZED, "Authentication required");
		}
		return ApiResponse.ok(users.toResponse(users.getById(id)));
	}
}
