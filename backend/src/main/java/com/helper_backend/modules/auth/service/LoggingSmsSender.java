package com.helper_backend.modules.auth.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.helper_backend.common.util.PhoneNumbers;

/**
 * DEV ONLY. Writes the OTP to the application log instead of sending an SMS.
 * Enabled only by app.sms.provider=log, which the prod profile never sets.
 */
public class LoggingSmsSender implements SmsSender {

	private static final Logger log = LoggerFactory.getLogger(LoggingSmsSender.class);

	@Override
	public void sendOtp(String phoneE164, String code) {
		log.warn("DEV-ONLY sms provider: OTP for {} is {}", PhoneNumbers.mask(phoneE164), code);
	}
}
