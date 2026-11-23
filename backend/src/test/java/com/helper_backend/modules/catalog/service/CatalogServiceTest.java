package com.helper_backend.modules.catalog.service;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

import java.math.BigDecimal;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.helper_backend.modules.catalog.domain.ServiceCategory;
import com.helper_backend.modules.catalog.dto.CategoryResponse;
import com.helper_backend.modules.catalog.repository.ServiceCategoryRepository;

class CatalogServiceTest {

	private final ServiceCategoryRepository repo = mock(ServiceCategoryRepository.class);
	private final CatalogService service = new CatalogService(repo);

	private static ServiceCategory category(String slug, String title, String tagline, int pricePaise,
			int originalPaise, String rating, int order) {
		return new ServiceCategory(slug, title, tagline, pricePaise, originalPaise, new BigDecimal(rating), order, true);
	}

	@Test
	void convertsPaiseToWholeRupeesAndMapsEveryField() {
		when(repo.findByActiveTrueOrderByDisplayOrderAscSlugAsc()).thenReturn(List.of(
				category("cooking", "Cooking", "Fresh home-style meals", 24900, 34900, "4.8", 1)));

		List<CategoryResponse> result = service.listCategories();

		assertThat(result).containsExactly(
				new CategoryResponse("cooking", "Cooking", "Fresh home-style meals", 249, 349, 4.8));
	}

	@Test
	void handlesTheLargestFrontendPriceAndLowestRating() {
		when(repo.findByActiveTrueOrderByDisplayOrderAscSlugAsc()).thenReturn(List.of(
				category("monthly", "Monthly", "Same helper, every visit", 299900, 399900, "4.8", 8),
				category("full-day", "Full day", "A helper for the whole day", 69900, 89900, "4.7", 7)));

		assertThat(service.listCategories()).extracting(CategoryResponse::price, CategoryResponse::originalPrice, CategoryResponse::rating)
				.containsExactly(
						org.assertj.core.groups.Tuple.tuple(2999, 3999, 4.8),
						org.assertj.core.groups.Tuple.tuple(699, 899, 4.7));
	}

	@Test
	void keepsTheOrderTheRepositoryReturns() {
		when(repo.findByActiveTrueOrderByDisplayOrderAscSlugAsc()).thenReturn(List.of(
				category("a", "A", "t", 100, 200, "4.0", 1),
				category("b", "B", "t", 100, 200, "4.0", 2),
				category("c", "C", "t", 100, 200, "4.0", 3)));

		assertThat(service.listCategories()).extracting(CategoryResponse::id).containsExactly("a", "b", "c");
	}

	@Test
	void usesOnlyTheActiveOrderedQuery() {
		when(repo.findByActiveTrueOrderByDisplayOrderAscSlugAsc()).thenReturn(List.of());

		service.listCategories();

		verify(repo).findByActiveTrueOrderByDisplayOrderAscSlugAsc();
		verifyNoMoreInteractions(repo);
	}

	@Test
	void anEmptyCatalogueIsAnEmptyListNotAnError() {
		when(repo.findByActiveTrueOrderByDisplayOrderAscSlugAsc()).thenReturn(List.of());
		assertThat(service.listCategories()).isEmpty();
	}

	@Test
	void aFractionalRupeeAmountFailsLoudlyInsteadOfBeingTruncated() {
		when(repo.findByActiveTrueOrderByDisplayOrderAscSlugAsc()).thenReturn(List.of(
				category("odd", "Odd", "t", 24950, 34900, "4.0", 1)));

		assertThatThrownBy(service::listCategories).isInstanceOf(IllegalStateException.class)
				.hasMessageContaining("24950");
	}

	@Test
	void ratingKeepsOneDecimalWithoutFloatingPointNoise() {
		when(repo.findByActiveTrueOrderByDisplayOrderAscSlugAsc()).thenReturn(List.of(
				category("x", "X", "t", 100, 200, "4.9", 1), category("y", "Y", "t", 100, 200, "5.0", 2),
				category("z", "Z", "t", 100, 200, "0.0", 3)));

		assertThat(service.listCategories()).extracting(CategoryResponse::rating).containsExactly(4.9, 5.0, 0.0);
	}
}
