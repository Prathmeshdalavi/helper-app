package com.helper_backend.common.exception;

import java.util.LinkedHashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
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
				.body(ApiResponse.fail(ex.getCode().name(), ex.getMessage(), null));
	}

	@ExceptionHandler(MethodArgumentNotValidException.class)
	ResponseEntity<ApiResponse<Void>> handleValidation(MethodArgumentNotValidException ex) {
		Map<String, String> details = new LinkedHashMap<>();
		ex.getBindingResult().getFieldErrors()
				.forEach(f -> details.putIfAbsent(f.getField(), f.getDefaultMessage()));
		return ResponseEntity.status(ErrorCode.VALIDATION_FAILED.status())
				.body(ApiResponse.fail(ErrorCode.VALIDATION_FAILED.name(), "Validation failed", details));
	}

	@ExceptionHandler(Exception.class)
	ResponseEntity<ApiResponse<Void>> handleUnexpected(Exception ex) {
		log.error("Unhandled exception", ex);
		return ResponseEntity.status(ErrorCode.INTERNAL_ERROR.status())
				.body(ApiResponse.fail(ErrorCode.INTERNAL_ERROR.name(), "Something went wrong", null));
	}
}
