/// Expert levels, lowest first, with their sample pay rates.
enum ExpertLevel {
  seed('Seed', 0, 120, 140, 450, 550),
  bloom('Bloom', 15, 130, 150, 500, 600),
  shine('Shine', 60, 140, 160, 550, 660),
  star('Star', 150, 155, 175, 600, 720);

  const ExpertLevel(
    this.label,
    this.coinsNeeded,
    this.weekdayHourly,
    this.weekendHourly,
    this.weekdayMinimum,
    this.weekendMinimum,
  );

  final String label;
  final int coinsNeeded;

  /// Lowest hourly total, bonuses included.
  final int weekdayHourly;
  final int weekendHourly;

  /// Guaranteed pay for a full 8 hour shift.
  final int weekdayMinimum;
  final int weekendMinimum;

  /// The parts added on top of the work rate.
  static const checkInBonus = 10;
  static const distanceMin = 5;
  static const distanceMax = 25;
  static const rainBonus = 10;

  int get weekdayWork => weekdayHourly - checkInBonus - distanceMin - rainBonus;
  int get weekendWork => weekendHourly - checkInBonus - distanceMin - rainBonus;

  static ExpertLevel forCoins(int coins) =>
      values.lastWhere((l) => coins >= l.coinsNeeded);

  ExpertLevel? get next => index + 1 < values.length ? values[index + 1] : null;
}
