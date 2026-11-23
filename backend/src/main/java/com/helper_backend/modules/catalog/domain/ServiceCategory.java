package com.helper_backend.modules.catalog.domain;

import java.math.BigDecimal;

import com.helper_backend.common.persistence.BaseEntity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

/** A service category card on the customer app home screen. Read-only in M2. */
@Entity
@Table(name = "service_categories")
public class ServiceCategory extends BaseEntity {

	@Column(name = "slug", nullable = false, updatable = false, length = 40)
	private String slug;

	@Column(name = "title", nullable = false, length = 80)
	private String title;

	@Column(name = "tagline", nullable = false, length = 160)
	private String tagline;

	@Column(name = "price_paise", nullable = false)
	private int pricePaise;

	@Column(name = "original_price_paise", nullable = false)
	private int originalPricePaise;

	@Column(name = "rating", nullable = false, precision = 2, scale = 1)
	private BigDecimal rating;

	@Column(name = "display_order", nullable = false)
	private int displayOrder;

	@Column(name = "active", nullable = false)
	private boolean active;

	protected ServiceCategory() {
	}

	public ServiceCategory(String slug, String title, String tagline, int pricePaise, int originalPricePaise,
			BigDecimal rating, int displayOrder, boolean active) {
		this.slug = slug;
		this.title = title;
		this.tagline = tagline;
		this.pricePaise = pricePaise;
		this.originalPricePaise = originalPricePaise;
		this.rating = rating;
		this.displayOrder = displayOrder;
		this.active = active;
	}

	public String getSlug() {
		return slug;
	}

	public String getTitle() {
		return title;
	}

	public String getTagline() {
		return tagline;
	}

	public int getPricePaise() {
		return pricePaise;
	}

	public int getOriginalPricePaise() {
		return originalPricePaise;
	}

	public BigDecimal getRating() {
		return rating;
	}

	public int getDisplayOrder() {
		return displayOrder;
	}

	public boolean isActive() {
		return active;
	}
}
