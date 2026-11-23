package com.helper_backend.modules.auth.repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.helper_backend.modules.auth.domain.OtpChallenge;

import jakarta.persistence.LockModeType;

public interface OtpChallengeRepository extends JpaRepository<OtpChallenge, UUID> {

	/** Row lock: concurrent verifications of the same phone are serialized. */
	@Lock(LockModeType.PESSIMISTIC_WRITE)
	@Query("select o from OtpChallenge o where o.phoneE164 = :phone "
			+ "and o.status = com.helper_backend.modules.auth.domain.OtpStatus.ACTIVE")
	Optional<OtpChallenge> findActiveForUpdate(@Param("phone") String phone);

	Optional<OtpChallenge> findFirstByPhoneE164OrderByCreatedAtDesc(String phoneE164);

	@Modifying(flushAutomatically = true, clearAutomatically = true)
	@Query("update OtpChallenge o set o.status = com.helper_backend.modules.auth.domain.OtpStatus.INVALIDATED, "
			+ "o.updatedAt = :now where o.phoneE164 = :phone "
			+ "and o.status = com.helper_backend.modules.auth.domain.OtpStatus.ACTIVE")
	int invalidateActive(@Param("phone") String phone, @Param("now") Instant now);
}
