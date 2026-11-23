package com.helper_backend.modules.catalog.dto;

/**
 * Exactly the fields the customer app's ServiceCategory model reads from the server.
 * Prices are whole rupees (the app prints "₹249"); rating has one decimal.
 * Icon, colours, photo and crop focus are UI-only and stay in the app, matched by {@code id}.
 */
public record CategoryResponse(
		String id,
		String title,
		String tagline,
		int price,
		int originalPrice,
		double rating) {
}
