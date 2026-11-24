import 'package:material_ui/material_ui.dart';

/// Services beyond the eight on Home. Shown under "Explore more".
/// TODO(catalog): replace with GET /catalog/categories.
class ExtraService {
  const ExtraService({
    required this.title,
    required this.tagline,
    required this.icon,
    required this.price,
  });

  final String title;
  final String tagline;
  final IconData icon;

  /// Starting price in rupees for one hour.
  final int price;
}

abstract final class DemoExtraServices {
  static const all = [
    ExtraService(
      title: 'Bathroom cleaning',
      tagline: 'Toilet, sink, mirrors and floor',
      icon: Icons.bathtub_outlined,
      price: 179,
    ),
    ExtraService(
      title: 'Dishwashing',
      tagline: 'Utensils and a clean sink',
      icon: Icons.soup_kitchen_outlined,
      price: 99,
    ),
    ExtraService(
      title: 'Sofa & carpet care',
      tagline: 'Vacuum and spot clean',
      icon: Icons.weekend_outlined,
      price: 249,
    ),
    ExtraService(
      title: 'Garden care',
      tagline: 'Water, trim and tidy plants',
      icon: Icons.yard_outlined,
      price: 199,
    ),
    ExtraService(
      title: 'Window cleaning',
      tagline: 'Interior glass and grills',
      icon: Icons.window_outlined,
      price: 229,
    ),
    ExtraService(
      title: 'Kitchen deep clean',
      tagline: 'Slab, stove, fridge and shelves',
      icon: Icons.kitchen_outlined,
      price: 299,
    ),
    ExtraService(
      title: 'Wardrobe organising',
      tagline: 'Sort, fold and arrange',
      icon: Icons.checkroom_outlined,
      price: 189,
    ),
    ExtraService(
      title: 'Grocery & errands',
      tagline: 'Pick-ups around the neighbourhood',
      icon: Icons.shopping_bag_outlined,
      price: 129,
    ),
  ];
}
