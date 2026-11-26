import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';
import '../domain/earnings.dart';

class EarningsState {
  const EarningsState({
    required this.month,
    required this.week,
    required this.payouts,
    this.payoutAccount,
    this.hasPan = false,
  });

  /// This month so far.
  final MonthEarnings month;

  /// Pay for each day of this week, Monday first.
  final List<int> week;
  final List<Payout> payouts;

  /// Masked UPI id or bank account, or null while none is linked.
  final String? payoutAccount;
  final bool hasPan;

  /// Share of this month's earnings that can be taken before payday.
  int get earlyLimit {
    final limit = (month.remaining(hasPan) * 0.6).floor();
    return limit < 0 ? 0 : limit - limit % 50;
  }

  EarningsState copyWith({
    MonthEarnings? month,
    List<int>? week,
    List<Payout>? payouts,
    String? payoutAccount,
    bool? hasPan,
  }) => EarningsState(
    month: month ?? this.month,
    week: week ?? this.week,
    payouts: payouts ?? this.payouts,
    payoutAccount: payoutAccount ?? this.payoutAccount,
    hasPan: hasPan ?? this.hasPan,
  );
}

/// TODO(earnings): load from GET /experts/me/earnings.
class EarningsNotifier extends Notifier<EarningsState> {
  @override
  EarningsState build() {
    final today = ref.watch(todayProvider);
    const daily = [640, 720, 580, 810, 690, 920, 760];
    return EarningsState(
      month: const MonthEarnings(
        jobs: 14280,
        incentives: 1150,
        referral: 500,
        tips: 340,
        productCost: 120,
        cashCollected: 600,
        earlyPayout: 0,
      ),
      // Days after today have not happened yet.
      week: [for (var i = 0; i < 7; i++) i < today.weekday ? daily[i] : 0],
      payouts: [
        Payout(
          date: today.subtract(const Duration(days: 12)),
          amount: 8450,
          status: PayoutStatus.paid,
          kind: 'Weekly payout',
        ),
        Payout(
          date: today.subtract(const Duration(days: 19)),
          amount: 7920,
          status: PayoutStatus.paid,
          kind: 'Weekly payout',
        ),
        Payout(
          date: today.subtract(const Duration(days: 24)),
          amount: 1500,
          status: PayoutStatus.failed,
          kind: 'Early payout',
        ),
      ],
    );
  }

  /// Pay for a month [back] months before this one. Only this month changes.
  MonthEarnings monthBack(int back) {
    if (back == 0) return state.month;
    if (back > 3) return MonthEarnings.empty;
    return MonthEarnings(
      jobs: 17900 - back * 1350,
      incentives: 1600 - back * 200,
      referral: back.isEven ? 1000 : 0,
      tips: 520 - back * 60,
      productCost: 150,
      cashCollected: 400,
      earlyPayout: back == 1 ? 2000 : 0,
    );
  }

  void addJob(int pay) {
    final m = state.month;
    final day = ref.read(todayProvider).weekday - 1;
    state = state.copyWith(
      month: MonthEarnings(
        jobs: m.jobs + pay,
        incentives: m.incentives,
        referral: m.referral,
        tips: m.tips,
        productCost: m.productCost,
        cashCollected: m.cashCollected,
        earlyPayout: m.earlyPayout,
      ),
      week: [for (var i = 0; i < 7; i++) state.week[i] + (i == day ? pay : 0)],
    );
  }

  /// Books a shop order against the next payout.
  void addProductCost(int amount) {
    final m = state.month;
    state = state.copyWith(
      month: MonthEarnings(
        jobs: m.jobs,
        incentives: m.incentives,
        referral: m.referral,
        tips: m.tips,
        productCost: m.productCost + amount,
        cashCollected: m.cashCollected,
        earlyPayout: m.earlyPayout,
      ),
    );
  }

  void linkAccount(String masked) =>
      state = state.copyWith(payoutAccount: masked);

  void addPan() => state = state.copyWith(hasPan: true);

  /// Returns false when the amount is over the limit or no account is linked.
  /// TODO(earnings): POST /payouts/early. No money moves in the demo.
  bool withdrawEarly(int amount) {
    if (state.payoutAccount == null ||
        amount <= 0 ||
        amount > state.earlyLimit) {
      return false;
    }
    final m = state.month;
    state = state.copyWith(
      month: MonthEarnings(
        jobs: m.jobs,
        incentives: m.incentives,
        referral: m.referral,
        tips: m.tips,
        productCost: m.productCost,
        cashCollected: m.cashCollected,
        earlyPayout: m.earlyPayout + amount,
      ),
      payouts: [
        Payout(
          date: ref.read(todayProvider),
          amount: amount,
          status: PayoutStatus.processing,
          kind: 'Early payout',
        ),
        ...state.payouts,
      ],
    );
    return true;
  }
}

final earningsProvider = NotifierProvider<EarningsNotifier, EarningsState>(
  EarningsNotifier.new,
);
