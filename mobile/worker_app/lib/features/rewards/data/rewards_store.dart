import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Coins earned. They set the expert's level and are never spent.
class RewardsNotifier extends Notifier<int> {
  @override
  int build() => 42;

  void add(int coins) => state += coins;
}

final rewardsProvider = NotifierProvider<RewardsNotifier, int>(
  RewardsNotifier.new,
);
