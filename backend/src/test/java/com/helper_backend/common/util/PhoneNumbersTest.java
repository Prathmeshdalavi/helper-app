package com.helper_backend.common.util;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class PhoneNumbersTest {

	@Test
	void convertsBetweenNationalAndE164() {
		assertThat(PhoneNumbers.toE164("9876543210")).isEqualTo("+919876543210");
		assertThat(PhoneNumbers.toNational("+919876543210")).isEqualTo("9876543210");
	}

	@Test
	void nationalRegexAcceptsOnlyIndianMobileShapes() {
		assertThat("9876543210").matches(PhoneNumbers.NATIONAL_REGEX);
		assertThat("6000000000").matches(PhoneNumbers.NATIONAL_REGEX);
		assertThat("5876543210").doesNotMatch(PhoneNumbers.NATIONAL_REGEX);
		assertThat("987654321").doesNotMatch(PhoneNumbers.NATIONAL_REGEX);
		assertThat("98765432100").doesNotMatch(PhoneNumbers.NATIONAL_REGEX);
		assertThat("98765abcde").doesNotMatch(PhoneNumbers.NATIONAL_REGEX);
	}

	@Test
	void maskHidesTheMiddleDigits() {
		assertThat(PhoneNumbers.mask("+919876543210")).isEqualTo("+91******3210").doesNotContain("98765");
	}
}
