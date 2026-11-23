package com.helper_backend.common.exception;

import org.springframework.http.HttpStatus;

/** Keep in sync with shared/contracts/error-codes.json. */
public enum ErrorCode {
	VALIDATION_FAILED(HttpStatus.BAD_REQUEST),
	UNAUTHORIZED(HttpStatus.UNAUTHORIZED),
	FORBIDDEN(HttpStatus.FORBIDDEN),
	NOT_FOUND(HttpStatus.NOT_FOUND),
	CONFLICT(HttpStatus.CONFLICT),
	OTP_INVALID(HttpStatus.BAD_REQUEST),
	OTP_EXPIRED(HttpStatus.BAD_REQUEST),
	OTP_LOCKED(HttpStatus.TOO_MANY_REQUESTS),
	RATE_LIMITED(HttpStatus.TOO_MANY_REQUESTS),
	SMS_UNAVAILABLE(HttpStatus.SERVICE_UNAVAILABLE),
	INTERNAL_ERROR(HttpStatus.INTERNAL_SERVER_ERROR);

	private final HttpStatus status;

	ErrorCode(HttpStatus status) {
		this.status = status;
	}

	public HttpStatus status() {
		return status;
	}
}
