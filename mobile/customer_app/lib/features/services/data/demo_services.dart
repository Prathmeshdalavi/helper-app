import 'package:material_ui/material_ui.dart';

import '../domain/service_item.dart';

/// Demo catalogue until the backend catalog module exists.
/// TODO(catalog): replace with GET /catalog/categories.
abstract final class DemoServices {
  static const cooking = ServiceCategory(
    id: 'cooking',
    title: 'Cooking',
    tagline: 'Fresh home-style meals',
    icon: Icons.soup_kitchen_rounded,
    tint: Color(0xFFFFF0D9),
    accent: Color(0xFFE59A2B),
    image: 'assets/images/cooking.jpg',
    price: 249,
    originalPrice: 349,
    rating: 4.8,
  );
  static const cleaning = ServiceCategory(
    id: 'cleaning',
    title: 'Cleaning',
    tagline: 'Floors, kitchen and dusting',
    icon: Icons.cleaning_services_rounded,
    tint: Color(0xFFFCEBE2),
    accent: Color(0xFFEA580C),
    image: 'assets/images/cleaning.jpg',
    price: 149,
    originalPrice: 229,
    rating: 4.9,
    focus: Alignment(0, 0.3),
  );
  static const baby = ServiceCategory(
    id: 'baby',
    title: 'Baby care',
    tagline: 'Gentle, trained caregivers',
    icon: Icons.child_care_rounded,
    tint: Color(0xFFFBE3EA),
    accent: Color(0xFFE5607F),
    image: 'assets/images/baby.jpg',
    price: 299,
    originalPrice: 399,
    rating: 4.9,
  );
  static const pets = ServiceCategory(
    id: 'pets',
    title: 'Pet care',
    tagline: 'Walks, play and feeding',
    icon: Icons.pets_rounded,
    tint: Color(0xFFFFE9D6),
    accent: Color(0xFFD9772B),
    image: 'assets/images/pets.jpg',
    price: 149,
    originalPrice: 199,
    rating: 4.8,
  );
  static const elder = ServiceCategory(
    id: 'elder',
    title: 'Elder care',
    tagline: 'Kind everyday support',
    icon: Icons.elderly_rounded,
    tint: Color(0xFFDCEBFA),
    accent: Color(0xFF3B86D9),
    image: 'assets/images/elder.jpg',
    price: 299,
    originalPrice: 399,
    rating: 4.9,
  );
  static const laundry = ServiceCategory(
    id: 'laundry',
    title: 'Laundry',
    tagline: 'Wash, dry and fold',
    icon: Icons.local_laundry_service_rounded,
    tint: Color(0xFFE3F0F6),
    accent: Color(0xFF3B86A8),
    image: 'assets/images/laundry.jpg',
    price: 199,
    originalPrice: 299,
    rating: 4.8,
  );
  static const fullDay = ServiceCategory(
    id: 'full-day',
    title: 'Full day',
    tagline: 'A helper for the whole day',
    icon: Icons.wb_sunny_rounded,
    tint: Color(0xFFFFF0D9),
    accent: Color(0xFFE59A2B),
    image: 'assets/images/fullday.jpg',
    price: 699,
    originalPrice: 899,
    rating: 4.7,
  );
  static const monthly = ServiceCategory(
    id: 'monthly',
    title: 'Monthly',
    tagline: 'Same helper, every visit',
    icon: Icons.calendar_month_rounded,
    tint: Color(0xFFFCE8DD),
    accent: Color(0xFFED6C29),
    image: 'assets/images/monthly.jpg',
    price: 2999,
    originalPrice: 3999,
    rating: 4.8,
    focus: Alignment(0, -0.1),
  );

  /// The eight service blocks, in display order. The ninth grid block is
  /// "Explore more".
  static const categories = [
    cooking,
    cleaning,
    baby,
    pets,
    elder,
    laundry,
    fullDay,
    monthly,
  ];

  /// Photos shown in the "Explore more" tile, hinting at what else exists.
  static const exploreMosaic = [
    'assets/images/explore_1.jpg',
    'assets/images/explore_2.jpg',
    'assets/images/explore_3.jpg',
  ];
}
