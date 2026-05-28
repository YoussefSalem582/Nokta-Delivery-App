import 'package:easy_localization/easy_localization.dart';

/// Formats [dateTime] as a 12-hour clock with AM/PM (locale-aware).
String formatAppClockTime(DateTime dateTime, {String? locale}) {
  final resolvedLocale = locale ?? Intl.getCurrentLocale();
  return DateFormat('h:mm a', resolvedLocale).format(dateTime);
}

/// Formats a trip/notification timestamp with relative day labels and 12-hour time.
String formatTripDate(DateTime date, {String? locale}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tripDay = DateTime(date.year, date.month, date.day);
  final time = formatAppClockTime(date, locale: locale);

  if (tripDay == today) return '${'today'.tr()}, $time';
  if (tripDay == today.subtract(const Duration(days: 1))) {
    return '${'yesterday'.tr()}, $time';
  }

  final resolvedLocale = locale ?? Intl.getCurrentLocale();
  return DateFormat('MMM d, y • h:mm a', resolvedLocale).format(date);
}

/// Formats a calendar date with 12-hour time (e.g. order details).
String formatAppDateTime(DateTime dateTime, {String? locale}) {
  final resolvedLocale = locale ?? Intl.getCurrentLocale();
  return DateFormat.yMMMd(resolvedLocale).add_jm().format(dateTime);
}
