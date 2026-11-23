package com.helper_backend.modules.catalog.service;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.helper_backend.modules.catalog.domain.ServiceCategory;
import com.helper_backend.modules.catalog.dto.CategoryResponse;
import com.helper_backend.modules.catalog.repository.ServiceCategoryRepository;

@Service
public class CatalogService {

	private final ServiceCategoryRepository categories;

	public CatalogService(ServiceCategoryRepository categories) {
		this.categories = categories;
	}

	/** Active categories in display order. An empty catalogue is a valid, empty list. */
	@Transactional(readOnly = true)
	public List<CategoryResponse> listCategories() {
		return categories.findByActiveTrueOrderByDisplayOrderAscSlugAsc().stream()
				.map(CatalogService::toResponse)
				.toList();
	}

	static CategoryResponse toResponse(ServiceCategory c) {
		return new CategoryResponse(
				c.getSlug(),
				c.getTitle(),
				c.getTagline(),
				rupees(c.getPricePaise()),
				rupees(c.getOriginalPricePaise()),
				c.getRating().doubleValue());
	}

	/** The app shows whole rupees. The database enforces whole-rupee amounts; fail loudly if that ever breaks. */
	static int rupees(int paise) {
		if (paise % 100 != 0) {
			throw new IllegalStateException("Category price is not a whole number of rupees: " + paise + " paise");
		}
		return paise / 100;
	}
}
