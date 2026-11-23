package com.helper_backend.modules.auth.service;

import java.time.Clock;
import java.time.OffsetDateTime;
import java.time.ZoneOffset;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

/** Hourly housekeeping of short-lived auth data (OTPs, counters, expired tokens). */
@Component
public class AuthCleanupJob {

	private static final Logger log = LoggerFactory.getLogger(AuthCleanupJob.class);

	private final JdbcTemplate jdbc;
	private final Clock clock;

	public AuthCleanupJob(JdbcTemplate jdbc, Clock clock) {
		this.jdbc = jdbc;
		this.clock = clock;
	}

	@Scheduled(cron = "0 15 * * * *")
	@Transactional
	public void purge() {
		OffsetDateTime now = OffsetDateTime.ofInstant(clock.instant(), ZoneOffset.UTC);
		int otps = jdbc.update("DELETE FROM otp_challenges WHERE created_at < ?", now.minusDays(1));
		int limits = jdbc.update("DELETE FROM auth_rate_limits WHERE window_start < ?", now.minusDays(2));
		int tokens = jdbc.update("DELETE FROM refresh_tokens WHERE expires_at < ?", now.minusDays(7));
		log.info("Auth cleanup removed {} otp challenges, {} rate-limit rows, {} expired refresh tokens",
				otps, limits, tokens);
	}
}
