/// The ways coins are earned.
enum CoinSource {
  earlyStart(
    'Early start',
    'Go online before your shift begins to earn 2 coins.',
  ),
  perfectJob('Perfect job', 'A 5 star rating on a job earns 3 coins.'),
  streak('Daily streak', 'Work six days in a row to earn 5 extra coins.');

  const CoinSource(this.title, this.how);

  final String title;
  final String how;
}

/// Demo history for one past day.
/// TODO(rewards): load from GET /experts/me/coins.
Map<CoinSource, int> coinsOn(DateTime day) {
  if (day.weekday == DateTime.sunday || day.day % 7 == 2) return const {};
  return {
    CoinSource.earlyStart: 2,
    if (day.day.isOdd) CoinSource.perfectJob: 3,
    if (day.weekday == DateTime.saturday) CoinSource.streak: 5,
  };
}
