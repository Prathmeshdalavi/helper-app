import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bottom tabs of the signed-in app, in order.
enum HomeTabId { home, earnings, refer, updates, profile }

class HomeTabNotifier extends Notifier<HomeTabId> {
  @override
  HomeTabId build() => HomeTabId.home;

  void show(HomeTabId tab) => state = tab;
}

final homeTabProvider = NotifierProvider<HomeTabNotifier, HomeTabId>(
  HomeTabNotifier.new,
);
