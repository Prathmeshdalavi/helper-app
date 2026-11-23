package com.helper_backend.modules.user.dto;

import java.time.Instant;
import java.util.UUID;

/** Public view of an account. {@code phone} is the 10-digit number the apps use. */
public record UserResponse(UUID id, String name, String phone, String email, Instant createdAt) {
}
