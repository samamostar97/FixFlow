import 'package:intl/intl.dart';

class DateFormatter {
  static String format(DateTime date) {
    return DateFormat('dd.MM.yyyy.').format(date);
  }

  static String formatWithTime(DateTime date) {
    return DateFormat('dd.MM.yyyy. HH:mm').format(date);
  }

  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Upravo sada';
    if (diff.inMinutes < 60) return 'Prije ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Prije ${diff.inHours}h';
    if (diff.inDays < 7) return 'Prije ${diff.inDays} dana';
    return format(date);
  }
}
