/// One month's pay, built up from its parts.
class MonthEarnings {
  const MonthEarnings({
    required this.jobs,
    required this.incentives,
    required this.referral,
    required this.tips,
    required this.productCost,
    required this.cashCollected,
    required this.earlyPayout,
  });

  final int jobs;
  final int incentives;
  final int referral;
  final int tips;
  final int productCost;
  final int cashCollected;
  final int earlyPayout;

  /// Demo tax cut applied until a PAN card is on file.
  int tax(bool hasPan) =>
      ((jobs + incentives + referral) * (hasPan ? 0.01 : 0.2)).round();

  int total(bool hasPan) =>
      jobs + incentives + referral + tips - productCost - tax(hasPan);

  int remaining(bool hasPan) => total(hasPan) - cashCollected - earlyPayout;

  static const empty = MonthEarnings(
    jobs: 0,
    incentives: 0,
    referral: 0,
    tips: 0,
    productCost: 0,
    cashCollected: 0,
    earlyPayout: 0,
  );
}

enum PayoutStatus { paid, processing, failed }

class Payout {
  const Payout({
    required this.date,
    required this.amount,
    required this.status,
    required this.kind,
  });

  final DateTime date;
  final int amount;
  final PayoutStatus status;
  final String kind;
}
