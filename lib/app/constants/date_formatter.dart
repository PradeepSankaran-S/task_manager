import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _display = DateFormat('EEE, d MMM yyyy');
  static final DateFormat _short = DateFormat('d MMM yyyy');

  static String display(DateTime date) => _display.format(date);

  static String short(DateTime date) => _short.format(date);
}
