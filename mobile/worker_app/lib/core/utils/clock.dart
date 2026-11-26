import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "Today" for all the demo data, so screens and tests agree on the date.
final todayProvider = Provider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});
