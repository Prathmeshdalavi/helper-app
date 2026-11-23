package com.helper_backend.modules.auth.dto;

/** Deliberately minimal: no name or other account data before the phone is verified. */
public record CheckPhoneResponse(boolean registered) {
}
