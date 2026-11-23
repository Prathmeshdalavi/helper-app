package com.helper_backend.modules.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record LogoutRequest(
		@NotBlank(message = "Refresh token is required")
		@Size(max = 200, message = "Invalid refresh token")
		String refreshToken) {
}
