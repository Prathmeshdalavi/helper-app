package com.helper_backend;

import java.time.Duration;
import java.util.List;

import com.helper_backend.config.AppProperties;

/** Shared fixtures for unit tests. All secrets here are test-only. */
public final class TestData {

	public static final String JWT_SECRET = "test-only-jwt-secret-0123456789-abcdef";
	public static final String OTP_PEPPER = "test-only-otp-pepper-0123456789-abcdefg";

	private TestData() {
	}

	public static AppProperties props() {
		return new AppProperties(
				new AppProperties.Jwt(JWT_SECRET, "helper-test", Duration.ofMinutes(15), Duration.ofDays(30)),
				new AppProperties.Cors(List.of("http://localhost")),
				new AppProperties.Otp(Duration.ofMinutes(5), 5, Duration.ofSeconds(15), OTP_PEPPER),
				new AppProperties.Sms("none"));
	}
}
