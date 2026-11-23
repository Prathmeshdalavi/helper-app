package com.helper_backend.modules.auth.service;

/** Delivers an OTP to a phone. A real provider is not integrated yet. */
public interface SmsSender {

	void sendOtp(String phoneE164, String code);
}
