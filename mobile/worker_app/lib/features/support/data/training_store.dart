import 'package:flutter_riverpod/flutter_riverpod.dart';

class Course {
  const Course(this.id, this.title, this.minutes, this.lessons);

  final String id;
  final String title;
  final int minutes;
  final List<String> lessons;
}

/// TODO(training): load courses and videos from the backend.
const courses = <Course>[
  Course('safety', 'Staying safe at work', 8, [
    'Before you enter a home',
    'Using SOS',
    'Saying no politely',
  ]),
  Course('kitchen', 'A spotless kitchen', 12, [
    'Order of cleaning',
    'Greasy surfaces',
    'Fridge hygiene',
  ]),
  Course('manners', 'Greeting customers', 5, [
    'Your first minute',
    'Asking about preferences',
  ]),
];

/// Number of lessons finished per course id.
class TrainingNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => const {'safety': 2};

  void finishLesson(Course course) {
    final done = state[course.id] ?? 0;
    if (done < course.lessons.length) state = {...state, course.id: done + 1};
  }
}

final trainingProvider = NotifierProvider<TrainingNotifier, Map<String, int>>(
  TrainingNotifier.new,
);
