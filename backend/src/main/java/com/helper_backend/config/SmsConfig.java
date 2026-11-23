package com.helper_backend.config;

import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.helper_backend.modules.auth.service.LoggingSmsSender;
import com.helper_backend.modules.auth.service.SmsSender;
import com.helper_backend.modules.auth.service.UnconfiguredSmsSender;

/**
 * Chooses the SMS implementation. Add a real provider here (for example with
 * app.sms.provider=msg91) once credentials and DLT registration exist.
 */
@Configuration
public class SmsConfig {

	@Bean
	@ConditionalOnProperty(name = "app.sms.provider", havingValue = "log")
	SmsSender loggingSmsSender() {
		return new LoggingSmsSender();
	}

	@Bean
	@ConditionalOnMissingBean(SmsSender.class)
	SmsSender unconfiguredSmsSender() {
		return new UnconfiguredSmsSender();
	}
}
