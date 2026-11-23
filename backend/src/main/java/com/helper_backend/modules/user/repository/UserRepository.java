package com.helper_backend.modules.user.repository;

import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.helper_backend.modules.user.domain.User;

public interface UserRepository extends JpaRepository<User, UUID> {

	Optional<User> findByPhoneE164(String phoneE164);
}
