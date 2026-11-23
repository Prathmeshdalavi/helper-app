import 'package:material_ui/material_ui.dart';

/// A service shown as a card on the home screen.
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.title,
    required this.tagline,
    required this.icon,
    required this.tint,
    required this.accent,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.rating,
    this.focus = const Alignment(0, -0.4),
  });

  final String id;
  final String title;

  /// One line under the title.
  final String tagline;
  final IconData icon;

  /// Soft panel colour behind the photo, and a stronger accent.
  final Color tint;
  final Color accent;

  /// Asset path of the card photo.
  final String image;

  /// Rupees; [originalPrice] is shown struck through.
  final int price;
  final int originalPrice;
  final double rating;

  /// Which part of the photo stays in view when it is cropped to the card.
  final Alignment focus;
}
