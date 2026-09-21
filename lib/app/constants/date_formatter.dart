import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _display = DateFormat('EEE, d MMM yyyy');
  static final DateFormat _short = DateFormat('d MMM yyyy');

  static String display(DateTime date) => _display.format(date);

  static String short(DateTime date) => _short.format(date);

  static String relative(DateTime date) {
    final now = DateTime.now();
    final due = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final difference = due.difference(today).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference == -1) return 'Yesterday';
    return short(date);
  }
}
