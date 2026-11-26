/// One month of customer ratings.
class MonthRating {
  const MonthRating({
    required this.counts,
    required this.loved,
    required this.advice,
  });

  /// Number of jobs rated 5, 4, 3, 2 and 1 stars, in that order.
  final List<int> counts;

  /// Compliments customers picked most.
  final List<String> loved;
  final String advice;

  int get rated => counts.fold(0, (a, b) => a + b);

  double get average {
    if (rated == 0) return 0;
    var sum = 0;
    for (var i = 0; i < counts.length; i++) {
      sum += counts[i] * (5 - i);
    }
    return sum / rated;
  }
}

/// This month first. TODO(ratings): load from GET /experts/me/ratings.
const monthRatings = <MonthRating>[
  MonthRating(
    counts: [22, 4, 1, 0, 0],
    loved: ['Neat work', 'On time', 'Polite'],
    advice: 'You are doing well. Show the customer your work before you leave.',
  ),
  MonthRating(
    counts: [31, 8, 2, 1, 0],
    loved: ['Careful', 'Friendly'],
    advice: 'Start travelling a little earlier to reach on time.',
  ),
  MonthRating(
    counts: [27, 9, 4, 1, 0],
    loved: ['Hard working'],
    advice: 'Wear your apron and tie your hair before you ring the bell.',
  ),
  MonthRating(
    counts: [18, 5, 1, 0, 0],
    loved: ['Quick learner'],
    advice: 'Ask which areas matter most before you begin.',
  ),
];
