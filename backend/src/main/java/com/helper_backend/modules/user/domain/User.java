package com.helper_backend.modules.user.domain;

import java.time.Instant;

import com.helper_backend.common.persistence.BaseEntity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Table;

@Entity
@Table(name = "users")
public class User extends BaseEntity {

	@Column(name = "phone_e164", nullable = false, updatable = false, length = 16)
	private String phoneE164;

	@Column(name = "full_name", nullable = false, length = 60)
	private String fullName;

	@Column(name = "email", length = 254)
	private String email;

	@Enumerated(EnumType.STRING)
	@Column(name = "role", nullable = false, length = 20)
	private UserRole role;

	@Enumerated(EnumType.STRING)
	@Column(name = "status", nullable = false, length = 20)
	private UserStatus status;

	@Column(name = "terms_accepted_at")
	private Instant termsAcceptedAt;

	protected User() {
	}

	public static User newCustomer(String phoneE164, String fullName, String email, Instant termsAcceptedAt) {
		User u = new User();
		u.phoneE164 = phoneE164;
		u.fullName = fullName;
		u.email = email;
		u.role = UserRole.CUSTOMER;
		u.status = UserStatus.ACTIVE;
		u.termsAcceptedAt = termsAcceptedAt;
		return u;
	}

	public String getPhoneE164() {
		return phoneE164;
	}

	public String getFullName() {
		return fullName;
	}

	public String getEmail() {
		return email;
	}

	public UserRole getRole() {
		return role;
	}

	public UserStatus getStatus() {
		return status;
	}

	public Instant getTermsAcceptedAt() {
		return termsAcceptedAt;
	}

	public boolean isActive() {
		return status == UserStatus.ACTIVE;
	}
}
