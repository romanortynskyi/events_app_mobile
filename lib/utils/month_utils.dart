import 'package:events_app_mobile/models/event.dart';
import 'package:events_app_mobile/models/month.dart';
import 'package:intl/intl.dart';

class MonthUtils {
  static Iterable<Month> getMonths({
    required Iterable<Event> events,
    required Iterable<Month> prevMonths,
  }) {
    if (events.isEmpty) {
      return prevMonths;
    }

    Set<String> uniqueMonthNames = events
        .map((event) =>
            DateFormat('MMM yyyy').format(event.startDate ?? DateTime.now()))
        .toSet();

    List<Month> months = uniqueMonthNames.map((monthName) {
      List<Event> eventsByMonth = events
          .where((event) =>
              DateFormat('MMM yyyy')
                  .format(event.startDate ?? DateTime.now()) ==
              monthName)
          .toList();

      return Month(
        name: monthName,
        events: eventsByMonth,
      );
    }).toList();

    if (prevMonths.isNotEmpty) {
      Month lastMonthFromState = prevMonths.last;
      Month firstMonthFromResponse =
          months.where((month) => month.name == lastMonthFromState.name).first;
      Month updatedLastMonth = Month(
        name: lastMonthFromState.name,
        events: [
          ...lastMonthFromState.events,
          ...firstMonthFromResponse.events,
        ],
      );

      List<Month> updatedMonths = [
        ...prevMonths.where((month) => month.name != updatedLastMonth.name),
        updatedLastMonth,
        ...months.sublist(1),
      ];

      return updatedMonths;
    }

    return months;
  }
}
