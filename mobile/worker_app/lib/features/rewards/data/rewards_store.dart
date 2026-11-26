import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreItem {
  const StoreItem(
    this.id,
    this.name,
    this.price,
    this.iconCode, {
    this.soldOut = false,
  });

  final String id;
  final String name;
  final int price;

  /// Which picture to draw for the item.
  final String iconCode;
  final bool soldOut;
}

/// TODO(rewards): load the catalogue from the backend.
const storeItems = <StoreItem>[
  StoreItem('bottle', 'Steel water bottle', 20, 'bottle'),
  StoreItem('bag', 'Work tote bag', 30, 'bag'),
  StoreItem('umbrella', 'Folding umbrella', 45, 'umbrella'),
  StoreItem('apron', 'Pocket apron', 25, 'apron', soldOut: true),
  StoreItem('shoes', 'Comfort shoes', 120, 'shoes'),
  StoreItem('tiffin', 'Lunch box set', 60, 'tiffin', soldOut: true),
];

class RewardsState {
  const RewardsState({this.coins = 42, this.redeemed = const {}});

  /// Coins available to spend.
  final int coins;
  final Set<String> redeemed;
}

class RewardsNotifier extends Notifier<RewardsState> {
  @override
  RewardsState build() => const RewardsState();

  void add(int coins) => state = RewardsState(
    coins: state.coins + coins,
    redeemed: state.redeemed,
  );

  bool redeem(StoreItem item) {
    if (item.soldOut ||
        state.redeemed.contains(item.id) ||
        state.coins < item.price) {
      return false;
    }
    state = RewardsState(
      coins: state.coins - item.price,
      redeemed: {...state.redeemed, item.id},
    );
    return true;
  }
}

final rewardsProvider = NotifierProvider<RewardsNotifier, RewardsState>(
  RewardsNotifier.new,
);
