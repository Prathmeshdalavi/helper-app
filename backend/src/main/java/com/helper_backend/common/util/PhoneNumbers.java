package com.helper_backend.common.util;

/** Indian mobile numbers: the apps send 10 digits, the database stores E.164. */
public final class PhoneNumbers {

	/** 10-digit Indian mobile number (starts with 6-9). */
	public static final String NATIONAL_REGEX = "^[6-9][0-9]{9}$";

	private PhoneNumbers() {
	}

	public static String toE164(String national) {
		return "+91" + national;
	}

	public static String toNational(String e164) {
		return e164.startsWith("+91") ? e164.substring(3) : e164;
	}

	/** For logs only: +91******3210. */
	public static String mask(String e164) {
		if (e164 == null || e164.length() < 4) {
			return "****";
		}
		return e164.substring(0, 3) + "******" + e164.substring(e164.length() - 4);
	}
}
