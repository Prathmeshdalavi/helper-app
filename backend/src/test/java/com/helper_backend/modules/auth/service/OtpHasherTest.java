package com.helper_backend.modules.auth.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Duration;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.helper_backend.TestData;
import com.helper_backend.config.AppProperties;

class OtpHasherTest {

	private final OtpHasher hasher = new OtpHasher(TestData.props());

	@Test
	void hashIsDeterministicAndDoesNotContainTheCode() {
		String h1 = hasher.hash("+919876543210", "1234");
		String h2 = hasher.hash("+919876543210", "1234");
		assertThat(h1).isEqualTo(h2).hasSize(64).doesNotContain("1234");
	}

	@Test
	void hashDependsOnPhoneAndCode() {
		String base = hasher.hash("+919876543210", "1234");
		assertThat(hasher.hash("+919876543211", "1234")).isNotEqualTo(base);
		assertThat(hasher.hash("+919876543210", "1235")).isNotEqualTo(base);
	}

	@Test
	void matchesOnlyTheRightCode() {
		String stored = hasher.hash("+919876543210", "4821");
		assertThat(hasher.matches("+919876543210", "4821", stored)).isTrue();
		assertThat(hasher.matches("+919876543210", "4822", stored)).isFalse();
		assertThat(hasher.matches("+919876543299", "4821", stored)).isFalse();
	}

	@Test
	void differentPepperGivesDifferentHash() {
		AppProperties other = new AppProperties(null, null,
				new AppProperties.Otp(Duration.ofMinutes(5), 5, Duration.ofSeconds(15),
						"another-test-only-pepper-0123456789-abcdef"),
				new AppProperties.Sms("none"));
		assertThat(new OtpHasher(other).hash("+919876543210", "1234"))
				.isNotEqualTo(hasher.hash("+919876543210", "1234"));
	}

	@Test
	void refusesMissingOrShortPepper() {
		AppProperties shortPepper = new AppProperties(null, new AppProperties.Cors(List.of()),
				new AppProperties.Otp(Duration.ofMinutes(5), 5, Duration.ofSeconds(15), "short"),
				new AppProperties.Sms("none"));
		assertThatThrownBy(() -> new OtpHasher(shortPepper)).isInstanceOf(IllegalStateException.class);

		AppProperties noPepper = new AppProperties(null, null,
				new AppProperties.Otp(Duration.ofMinutes(5), 5, Duration.ofSeconds(15), null),
				new AppProperties.Sms("none"));
		assertThatThrownBy(() -> new OtpHasher(noPepper)).isInstanceOf(IllegalStateException.class);
	}
}
