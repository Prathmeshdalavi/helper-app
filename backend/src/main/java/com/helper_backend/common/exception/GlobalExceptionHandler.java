package com.helper_backend.common.exception;

import java.util.LinkedHashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import com.helper_backend.common.api.ApiResponse;

@RestControllerAdvice
public class GlobalExceptionHandler {

	private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

	@ExceptionHandler(ApiException.class)
	ResponseEntity<ApiResponse<Void>> handleApi(ApiException ex) {
		return ResponseEntity.status(ex.getCode().status())
				.body(ApiResponse.fail(ex.getCode().name(), ex.getMessage(), ex.getDetails()));
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException ex) {
		Map<String, String> details = new LinkedHashMap<>();
		ex.getBindingResult().getFieldErrors()
				.forEach(f -> details.putIfAbsent(f.getField(), f.getDefaultMessage()));
		return ResponseEntity.status(ErrorCode.VALIDATION_FAILED.status())
				.body(ApiResponse.fail(ErrorCode.VALIDATION_FAILED.name(), "Validation failed", details));
	}

	@ExceptionHandler(HttpMessageNotReadableException.class)
	ResponseEntity<ApiResponse<Void>> handleUnreadable(HttpMessageNotReadableException ex) {
		return ResponseEntity.status(ErrorCode.VALIDATION_FAILED.status())
				.body(ApiResponse.fail(ErrorCode.VALIDATION_FAILED.name(), "Malformed request body", null));
	}

	@ExceptionHandler(DataIntegrityViolationException.class)
	ResponseEntity<ApiResponse<Void>> handleIntegrity(DataIntegrityViolationException ex) {
		log.warn("Data integrity violation: {}", ex.getMostSpecificCause().getClass().getSimpleName());
		return ResponseEntity.status(ErrorCode.CONFLICT.status())
				.body(ApiResponse.fail(ErrorCode.CONFLICT.name(),
						"The request conflicts with the current state. Please retry.", null));
	}

	@ExceptionHandler(Exception.class)
	ResponseEntity<ApiResponse<Void>> handleUnexpected(Exception ex) throws Exception {
		// Let Spring Security's own handlers produce 401/403.
		if (ex instanceof AccessDeniedException || ex instanceof AuthenticationException) {
			throw ex;
		}
		// Standard Spring MVC errors (404 unknown route, 405, 415, ...) keep their status.
		if (ex instanceof ErrorResponse er) {
			HttpStatusCode status = er.getStatusCode();
			ErrorCode code = status.value() == 404 ? ErrorCode.NOT_FOUND : ErrorCode.VALIDATION_FAILED;
			String message = status.value() == 404 ? "Resource not found" : "Request could not be processed";
			return ResponseEntity.status(status).body(ApiResponse.fail(code.name(), message, null));
		}
		log.error("Unhandled exception", ex);
		return ResponseEntity.status(ErrorCode.INTERNAL_ERROR.status())
				.body(ApiResponse.fail(ErrorCode.INTERNAL_ERROR.name(), "Something went wrong", null));
	}
}
