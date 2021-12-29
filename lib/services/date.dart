import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:popover/popover.dart';
import 'package:roman/services/extensions.dart';
import 'package:table_calendar/table_calendar.dart';

class ConvertDate {
  ConvertDate(
    this.context,
  ) {
    initializeDateFormatting();
  }

  final BuildContext context;

  static DateTime firstDayOfWeak() {
    var _today = DateTime.now().toLocal();
    return _today.add(
      Duration(
        days: -_today.weekday + 1,
        hours: -_today.hour,
        minutes: -_today.minute,
        seconds: -_today.second,
        milliseconds: -_today.millisecond,
      ),
    );
  }

  int fromDateTime(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  String fromDate(DateTime date, String format) {
    Localizations.localeOf(context).languageCode;
    final DateFormat formatter = DateFormat(format, "ru");
    return formatter.format(date);
  }

  String fromUnix(int unix, String format) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      unix * 1000,
    ).toLocal();
    Localizations.localeOf(context).languageCode;
    final DateFormat formatter = DateFormat(format, "ru");
    return formatter.format(date);
  }

  void showDatePicker(DateTime selectedTime, Function(DateTime date) select) {
    var _firstDay = DateTime.now().toLocal();
    var _lastDay = DateTime(DateTime.now().toLocal().year + 2);

    showPopover(
      context: context,
      width: 280,
      height: 400,
      direction: PopoverDirection.left,
      bodyBuilder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: TableCalendar(
            locale: "ru",
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: HeaderStyle(
              titleTextFormatter: (date, locale) {
                return ConvertDate(context)
                    .fromDate(date, "MMMM")
                    .capitalLetter();
              },
              titleCentered: true,
              formatButtonVisible: false,
            ),
            focusedDay: selectedTime,
            firstDay: _firstDay,
            lastDay: _lastDay,
            selectedDayPredicate: (day) => isSameDay(selectedTime, day),
            onDaySelected: (date, _) {
              select(date);
              Navigator.pop(context);
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
