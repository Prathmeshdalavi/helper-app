package com.helper_backend.common.exception;

import java.util.Map;

/** Throw from services to produce a clean, typed API error. */
public class ApiException extends RuntimeException {

	private final ErrorCode code;
	private final Map<String, String> details;

	public ApiException(ErrorCode code, String message) {
		this(code, message, null);
	}

	public ApiException(ErrorCode code, String message, Map<String, String> details) {
		super(message);
		this.code = code;
		this.details = details;
	}

	public ErrorCode getCode() {
		return code;
	}

	public Map<String, String> getDetails() {
		return details;
	}
}
