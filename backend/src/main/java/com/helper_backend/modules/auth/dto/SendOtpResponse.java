package com.helper_backend.modules.auth.dto;

public record SendOtpResponse(int resendAfterSeconds, int expiresInSeconds) {
}
