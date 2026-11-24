import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One line in the wallet history.
class WalletEntry {
  const WalletEntry({
    required this.title,
    required this.amount,
    required this.at,
    this.detail,
  });

  final String title;

  /// Positive when money came in, negative when it went out.
  final double amount;
  final DateTime at;
  final String? detail;
}

class WalletState {
  const WalletState({this.cash = 0, this.bonus = 0, this.entries = const []});

  final double cash;
  final double bonus;

  /// Newest first.
  final List<WalletEntry> entries;

  double get balance => cash + bonus;
}

/// The customer's wallet, in memory for now.
/// TODO(wallet): load from and write to the wallet backend.
class WalletNotifier extends Notifier<WalletState> {
  /// Adding at least this much earns a bonus.
  static const bonusThreshold = 500;
  static const bonusRate = 0.05;

  /// The bonus that comes with adding [amount] rupees.
  static int bonusFor(int amount) =>
      amount >= bonusThreshold ? (amount * bonusRate).floor() : 0;

  @override
  WalletState build() => const WalletState();

  void topUp(int amount) {
    final bonus = bonusFor(amount);
    final now = DateTime.now();
    state = WalletState(
      cash: state.cash + amount,
      bonus: state.bonus + bonus,
      entries: [
        if (bonus > 0)
          WalletEntry(
            title: 'Bonus on top-up',
            amount: bonus.toDouble(),
            at: now,
            detail: '5% extra',
          ),
        WalletEntry(
          title: 'Added to wallet',
          amount: amount.toDouble(),
          at: now,
        ),
        ...state.entries,
      ],
    );
  }

  /// Pays [amount] from the wallet, cash first. Returns false if too low.
  bool spend(double amount, String title) {
    if (state.balance + 0.001 < amount) return false;
    final fromCash = amount <= state.cash ? amount : state.cash;
    final fromBonus = amount - fromCash;
    state = WalletState(
      cash: state.cash - fromCash,
      bonus: state.bonus - fromBonus,
      entries: [
        WalletEntry(title: title, amount: -amount, at: DateTime.now()),
        ...state.entries,
      ],
    );
    return true;
  }

  void refund(double amount, String title) {
    state = WalletState(
      cash: state.cash + amount,
      bonus: state.bonus,
      entries: [
        WalletEntry(
          title: title,
          amount: amount,
          at: DateTime.now(),
          detail: 'Instant refund',
        ),
        ...state.entries,
      ],
    );
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);
