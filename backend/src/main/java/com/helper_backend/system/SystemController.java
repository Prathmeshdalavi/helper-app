package com.helper_backend.system;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.helper_backend.common.api.ApiResponse;

/** Public smoke-test endpoint for the mobile app, admin web and load balancers. */
@RestController
@RequestMapping("/api/v1/system")
public class SystemController {

	@GetMapping("/ping")
	public ApiResponse<Map<String, String>> ping() {
		return ApiResponse.ok(Map.of("service", "hercare-backend", "status", "UP"));
	}
}
