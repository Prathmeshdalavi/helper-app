package com.helper_backend.modules.user.service;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;
import com.helper_backend.common.util.PhoneNumbers;
import com.helper_backend.modules.user.domain.User;
import com.helper_backend.modules.user.dto.UserResponse;
import com.helper_backend.modules.user.repository.UserRepository;

/** The only entry point other modules use to read or create accounts. */
@Service
public class UserService {

	private final UserRepository users;

	public UserService(UserRepository users) {
		this.users = users;
	}

	@Transactional(readOnly = true)
	public Optional<User> findByPhone(String phoneE164) {
		return users.findByPhoneE164(phoneE164);
	}

	@Transactional
	public User createCustomer(String phoneE164, String fullName, String email, Instant termsAcceptedAt) {
		return users.save(User.newCustomer(phoneE164, fullName, email, termsAcceptedAt));
	}

	@Transactional(readOnly = true)
	public User getById(UUID id) {
		return users.findById(id)
				.orElseThrow(() -> new ApiException(ErrorCode.NOT_FOUND, "Account not found"));
	}

	public UserResponse toResponse(User u) {
		return new UserResponse(u.getId(), u.getFullName(), PhoneNumbers.toNational(u.getPhoneE164()),
				u.getEmail(), u.getCreatedAt());
	}
}
