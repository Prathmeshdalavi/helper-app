import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/clock.dart';

class Leave {
  Leave({
    required this.date,
    DateTime? until,
    required this.reason,
    required this.approved,
  }) : until = until ?? date;

  /// First and last day, both included.
  final DateTime date;
  final DateTime until;
  final String reason;
  final bool approved;

  bool covers(DateTime day) => !day.isBefore(date) && !day.isAfter(until);
}

class ShiftState {
  const ShiftState({
    this.tomorrowPresent,
    this.leaves = const [],
    this.overtime = const {},
    this.loggedOutEarly = false,
  });

  /// Null until the expert answers for tomorrow.
  final bool? tomorrowPresent;
  final List<Leave> leaves;

  /// Ids of the overtime slots taken.
  final Set<String> overtime;
  final bool loggedOutEarly;

  ShiftState copyWith({
    bool? tomorrowPresent,
    List<Leave>? leaves,
    Set<String>? overtime,
    bool? loggedOutEarly,
  }) => ShiftState(
    tomorrowPresent: tomorrowPresent ?? this.tomorrowPresent,
    leaves: leaves ?? this.leaves,
    overtime: overtime ?? this.overtime,
    loggedOutEarly: loggedOutEarly ?? this.loggedOutEarly,
  );
}

/// TODO(shifts): sync with the scheduling service.
class ShiftNotifier extends Notifier<ShiftState> {
  /// Days of care leave allowed each month.
  static const careLeavePerMonth = 1;
  static const careLeaveReason = 'Period leave';

  @override
  ShiftState build() {
    final today = ref.watch(todayProvider);
    return ShiftState(
      leaves: [
        Leave(
          date: today.subtract(const Duration(days: 37)),
          reason: 'Family function',
          approved: true,
        ),
      ],
    );
  }

  void markTomorrow(bool present) =>
      state = state.copyWith(tomorrowPresent: present);

  /// Returns an error message, or null when the leave was added.
  String? applyLeave(DateTime from, DateTime to, String reason) {
    if (to.isBefore(from)) return 'The end date is before the start date';
    if (state.leaves.any(
      (l) => !to.isBefore(l.date) && !from.isAfter(l.until),
    )) {
      return 'You already have leave on those days';
    }
    if (reason == careLeaveReason) {
      if (from != to) return 'Period leave is one day at a time';
      if (careLeaveUsed(from) >= careLeavePerMonth) {
        return 'Period leave for that month is used';
      }
    }
    state = state.copyWith(
      leaves: [
        Leave(
          date: from,
          until: to,
          reason: reason,
          approved: reason == careLeaveReason,
        ),
        ...state.leaves,
      ],
    );
    return null;
  }

  int careLeaveUsed(DateTime month) => state.leaves
      .where(
        (l) =>
            l.reason == careLeaveReason &&
            l.date.year == month.year &&
            l.date.month == month.month,
      )
      .length;

  void toggleOvertime(String id) => state = state.copyWith(
    overtime: state.overtime.contains(id)
        ? ({...state.overtime}..remove(id))
        : {...state.overtime, id},
  );

  void logOutEarly() => state = state.copyWith(loggedOutEarly: true);
}

final shiftProvider = NotifierProvider<ShiftNotifier, ShiftState>(
  ShiftNotifier.new,
);
