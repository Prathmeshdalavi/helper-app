/// "₹1,23,456" with Indian digit grouping. Negative values keep the sign first.
String rupees(num value) {
  final n = value.round();
  final digits = n.abs().toString();
  var out = digits;
  if (digits.length > 3) {
    var head = digits.substring(0, digits.length - 3);
    final groups = <String>[];
    while (head.length > 2) {
      groups.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    groups.insert(0, head);
    out = '${groups.join(',')},${digits.substring(digits.length - 3)}';
  }
  return '${n < 0 ? '-' : ''}₹$out';
}

const monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

const weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// "26 Nov".
String shortDate(DateTime d) =>
    '${d.day} ${monthNames[d.month - 1].substring(0, 3)}';

/// "Thu, 26 Nov".
String dayDate(DateTime d) => '${weekdayShort[d.weekday - 1]}, ${shortDate(d)}';
