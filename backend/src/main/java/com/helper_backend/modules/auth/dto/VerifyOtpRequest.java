package com.helper_backend.modules.auth.dto;

import com.helper_backend.common.util.PhoneNumbers;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * {@code name} and {@code email} are only read when the phone has no account yet
 * (sign-up); for an existing account they are ignored and never overwrite data.
 */
public record VerifyOtpRequest(
		@NotBlank(message = "Phone number is required")
		@Pattern(regexp = PhoneNumbers.NATIONAL_REGEX, message = "Enter a valid 10-digit mobile number")
		String phone,

		@NotBlank(message = "OTP is required")
		@Pattern(regexp = "^[0-9]{4}$", message = "OTP must be 4 digits")
		String otp,

		@Size(max = 60, message = "Name must be at most 60 characters")
		@Pattern(regexp = "^[^0-9]*$", message = "Name cannot contain digits")
		String name,

		@Size(max = 254, message = "Email is too long")
		String email) {
}
