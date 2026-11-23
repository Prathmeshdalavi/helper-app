package com.helper_backend.modules.auth.dto;

import com.helper_backend.common.util.PhoneNumbers;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record SendOtpRequest(
		@NotBlank(message = "Phone number is required")
		@Pattern(regexp = PhoneNumbers.NATIONAL_REGEX, message = "Enter a valid 10-digit mobile number")
		String phone) {
}
