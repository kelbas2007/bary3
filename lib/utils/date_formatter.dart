import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// Утилита для локализованного форматирования дат
class LocalizedDateFormatter {
  /// Форматирует дату в формате dd.MM.yyyy с учетом локали
  static String formatDateShort(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    return DateFormat.yMd(locale.toString()).format(date);
  }

  /// Форматирует дату в формате dd MMMM yyyy с учетом локали
  static String formatDateLong(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    return DateFormat.yMMMMd(locale.toString()).format(date);
  }

  /// Форматирует дату и время с учетом локали
  static String formatDateTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context);
    return DateFormat.yMd(locale.toString()).add_jm().format(dateTime);
  }

  /// Форматирует только время
  static String formatTime(BuildContext context, TimeOfDay time) {
    final locale = Localizations.localeOf(context);
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat.jm(locale.toString()).format(dateTime);
  }

  /// Форматирует месяц и год (например, "Январь 2024")
  static String formatMonthYear(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    return DateFormat.yMMMM(locale.toString()).format(date);
  }

  /// Форматирует только месяц и год (MMMM yyyy)
  static String formatMonthYearShort(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    return DateFormat.yMMMM(locale.toString()).format(date);
  }

  /// Форматирует день недели и дату (например, "Понедельник, 1 января")
  static String formatWeekdayDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    return DateFormat('EEEE, d MMMM', locale.toString()).format(date);
  }

  /// Форматирует только день месяца (dd)
  static String formatDay(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    return DateFormat.d(locale.toString()).format(date);
  }

  /// Форматирует день и месяц (dd.MM)
  static String formatDayMonth(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    return DateFormat.Md(locale.toString()).format(date);
  }

  /// Форматирует день недели (короткий формат, например "Пн")
  static String formatWeekdayShort(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    return DateFormat.E(locale.toString()).format(date).toUpperCase();
  }

  /// Форматирует дату для календаря (dd MMMM yyyy, HH:mm)
  static String formatCalendarDateTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context);
    return DateFormat('d MMMM yyyy, HH:mm', locale.toString()).format(dateTime);
  }

  /// Форматирует время из DateTime
  static String formatTimeFromDateTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context);
    return DateFormat.jm(locale.toString()).format(dateTime);
  }
}
