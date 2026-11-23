package com.helper_backend.modules.auth.service;

import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.stereotype.Component;

import com.helper_backend.config.AppProperties;

/**
 * Keyed hash (HMAC-SHA256) of phone + code. With only 4 digits a plain hash could be
 * reversed instantly if the table leaked; the secret pepper (env OTP_PEPPER) prevents that.
 */
@Component
public class OtpHasher {

	private static final int MIN_PEPPER_BYTES = 32;

	private final SecretKeySpec key;

	public OtpHasher(AppProperties props) {
		String pepper = props.otp() == null ? null : props.otp().pepper();
		if (pepper == null || pepper.getBytes(StandardCharsets.UTF_8).length < MIN_PEPPER_BYTES) {
			throw new IllegalStateException(
					"app.otp.pepper (env OTP_PEPPER) must be set and at least 32 bytes long");
		}
		this.key = new SecretKeySpec(pepper.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
	}

	public String hash(String phoneE164, String code) {
		try {
			Mac mac = Mac.getInstance("HmacSHA256");
			mac.init(key);
			byte[] out = mac.doFinal((phoneE164 + ":" + code).getBytes(StandardCharsets.UTF_8));
			return HexFormat.of().formatHex(out);
		} catch (NoSuchAlgorithmException | InvalidKeyException e) {
			throw new IllegalStateException("HMAC-SHA256 unavailable", e);
		}
	}

	/** Constant-time comparison. */
	public boolean matches(String phoneE164, String code, String expectedHash) {
		return MessageDigest.isEqual(
				hash(phoneE164, code).getBytes(StandardCharsets.UTF_8),
				expectedHash.getBytes(StandardCharsets.UTF_8));
	}
}
