package com.helper_backend.modules.auth.service;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Map;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.common.util.Hashes;

/**
 * Fixed-window limiter backed by PostgreSQL (one atomic upsert per hit), so it is
 * correct across several app instances without extra infrastructure. Runs in its own
 * transaction so a rejected request still counts even if the caller rolls back.
 */
@Service
public class RateLimiter {

	private static final String UPSERT = "INSERT INTO auth_rate_limits (rl_key, window_start, hits) "
			+ "VALUES (?, ?, 1) ON CONFLICT (rl_key, window_start) "
			+ "DO UPDATE SET hits = auth_rate_limits.hits + 1 RETURNING hits";

	private final JdbcTemplate jdbc;
	private final Clock clock;

	public RateLimiter(JdbcTemplate jdbc, Clock clock) {
		this.jdbc = jdbc;
		this.clock = clock;
	}

	/** Counts one hit for (scope, identifier); throws 429 once {@code limit} is exceeded. */
	@Transactional(propagation = Propagation.REQUIRES_NEW, noRollbackFor = ApiException.class)
	public void hit(String scope, String identifier, int limit, Duration window) {
		Instant now = clock.instant();
		long windowSeconds = window.toSeconds();
		Instant start = Instant.ofEpochSecond(now.getEpochSecond() / windowSeconds * windowSeconds);
		String key = scope + ":" + Hashes.sha256Hex(identifier).substring(0, 32);

		Integer hits = jdbc.queryForObject(UPSERT, Integer.class, key,
				OffsetDateTime.ofInstant(start, ZoneOffset.UTC));

		if (hits != null && hits > limit) {
			long retryAfter = Math.max(1, start.plusSeconds(windowSeconds).getEpochSecond() - now.getEpochSecond());
			throw new ApiException(ErrorCode.RATE_LIMITED, "Too many requests. Please try again later.",
					Map.of("retryAfterSeconds", String.valueOf(retryAfter)));
		}
	}
}
