package com.helper_backend.modules.auth.service;

import com.helper_backend.common.exception.ApiException;
import com.helper_backend.common.exception.ErrorCode;

/** Default when no SMS provider is configured: OTP delivery fails loudly (503). */
public class UnconfiguredSmsSender implements SmsSender {

	@Override
	public void sendOtp(String phoneE164, String code) {
		throw new ApiException(ErrorCode.SMS_UNAVAILABLE, "SMS delivery is not available right now");
	}
}
