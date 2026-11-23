package com.helper_backend.modules.catalog.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;

import com.helper_backend.modules.catalog.domain.ServiceCategory;

public interface ServiceCategoryRepository extends JpaRepository<ServiceCategory, UUID> {

	/** Active categories in display order; slug breaks ties so the order is always deterministic. */
	List<ServiceCategory> findByActiveTrueOrderByDisplayOrderAscSlugAsc();
}
