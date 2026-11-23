package com.helper_backend.modules.auth.domain;

import java.time.Instant;

import com.helper_backend.common.persistence.BaseEntity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

/** One OTP issued to one phone. Only a keyed hash of the code is stored. */
@Entity
@Table(name = "otp_challenges")
public class OtpChallenge extends BaseEntity {

	@Column(name = "phone_e164", nullable = false, updatable = false, length = 16)
	private String phoneE164;

	@Column(name = "code_hash", nullable = false, updatable = false, length = 64)
	private String codeHash;

	@Column(name = "expires_at", nullable = false, updatable = false)
	private Instant expiresAt;

	@Column(name = "attempts", nullable = false)
	private int attempts;

	@Column(name = "max_attempts", nullable = false, updatable = false)
	private int maxAttempts;

	@Enumerated(EnumType.STRING)
	@Column(name = "status", nullable = false, length = 16)
	private OtpStatus status;

	protected OtpChallenge() {
	}

	public OtpChallenge(String phoneE164, String codeHash, Instant expiresAt, int maxAttempts) {
		this.phoneE164 = phoneE164;
		this.codeHash = codeHash;
		this.expiresAt = expiresAt;
		this.maxAttempts = maxAttempts;
		this.attempts = 0;
		this.status = OtpStatus.ACTIVE;
	}

	public String getPhoneE164() {
		return phoneE164;
	}

	public String getCodeHash() {
		return codeHash;
	}

	public Instant getExpiresAt() {
		return expiresAt;
	}

	public int getAttempts() {
		return attempts;
	}

	public int getMaxAttempts() {
		return maxAttempts;
	}

	public OtpStatus getStatus() {
		return status;
	}

	public void registerFailedAttempt() {
		attempts++;
	}

	public void lock() {
		status = OtpStatus.LOCKED;
	}

	public void expire() {
		status = OtpStatus.EXPIRED;
	}

	public void consume() {
		status = OtpStatus.CONSUMED;
	}
}
