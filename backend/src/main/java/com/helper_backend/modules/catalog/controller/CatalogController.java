package com.helper_backend.modules.catalog.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.helper_backend.common.api.ApiResponse;
import com.helper_backend.modules.catalog.dto.CategoryResponse;
import com.helper_backend.modules.catalog.service.CatalogService;

/** Requires a valid access token (the customer app shows the catalogue after sign-in). */
@RestController
@RequestMapping("/api/v1/catalog")
public class CatalogController {

	private final CatalogService catalog;

	public CatalogController(CatalogService catalog) {
		this.catalog = catalog;
	}

	@GetMapping("/categories")
	public ApiResponse<List<CategoryResponse>> categories() {
		return ApiResponse.ok(catalog.listCategories());
	}
}
