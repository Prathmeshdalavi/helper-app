package com.helper_backend.modules.catalog;

import static org.assertj.core.api.Assertions.assertThat;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.support.TransactionTemplate;

import com.helper_backend.config.AppProperties;
import com.helper_backend.modules.catalog.domain.ServiceCategory;
import com.helper_backend.modules.catalog.repository.ServiceCategoryRepository;
import com.jayway.jsonpath.JsonPath;

/**
 * Real-PostgreSQL tests for the catalogue (migrations V3 + V4 are applied by Flyway).
 * Runs only with TEST_DB_URL set to a dedicated test database (name must contain "test").
 * Tests that write do so inside a transaction that is always rolled back.
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@EnabledIfEnvironmentVariable(named = "TEST_DB_URL", matches = ".+")
class CatalogIntegrationTest {

	/** id, title, tagline, price, originalPrice, rating: copied from the Flutter DemoServices.categories. */
	private static final List<Object[]> FRONTEND = List.of(
			new Object[] { "cooking", "Cooking", "Fresh home-style meals", 249, 349, 4.8 },
			new Object[] { "cleaning", "Cleaning", "Floors, kitchen and dusting", 149, 229, 4.9 },
			new Object[] { "baby", "Baby care", "Gentle, trained caregivers", 299, 399, 4.9 },
			new Object[] { "pets", "Pet care", "Walks, play and feeding", 149, 199, 4.8 },
			new Object[] { "elder", "Elder care", "Kind everyday support", 299, 399, 4.9 },
			new Object[] { "laundry", "Laundry", "Wash, dry and fold", 199, 299, 4.8 },
			new Object[] { "full-day", "Full day", "A helper for the whole day", 699, 899, 4.7 },
			new Object[] { "monthly", "Monthly", "Same helper, every visit", 2999, 3999, 4.8 });

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
	@Autowired
	JwtEncoder jwtEncoder;
	@Autowired
	AppProperties props;
	@Autowired
	ServiceCategoryRepository repository;
	@Autowired
	PlatformTransactionManager txManager;

	private String token(String role) {
		Instant now = Instant.now();
		JwtClaimsSet claims = JwtClaimsSet.builder().issuer(props.jwt().issuer())
				.subject(UUID.randomUUID().toString()).issuedAt(now).expiresAt(now.plusSeconds(600))
				.claim("roles", List.of(role)).build();
		return jwtEncoder.encode(JwtEncoderParameters.from(JwsHeader.with(MacAlgorithm.HS256).build(), claims))
				.getTokenValue();
	}

	private MvcResult getCategories(String bearer) throws Exception {
		var req = MockMvcRequestBuilders.get("/api/v1/catalog/categories");
		if (bearer != null) {
			req.header("Authorization", "Bearer " + bearer);
		}
		return mvc.perform(req).andReturn();
	}

	// ------------------------------------------------------------- migrations

	@Test
	void migrationsV1ToV4AreAppliedAndSuccessful() {
		List<Integer> versions = jdbc.queryForList(
				"select version::int from flyway_schema_history where success order by installed_rank", Integer.class);
		assertThat(versions).containsExactly(1, 2, 3, 4);
	}

	@Test
	void theTableHasTheDesignedColumnsConstraintsAndIndex() {
		Map<String, String> types = new LinkedHashMap<>();
		jdbc.query("select column_name, data_type, numeric_precision, numeric_scale from information_schema.columns "
				+ "where table_name = 'service_categories' order by ordinal_position", rs -> {
			types.put(rs.getString("column_name"), rs.getString("data_type")
					+ ("numeric".equals(rs.getString("data_type"))
							? "(" + rs.getInt("numeric_precision") + "," + rs.getInt("numeric_scale") + ")" : ""));
		});
		assertThat(types).containsEntry("id", "uuid").containsEntry("slug", "character varying")
				.containsEntry("price_paise", "integer").containsEntry("original_price_paise", "integer")
				.containsEntry("rating", "numeric(2,1)").containsEntry("display_order", "integer")
				.containsEntry("active", "boolean").containsEntry("created_at", "timestamp with time zone");

		List<String> constraints = jdbc.queryForList("select conname from pg_constraint where conrelid = 'service_categories'::regclass",
				String.class);
		assertThat(constraints).contains("uq_service_categories_slug", "chk_service_categories_slug",
				"chk_service_categories_price", "chk_service_categories_original",
				"chk_service_categories_whole_rupees", "chk_service_categories_rating", "chk_service_categories_order");

		assertThat(jdbc.queryForList("select indexname from pg_indexes where tablename = 'service_categories'", String.class))
				.contains("ix_service_categories_active_order", "uq_service_categories_slug");
	}

	// -------------------------------------------------------------------- API

	@Test
	void theApiReturnsTheEightFrontendCategoriesExactlyAndInOrder() throws Exception {
		MvcResult res = getCategories(token("CUSTOMER"));
		assertThat(res.getResponse().getStatus()).isEqualTo(200);
		String body = res.getResponse().getContentAsString();

		assertThat((Boolean) JsonPath.read(body, "$.success")).isTrue();
		assertThat((List<?>) JsonPath.read(body, "$.data")).hasSize(8);
		for (int i = 0; i < FRONTEND.size(); i++) {
			Object[] e = FRONTEND.get(i);
			String p = "$.data[" + i + "]";
			assertThat((String) JsonPath.read(body, p + ".id")).as("id #" + i).isEqualTo(e[0]);
			assertThat((String) JsonPath.read(body, p + ".title")).as("title #" + i).isEqualTo(e[1]);
			assertThat((String) JsonPath.read(body, p + ".tagline")).as("tagline #" + i).isEqualTo(e[2]);
			assertThat((Object) JsonPath.read(body, p + ".price")).as("price #" + i).isEqualTo(e[3]);
			assertThat((Object) JsonPath.read(body, p + ".originalPrice")).as("originalPrice #" + i).isEqualTo(e[4]);
			assertThat((Object) JsonPath.read(body, p + ".rating")).as("rating #" + i).isEqualTo(e[5]);
		}
	}

	@Test
	void eachCategoryHasExactlySixFieldsWithTheRightJsonTypes() throws Exception {
		String body = getCategories(token("CUSTOMER")).getResponse().getContentAsString();
		Map<String, Object> first = JsonPath.read(body, "$.data[0]");
		assertThat(first.keySet()).containsExactlyInAnyOrder("id", "title", "tagline", "price", "originalPrice", "rating");
		assertThat(first.get("price")).isInstanceOf(Integer.class);
		assertThat(first.get("originalPrice")).isInstanceOf(Integer.class);
		assertThat(first.get("rating")).isInstanceOf(Double.class);
	}

	@Test
	void everyOriginalPriceIsAtLeastThePriceAndPricesArePositive() throws Exception {
		String body = getCategories(token("CUSTOMER")).getResponse().getContentAsString();
		List<Integer> prices = JsonPath.read(body, "$.data[*].price");
		List<Integer> originals = JsonPath.read(body, "$.data[*].originalPrice");
		for (int i = 0; i < prices.size(); i++) {
			assertThat(prices.get(i)).isPositive();
			assertThat(originals.get(i)).isGreaterThanOrEqualTo(prices.get(i));
		}
	}

	@Test
	void anyRoleCanReadButAnonymousAndForgedTokensCannot() throws Exception {
		assertThat(getCategories(token("HELPER")).getResponse().getStatus()).isEqualTo(200);
		assertThat(getCategories(token("ADMIN")).getResponse().getStatus()).isEqualTo(200);
		assertThat(getCategories(null).getResponse().getStatus()).isEqualTo(401);
		assertThat(getCategories("not.a.jwt").getResponse().getStatus()).isEqualTo(401);
	}

	// -------------------------------------------------------------- repository

	@Test
	@Transactional
	void inactiveCategoriesAreHiddenAndOrderFollowsDisplayOrderThenSlug() {
		repository.saveAndFlush(new ServiceCategory("zz-hidden", "Hidden", "t", 100, 200, new BigDecimal("4.0"), 0, false));
		repository.saveAndFlush(new ServiceCategory("zz-first-b", "First B", "t", 100, 200, new BigDecimal("4.0"), 0, true));
		repository.saveAndFlush(new ServiceCategory("zz-first-a", "First A", "t", 100, 200, new BigDecimal("4.0"), 0, true));

		List<String> slugs = repository.findByActiveTrueOrderByDisplayOrderAscSlugAsc().stream()
				.map(ServiceCategory::getSlug).toList();

		assertThat(slugs).doesNotContain("zz-hidden");
		assertThat(slugs.subList(0, 2)).containsExactly("zz-first-a", "zz-first-b");
		assertThat(slugs.subList(2, 10)).containsExactly("cooking", "cleaning", "baby", "pets", "elder", "laundry",
				"full-day", "monthly");
	}

	// ------------------------------------------------------ database constraints

	private static final String INSERT = "insert into service_categories "
			+ "(id, slug, title, tagline, price_paise, original_price_paise, rating, display_order) "
			+ "values (gen_random_uuid(), ?, ?, ?, ?, ?, ?, ?)";

	/** Runs the insert in its own transaction that is ALWAYS rolled back; fails the test if the row is accepted. */
	private void assertRejected(String why, String slug, String title, String tagline, int price, int original,
			String rating, int order) {
		TransactionTemplate tx = new TransactionTemplate(txManager);
		Boolean accepted = tx.execute(status -> {
			status.setRollbackOnly();
			try {
				jdbc.update(INSERT, slug, title, tagline, price, original, new BigDecimal(rating), order);
				return true;
			} catch (DataIntegrityViolationException e) {
				return false;
			}
		});
		assertThat(accepted).as("database should reject: " + why).isFalse();
	}

	@Test
	void theDatabaseRejectsInvalidCategoryRows() {
		assertRejected("negative price", "zz-a", "T", "t", -100, 200, "4.0", 9);
		assertRejected("original below price", "zz-b", "T", "t", 30000, 20000, "4.0", 9);
		assertRejected("rating above 5", "zz-c", "T", "t", 100, 200, "5.1", 9);
		assertRejected("negative rating", "zz-d", "T", "t", 100, 200, "-0.1", 9);
		assertRejected("slug with spaces and capitals", "Bad Slug", "T", "t", 100, 200, "4.0", 9);
		assertRejected("slug with trailing dash", "bad-", "T", "t", 100, 200, "4.0", 9);
		assertRejected("duplicate slug", "cooking", "T", "t", 100, 200, "4.0", 9);
		assertRejected("fractional rupee price", "zz-e", "T", "t", 24950, 34900, "4.0", 9);
		assertRejected("blank title", "zz-f", "  ", "t", 100, 200, "4.0", 9);
		assertRejected("blank tagline", "zz-g", "T", "", 100, 200, "4.0", 9);
		assertRejected("negative display order", "zz-h", "T", "t", 100, 200, "4.0", -1);
	}

	@Test
	void theSeedDataIsUntouchedByTheTests() {
		assertThat(jdbc.queryForObject("select count(*) from service_categories", Integer.class)).isEqualTo(8);
		assertThat(Set.copyOf(jdbc.queryForList("select slug from service_categories", String.class)))
				.containsExactlyInAnyOrder("cooking", "cleaning", "baby", "pets", "elder", "laundry", "full-day", "monthly");
	}
}
