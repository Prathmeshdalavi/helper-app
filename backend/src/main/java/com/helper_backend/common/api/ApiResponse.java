package com.helper_backend.common.api;

import java.time.Instant;
import java.util.Map;

import com.fasterxml.jackson.annotation.JsonInclude;

/** Uniform envelope for every API response. See docs/api-conventions.md. */
@JsonInclude(JsonInclude.Include.NON_NULL)
public record ApiResponse<T>(boolean success, T data, ApiError error, Instant timestamp) {

	public record ApiError(String code, String message, Map<String, String> details) {
	}

	public static <T> ApiResponse<T> ok(T data) {
		return new ApiResponse<>(true, data, null, Instant.now());
	}

	public static <T> ApiResponse<T> fail(String code, String message, Map<String, String> details) {
		return new ApiResponse<>(false, null, new ApiError(code, message, details), Instant.now());
	}
}
