import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which bottom tab is showing: 0 Home, 1 Bookings, 2 Offers, 3 Account.
class HomeTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void show(int index) => state = index;
}

final homeTabProvider = NotifierProvider<HomeTabNotifier, int>(
  HomeTabNotifier.new,
);
