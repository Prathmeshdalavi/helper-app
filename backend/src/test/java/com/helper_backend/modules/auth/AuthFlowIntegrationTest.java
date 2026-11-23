package com.helper_backend.modules.auth;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.ThreadLocalRandom;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;

import com.helper_backend.modules.auth.service.SmsSender;
import com.jayway.jsonpath.JsonPath;

/**
 * End-to-end tests against a REAL PostgreSQL database (Flyway migrations are applied).
 *
 * They only run when TEST_DB_URL, TEST_DB_USER and TEST_DB_PASSWORD are set, and refuse
 * to run unless the URL contains "test" so they can never touch the development
 * database. Every test uses fresh random phone numbers and IPs and deletes nothing.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@EnabledIfEnvironmentVariable(named = "TEST_DB_URL", matches = ".+")
class AuthFlowIntegrationTest {

	/** Last OTP "sent" per E.164 phone (captured instead of real SMS). */
	static final Map<String, String> LAST_CODE = new ConcurrentHashMap<>();

	@TestConfiguration
	static class Config {
		@Bean
		@Primary
		SmsSender capturingSmsSender() {
			return (phone, code) -> LAST_CODE.put(phone, code);
		}
	}

	@BeforeAll
	static void onlyAgainstATestDatabase() {
		assertThat(System.getenv("TEST_DB_URL"))
				.as("TEST_DB_URL must point at a dedicated test database (name contains 'test')")
				.containsIgnoringCase("test");
	}

	@Autowired
	MockMvc mvc;

	@Autowired
	JdbcTemplate jdbc;

	// ------------------------------------------------------------------ helpers

	private static String randomPhone() {
		return "9" + String.format("%09d", ThreadLocalRandom.current().nextInt(1_000_000_000));
	}

	private static String randomIp() {
		ThreadLocalRandom r = ThreadLocalRandom.current();
		return "10." + r.nextInt(256) + "." + r.nextInt(256) + "." + r.nextInt(1, 255);
	}

	private MvcResult post(String path, String body, String ip, String bearer) throws Exception {
		MockHttpServletRequestBuilder req = MockMvcRequestBuilders.post(path)
				.contentType(MediaType.APPLICATION_JSON).content(body)
				.with(r -> {
					r.setRemoteAddr(ip);
					return r;
				});
		if (bearer != null) {
			req.header("Authorization", "Bearer " + bearer);
		}
		return mvc.perform(req).andReturn();
	}

	private MvcResult get(String path, String bearer) throws Exception {
		MockHttpServletRequestBuilder req = MockMvcRequestBuilders.get(path);
		if (bearer != null) {
			req.header("Authorization", "Bearer " + bearer);
		}
		return mvc.perform(req).andReturn();
	}

	private static String body(MvcResult r) throws Exception {
		return r.getResponse().getContentAsString();
	}

	private static <T> T read(MvcResult r, String path) throws Exception {
		return JsonPath.read(body(r), path);
	}

	private static String phoneBody(String phone) {
		return "{\"phone\":\"" + phone + "\"}";
	}

	private static String verifyBody(String phone, String otp, String name) {
		return "{\"phone\":\"" + phone + "\",\"otp\":\"" + otp + "\""
				+ (name == null ? "" : ",\"name\":\"" + name + "\"") + "}";
	}

	private String sendOtp(String phone, String ip) throws Exception {
		MvcResult r = post("/api/v1/auth/send-otp", phoneBody(phone), ip, null);
		assertThat(r.getResponse().getStatus()).as(body(r)).isEqualTo(200);
		return LAST_CODE.get("+91" + phone);
	}

	/** Full sign-up. Returns {accessToken, refreshToken}. */
	private String[] signUp(String phone, String ip, String name) throws Exception {
		String code = sendOtp(phone, ip);
		MvcResult r = post("/api/v1/auth/verify-otp", verifyBody(phone, code, name), ip, null);
		assertThat(r.getResponse().getStatus()).as(body(r)).isEqualTo(200);
		return new String[] { read(r, "$.data.accessToken"), read(r, "$.data.refreshToken") };
	}

	private int userCount(String phone) {
		return jdbc.queryForObject("select count(*) from users where phone_e164 = ?", Integer.class, "+91" + phone);
	}

	private static String wrongCode(String right) {
		return right.equals("0000") ? "1111" : "0000";
	}

	// -------------------------------------------------------------------- tests

	@Test
	void signUpCreatesTheAccountAndMeReturnsIt() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();

		MvcResult before = post("/api/v1/auth/check-phone", phoneBody(phone), ip, null);
		assertThat((Boolean) read(before, "$.data.registered")).isFalse();

		String code = sendOtp(phone, ip);
		MvcResult res = post("/api/v1/auth/verify-otp", verifyBody(phone, code, "Priya Sharma"), ip, null);

		assertThat(res.getResponse().getStatus()).as(body(res)).isEqualTo(200);
		assertThat((Boolean) read(res, "$.data.isNewUser")).isTrue();
		assertThat((String) read(res, "$.data.tokenType")).isEqualTo("Bearer");
		assertThat((String) read(res, "$.data.user.phone")).isEqualTo(phone);
		assertThat(userCount(phone)).isEqualTo(1);

		String access = read(res, "$.data.accessToken");
		MvcResult me = get("/api/v1/users/me", access);
		assertThat(me.getResponse().getStatus()).isEqualTo(200);
		assertThat((String) read(me, "$.data.name")).isEqualTo("Priya Sharma");
		assertThat((String) read(me, "$.data.phone")).isEqualTo(phone);

		MvcResult after = post("/api/v1/auth/check-phone", phoneBody(phone), ip, null);
		assertThat((Boolean) read(after, "$.data.registered")).isTrue();
		assertThat(body(after)).doesNotContain("Priya");
	}

	@Test
	void theOtpIsNeverStoredInThePlain() throws Exception {
		String phone = randomPhone();
		String code = sendOtp(phone, randomIp());

		String stored = jdbc.queryForObject(
				"select code_hash from otp_challenges where phone_e164 = ? and status = 'ACTIVE'",
				String.class, "+91" + phone);
		assertThat(stored).hasSize(64).isNotEqualTo(code).doesNotContain(code);
	}

	@Test
	void existingUsersSignInAndTheirNameIsNeverOverwritten() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();
		signUp(phone, ip, "Anita Rao");

		String code = sendOtp(phone, ip);
		MvcResult res = post("/api/v1/auth/verify-otp", verifyBody(phone, code, "Someone Else"), ip, null);

		assertThat(res.getResponse().getStatus()).as(body(res)).isEqualTo(200);
		assertThat((Boolean) read(res, "$.data.isNewUser")).isFalse();
		assertThat((String) read(res, "$.data.user.name")).isEqualTo("Anita Rao");
		assertThat(userCount(phone)).isEqualTo(1);
	}

	@Test
	void signUpNeedsAValidNameAndKeepsTheOtpUsable() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();
		String code = sendOtp(phone, ip);

		MvcResult noName = post("/api/v1/auth/verify-otp", verifyBody(phone, code, null), ip, null);
		assertThat(noName.getResponse().getStatus()).isEqualTo(400);
		assertThat((String) read(noName, "$.error.code")).isEqualTo("VALIDATION_FAILED");
		assertThat(userCount(phone)).isZero();

		MvcResult ok = post("/api/v1/auth/verify-otp", verifyBody(phone, code, "Priya Sharma"), ip, null);
		assertThat(ok.getResponse().getStatus()).as(body(ok)).isEqualTo(200);
	}

	@Test
	void fiveWrongAttemptsLockTheChallengeAndTheRightCodeStopsWorking() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();
		String code = sendOtp(phone, ip);
		String bad = wrongCode(code);

		for (int i = 1; i <= 4; i++) {
			MvcResult r = post("/api/v1/auth/verify-otp", verifyBody(phone, bad, "Priya Sharma"), ip, null);
			assertThat(r.getResponse().getStatus()).isEqualTo(400);
			assertThat((String) read(r, "$.error.code")).isEqualTo("OTP_INVALID");
			assertThat((String) read(r, "$.error.details.remainingAttempts")).isEqualTo(String.valueOf(5 - i));
		}
		MvcResult fifth = post("/api/v1/auth/verify-otp", verifyBody(phone, bad, "Priya Sharma"), ip, null);
		assertThat(fifth.getResponse().getStatus()).isEqualTo(429);
		assertThat((String) read(fifth, "$.error.code")).isEqualTo("OTP_LOCKED");

		MvcResult right = post("/api/v1/auth/verify-otp", verifyBody(phone, code, "Priya Sharma"), ip, null);
		assertThat(right.getResponse().getStatus()).isEqualTo(400);
		assertThat(userCount(phone)).isZero();
	}

	@Test
	void anOtpWorksOnlyOnce() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();
		String code = sendOtp(phone, ip);

		assertThat(post("/api/v1/auth/verify-otp", verifyBody(phone, code, "Priya Sharma"), ip, null)
				.getResponse().getStatus()).isEqualTo(200);
		MvcResult replay = post("/api/v1/auth/verify-otp", verifyBody(phone, code, "Priya Sharma"), ip, null);
		assertThat(replay.getResponse().getStatus()).isEqualTo(400);
		assertThat((String) read(replay, "$.error.code")).isEqualTo("OTP_EXPIRED");
	}

	@Test
	void anExpiredOtpIsRejected() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();
		String code = sendOtp(phone, ip);
		jdbc.update("update otp_challenges set expires_at = now() - interval '1 minute' "
				+ "where phone_e164 = ? and status = 'ACTIVE'", "+91" + phone);

		MvcResult r = post("/api/v1/auth/verify-otp", verifyBody(phone, code, "Priya Sharma"), ip, null);
		assertThat(r.getResponse().getStatus()).isEqualTo(400);
		assertThat((String) read(r, "$.error.code")).isEqualTo("OTP_EXPIRED");
		assertThat(userCount(phone)).isZero();
	}

	@Test
	void requestingANewOtpLeavesExactlyOneActiveChallenge() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();
		sendOtp(phone, ip);
		sendOtp(phone, ip);

		Integer active = jdbc.queryForObject(
				"select count(*) from otp_challenges where phone_e164 = ? and status = 'ACTIVE'",
				Integer.class, "+91" + phone);
		assertThat(active).isEqualTo(1);
	}

	@Test
	void sendOtpIsRateLimitedPerPhone() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();
		for (int i = 0; i < 5; i++) {
			assertThat(post("/api/v1/auth/send-otp", phoneBody(phone), ip, null).getResponse().getStatus())
					.isEqualTo(200);
		}
		MvcResult sixth = post("/api/v1/auth/send-otp", phoneBody(phone), ip, null);
		assertThat(sixth.getResponse().getStatus()).isEqualTo(429);
		assertThat((String) read(sixth, "$.error.code")).isEqualTo("RATE_LIMITED");
	}

	@Test
	void refreshRotatesAndReuseKillsTheWholeLogin() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();
		String[] first = signUp(phone, ip, "Priya Sharma");

		MvcResult rotated = post("/api/v1/auth/refresh", "{\"refreshToken\":\"" + first[1] + "\"}", ip, null);
		assertThat(rotated.getResponse().getStatus()).as(body(rotated)).isEqualTo(200);
		String second = read(rotated, "$.data.refreshToken");
		assertThat(second).isNotEqualTo(first[1]);

		// Replaying the retired token is treated as theft...
		MvcResult replay = post("/api/v1/auth/refresh", "{\"refreshToken\":\"" + first[1] + "\"}", ip, null);
		assertThat(replay.getResponse().getStatus()).isEqualTo(401);

		// ...so even the newest token of that login is now dead.
		MvcResult newest = post("/api/v1/auth/refresh", "{\"refreshToken\":\"" + second + "\"}", ip, null);
		assertThat(newest.getResponse().getStatus()).isEqualTo(401);
	}

	@Test
	void logoutEndsOnlyTheCallersOwnSession() throws Exception {
		String ip = randomIp();
		String[] alice = signUp(randomPhone(), ip, "Alice Roy");
		String[] bob = signUp(randomPhone(), ip, "Bob Roy");

		// Bob presents Alice's refresh token: accepted silently, but changes nothing.
		MvcResult cross = post("/api/v1/auth/logout", "{\"refreshToken\":\"" + alice[1] + "\"}", ip, bob[0]);
		assertThat(cross.getResponse().getStatus()).isEqualTo(200);
		assertThat(post("/api/v1/auth/refresh", "{\"refreshToken\":\"" + alice[1] + "\"}", ip, null)
				.getResponse().getStatus()).isEqualTo(200);

		// Bob logs out his own session: his refresh token stops working.
		assertThat(post("/api/v1/auth/logout", "{\"refreshToken\":\"" + bob[1] + "\"}", ip, bob[0])
				.getResponse().getStatus()).isEqualTo(200);
		assertThat(post("/api/v1/auth/refresh", "{\"refreshToken\":\"" + bob[1] + "\"}", ip, null)
				.getResponse().getStatus()).isEqualTo(401);
	}

	@Test
	void logoutAndMeRequireAnAccessToken() throws Exception {
		assertThat(get("/api/v1/users/me", null).getResponse().getStatus()).isEqualTo(401);
		assertThat(post("/api/v1/auth/logout", "{\"refreshToken\":\"x\"}", randomIp(), null)
				.getResponse().getStatus()).isEqualTo(401);
	}

	@Test
	void concurrentVerificationsOfOneOtpProduceExactlyOneAccountAndOneSuccess() throws Exception {
		String phone = randomPhone();
		String ip = randomIp();
		String code = sendOtp(phone, ip);

		int threads = 8;
		ExecutorService pool = Executors.newFixedThreadPool(threads);
		CountDownLatch go = new CountDownLatch(1);
		List<Future<Integer>> results = new ArrayList<>();
		for (int i = 0; i < threads; i++) {
			Callable<Integer> task = () -> {
				go.await();
				return post("/api/v1/auth/verify-otp", verifyBody(phone, code, "Priya Sharma"), ip, null)
						.getResponse().getStatus();
			};
			results.add(pool.submit(task));
		}
		go.countDown();

		int ok = 0;
		for (Future<Integer> f : results) {
			int status = f.get();
			if (status == 200) {
				ok++;
			} else {
				assertThat(status).isIn(400, 409, 429);
			}
		}
		pool.shutdown();

		assertThat(ok).isEqualTo(1);
		assertThat(userCount(phone)).isEqualTo(1);
	}
}
