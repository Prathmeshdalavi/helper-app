package com.helper_backend.config;

import java.time.Duration;
import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Typed binding for every custom "app.*" property.
 * Values come from application-{profile}.properties / environment variables.
 */
@ConfigurationProperties(prefix = "app")
public record AppProperties(Jwt jwt, Cors cors) {

	public record Jwt(String secret, String issuer, Duration accessTtl, Duration refreshTtl) {
	}

	public record Cors(List<String> allowedOrigins) {
	}
}
