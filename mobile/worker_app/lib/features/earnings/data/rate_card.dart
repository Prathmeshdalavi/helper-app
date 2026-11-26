/// Expert levels, lowest first, with their demo pay rates.
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
  final int weekdayHourly;
  final int weekendHourly;

  /// Guaranteed pay for a full 8 hour shift.
  final int weekdayMinimum;
  final int weekendMinimum;

  static ExpertLevel forCoins(int coins) =>
      values.lastWhere((l) => coins >= l.coinsNeeded);

  ExpertLevel? get next => index + 1 < values.length ? values[index + 1] : null;
}
