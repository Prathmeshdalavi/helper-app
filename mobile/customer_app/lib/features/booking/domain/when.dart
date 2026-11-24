const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "9:48 AM".
String clockLabel(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
}

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

/// "Today", "Tomorrow", "Wednesday", or "26 Nov" for dates further out.
String dayLabel(DateTime t, DateTime now) {
  final diff = _day(t).difference(_day(now)).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Tomorrow';
  if (diff > 1 && diff < 7) return _weekdays[t.weekday - 1];
  return '${t.day} ${_months[t.month - 1]}';
}

/// "Tomorrow, 9:00 AM".
String whenLabel(DateTime t, DateTime now) =>
    '${dayLabel(t, now)}, ${clockLabel(t)}';
