import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/buddhist_calendar_service.dart';
import '../../data/lunar_calendar_service.dart';
import '../../data/models/reading.dart';
import '../pages/calendar_settings_page.dart';
import '../pages/detail_page.dart';

class BuddhistCalendarWidget extends ConsumerStatefulWidget {
  final int year;
  final int month;
  final List<Reading> readings;
  final Function(DateTime) onDateSelected;
  final Function(int year, int month)? onMonthChanged;

  const BuddhistCalendarWidget({
    super.key,
    required this.year,
    required this.month,
    required this.readings,
    required this.onDateSelected,
    this.onMonthChanged,
  });

  @override
  ConsumerState<BuddhistCalendarWidget> createState() =>
      _BuddhistCalendarWidgetState();
}

class _BuddhistCalendarWidgetState
    extends ConsumerState<BuddhistCalendarWidget> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.year, widget.month);
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final calendarSettings = ref.watch(calendarSettingsProvider);

    return Column(
      children: [
        // Month navigation with settings button
        _buildMonthNavigation(context),
        const SizedBox(height: 16),
        // Calendar grid
        _buildCalendarGrid(calendarSettings),
        const SizedBox(height: 16),
        // Selected date info
        _buildSelectedDateInfo(calendarSettings),
      ],
    );
  }

  Widget _buildMonthNavigation(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              );
            });
            // Notify parent about month change
            widget.onMonthChanged?.call(
              _currentMonth.year,
              _currentMonth.month,
            );
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            DateFormat('MMMM yyyy', 'vi').format(_currentMonth),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CalendarSettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
              tooltip: 'Cài đặt lịch',
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(
                    _currentMonth.year,
                    _currentMonth.month + 1,
                  );
                });
                // Notify parent about month change
                widget.onMonthChanged?.call(
                  _currentMonth.year,
                  _currentMonth.month,
                );
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(CalendarSettings settings) {
    final firstDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
      0,
    );
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;

    // Tạo danh sách ngày có readings
    final readingDates = widget.readings.map((r) {
      final localDate = r.date.toLocal();
      return DateTime(localDate.year, localDate.month, localDate.day);
    }).toSet();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          // Weekday headers
          _buildWeekdayHeaders(),
          // Calendar days
          _buildCalendarDays(
            firstDayWeekday,
            daysInMonth,
            readingDates,
            settings,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: weekdays
            .map(
              (day) => Expanded(
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendarDays(
    int firstDayWeekday,
    int daysInMonth,
    Set<DateTime> readingDates,
    CalendarSettings settings,
  ) {
    final days = <Widget>[];

    // Empty cells for days before month starts
    // DateTime.weekday: 1=Monday, 2=Tuesday, ..., 7=Sunday
    // Calendar grid: 0=Monday, 1=Tuesday, ..., 6=Sunday
    final emptyDays = (firstDayWeekday - 1) % 7;

    for (int i = 0; i < emptyDays; i++) {
      days.add(const SizedBox(height: 40));
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final hasReading = readingDates.contains(date);
      final holidays = BuddhistCalendarService.getHolidaysForDay(
        date.month,
        date.day,
      );
      final isFullMoon = LunarCalendarService.isFullMoonDay(date);
      final isSelected =
          _selectedDate.year == date.year &&
          _selectedDate.month == date.month &&
          _selectedDate.day == date.day;
      final isToday =
          date.year == DateTime.now().year &&
          date.month == DateTime.now().month &&
          date.day == DateTime.now().day;

      days.add(
        _buildDayCell(
          day: day,
          date: date,
          hasReading: hasReading,
          holidays: holidays,
          isFullMoon: isFullMoon,
          isSelected: isSelected,
          isToday: isToday,
          settings: settings,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // 7 days per week
          childAspectRatio: 1.0,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) => days[index],
      ),
    );
  }

  Widget _buildDayCell({
    required int day,
    required DateTime date,
    required bool hasReading,
    required List<BuddhistHoliday> holidays,
    required bool isFullMoon,
    required bool isSelected,
    required bool isToday,
    required CalendarSettings settings,
  }) {
    // Filter holidays based on settings
    final filteredHolidays = holidays.where((holiday) {
      switch (settings.holidayFilter) {
        case HolidayTypeFilter.all:
          return true;
        case HolidayTypeFilter.majorOnly:
          return holiday.type == HolidayType.major;
        case HolidayTypeFilter.traditionalOnly:
          return holiday.type == HolidayType.traditional;
        case HolidayTypeFilter.buddhistOnly:
          return holiday.type == HolidayType.buddhist;
      }
    }).toList();

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
        // Không gọi callback nữa, chỉ hiển thị thông tin ngày được chọn
        // Bài đọc sẽ được hiển thị trực tiếp trong selected date info
      },
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : isToday
              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: hasReading && settings.showReadingIndicators
              ? Border.all(
                  color: Theme.of(context).colorScheme.secondary,
                  width: 2,
                )
              : null,
        ),
        child: Stack(
          children: [
            // Day number
            Center(
              child: Text(
                day.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : isToday
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            // Reading indicator
            if (hasReading && settings.showReadingIndicators)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Holiday indicator
            if (filteredHolidays.isNotEmpty && settings.showHolidayIndicators)
              Positioned(
                bottom: 2,
                left: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: filteredHolidays.first.getColor(),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Full moon indicator
            if (isFullMoon && settings.showFullMoonIndicators)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Visual cue for clickable days (days with readings)
            if (hasReading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateInfo(CalendarSettings settings) {
    final holidays = BuddhistCalendarService.getHolidaysForDay(
      _selectedDate.month,
      _selectedDate.day,
    );
    final readings = widget.readings.where((r) {
      final localDate = r.date.toLocal();
      return localDate.year == _selectedDate.year &&
          localDate.month == _selectedDate.month &&
          localDate.day == _selectedDate.day;
    }).toList();

    // Filter holidays based on settings
    final filteredHolidays = holidays.where((holiday) {
      switch (settings.holidayFilter) {
        case HolidayTypeFilter.all:
          return true;
        case HolidayTypeFilter.majorOnly:
          return holiday.type == HolidayType.major;
        case HolidayTypeFilter.traditionalOnly:
          return holiday.type == HolidayType.traditional;
        case HolidayTypeFilter.buddhistOnly:
          return holiday.type == HolidayType.buddhist;
      }
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            if (readings.isNotEmpty) ...[
              Text(
                'Bài đọc: ${readings.length} bài',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              ...readings.map(
                (reading) => GestureDetector(
                  onTap: () {
                    // Navigate đến DetailPage khi click vào bài đọc cụ thể
                    // Truyền readingId để hiển thị đúng bài đọc được chọn
                    final normalizedDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPage(
                          date: normalizedDate,
                          readingId: reading.id,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reading.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              if (reading.topicSlugs.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Chủ đề: ${reading.topicSlugs.join(', ')}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant
                                            .withOpacity(0.7),
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Không có bài đọc cho ngày này',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Nhấn vào ngày có chấm xanh để xem bài đọc',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (filteredHolidays.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ngày lễ:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              ...filteredHolidays.map(
                (holiday) => settings.showHolidayDetails
                    ? _buildHolidayDetailCard(holiday)
                    : Text(
                        '• ${holiday.name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: holiday.getColor(),
                        ),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayDetailCard(BuddhistHoliday holiday) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(holiday.getIcon(), color: holiday.getColor(), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holiday.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: holiday.getColor(),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    holiday.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
