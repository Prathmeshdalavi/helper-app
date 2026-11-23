package com.helper_backend.modules.catalog.controller;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.jwt;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.context.annotation.Import;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import com.helper_backend.config.AppProperties;
import com.helper_backend.config.CorsConfig;
import com.helper_backend.config.JsonSecurityHandlers;
import com.helper_backend.config.JwtConfig;
import com.helper_backend.config.SecurityConfig;
import com.helper_backend.modules.catalog.dto.CategoryResponse;
import com.helper_backend.modules.catalog.service.CatalogService;

@WebMvcTest(CatalogController.class)
@Import({ SecurityConfig.class, JsonSecurityHandlers.class, JwtConfig.class, CorsConfig.class })
@EnableConfigurationProperties(AppProperties.class)
@TestPropertySource(properties = {
		"app.jwt.secret=test-only-jwt-secret-0123456789-abcdef",
		"app.jwt.issuer=helper-test",
		"app.jwt.access-ttl=15m",
		"app.jwt.refresh-ttl=30d",
		"app.cors.allowed-origins=http://localhost"
})
class CatalogControllerTest {

	@Autowired
	MockMvc mvc;

	@MockitoBean
	CatalogService catalog;

	@Test
	void requiresAnAccessToken() throws Exception {
		mvc.perform(get("/api/v1/catalog/categories"))
				.andExpect(status().isUnauthorized())
				.andExpect(jsonPath("$.success").value(false))
				.andExpect(jsonPath("$.error.code").value("UNAUTHORIZED"));
		verifyNoInteractions(catalog);
	}

	@Test
	void rejectsAGarbageToken() throws Exception {
		mvc.perform(get("/api/v1/catalog/categories").header("Authorization", "Bearer not.a.jwt"))
				.andExpect(status().isUnauthorized());
		verifyNoInteractions(catalog);
	}

	@Test
	void returnsExactlyTheSixFieldsTheAppReadsInOrder() throws Exception {
		when(catalog.listCategories()).thenReturn(List.of(
				new CategoryResponse("cooking", "Cooking", "Fresh home-style meals", 249, 349, 4.8),
				new CategoryResponse("full-day", "Full day", "A helper for the whole day", 699, 899, 4.7)));

		mvc.perform(get("/api/v1/catalog/categories").with(jwt()))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.success").value(true))
				.andExpect(jsonPath("$.data", hasSize(2)))
				.andExpect(jsonPath("$.data[0].id").value("cooking"))
				.andExpect(jsonPath("$.data[0].title").value("Cooking"))
				.andExpect(jsonPath("$.data[0].tagline").value("Fresh home-style meals"))
				.andExpect(jsonPath("$.data[0].price").value(249))
				.andExpect(jsonPath("$.data[0].originalPrice").value(349))
				.andExpect(jsonPath("$.data[0].rating").value(4.8))
				.andExpect(jsonPath("$.data[0].*", hasSize(6)))
				.andExpect(jsonPath("$.data[1].id").value("full-day"));
	}

	@Test
	void pricesAreJsonIntegersNotDecimals() throws Exception {
		when(catalog.listCategories()).thenReturn(List.of(
				new CategoryResponse("monthly", "Monthly", "Same helper, every visit", 2999, 3999, 4.8)));

		String json = mvc.perform(get("/api/v1/catalog/categories").with(jwt()))
				.andReturn().getResponse().getContentAsString();

		org.assertj.core.api.Assertions.assertThat(json)
				.contains("\"price\":2999")
				.contains("\"originalPrice\":3999")
				.contains("\"rating\":4.8")
				.doesNotContain("2999.0");
	}

	@Test
	void anEmptyCatalogueIsAnEmptyArray() throws Exception {
		when(catalog.listCategories()).thenReturn(List.of());

		mvc.perform(get("/api/v1/catalog/categories").with(jwt()))
				.andExpect(status().isOk())
				.andExpect(jsonPath("$.success").value(true))
				.andExpect(jsonPath("$.data", hasSize(0)));
	}

	@Test
	void anyAuthenticatedRoleMayRead() throws Exception {
		when(catalog.listCategories()).thenReturn(List.of());

		for (String role : new String[] { "ROLE_CUSTOMER", "ROLE_HELPER", "ROLE_ADMIN" }) {
			mvc.perform(get("/api/v1/catalog/categories")
					.with(jwt().authorities(new SimpleGrantedAuthority(role))))
					.andExpect(status().isOk());
		}
	}

	@Test
	void aServerFailureIsAnInternalErrorEnvelopeWithoutDetails() throws Exception {
		when(catalog.listCategories()).thenThrow(new IllegalStateException("db password is hunter2"));

		mvc.perform(get("/api/v1/catalog/categories").with(jwt()))
				.andExpect(status().isInternalServerError())
				.andExpect(jsonPath("$.error.code").value("INTERNAL_ERROR"))
				.andExpect(jsonPath("$.error.message").value("Something went wrong"));
	}

	@Test
	void theCatalogueIsReadOnly() throws Exception {
		mvc.perform(post("/api/v1/catalog/categories").with(jwt()).contentType("application/json").content("{}"))
				.andExpect(status().isMethodNotAllowed());
		verifyNoInteractions(catalog);
	}
}
