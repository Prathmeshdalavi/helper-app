package com.helper_backend.config;

import java.time.Duration;
import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.bind.DefaultValue;

/**
 * Typed binding for every custom "app.*" property.
 * Values come from application-{profile}.properties / environment variables.
 */
@ConfigurationProperties(prefix = "app")
public record AppProperties(Jwt jwt, Cors cors, @DefaultValue Otp otp, @DefaultValue Sms sms) {

	public record Jwt(String secret, String issuer, Duration accessTtl, Duration refreshTtl) {
	}

	public record Cors(List<String> allowedOrigins) {
	}

	/** One-time passcode policy. The pepper is a secret and has no default. */
	public record Otp(
			@DefaultValue("5m") Duration ttl,
			@DefaultValue("5") int maxAttempts,
			@DefaultValue("15s") Duration resendCooldown,
			String pepper) {
	}

	/** "log" (dev only, writes the OTP to the log) or "none" (not configured). */
	public record Sms(@DefaultValue("none") String provider) {
	}
}
