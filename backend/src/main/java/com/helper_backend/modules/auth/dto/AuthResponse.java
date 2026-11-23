package com.helper_backend.modules.auth.dto;

import com.helper_backend.modules.user.dto.UserResponse;

/** {@code user} is null on refresh; {@code isNewUser} is only meaningful after verify-otp. */
public record AuthResponse(
		String accessToken,
		String refreshToken,
		String tokenType,
		long expiresIn,
		boolean isNewUser,
		UserResponse user) {
}
