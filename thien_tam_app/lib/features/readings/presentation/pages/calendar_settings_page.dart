import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Calendar settings provider
final calendarSettingsProvider =
    StateNotifierProvider<CalendarSettingsNotifier, CalendarSettings>((ref) {
      return CalendarSettingsNotifier();
    });

class CalendarSettings {
  final bool showReadingIndicators;
  final bool showHolidayIndicators;
  final bool showFullMoonIndicators;
  final bool showHolidayDetails;
  final HolidayTypeFilter holidayFilter;
  final CalendarTheme calendarTheme;

  const CalendarSettings({
    this.showReadingIndicators = true,
    this.showHolidayIndicators = true,
    this.showFullMoonIndicators = true,
    this.showHolidayDetails = true,
    this.holidayFilter = HolidayTypeFilter.all,
    this.calendarTheme = CalendarTheme.buddhist,
  });

  CalendarSettings copyWith({
    bool? showReadingIndicators,
    bool? showHolidayIndicators,
    bool? showFullMoonIndicators,
    bool? showHolidayDetails,
    HolidayTypeFilter? holidayFilter,
    CalendarTheme? calendarTheme,
  }) {
    return CalendarSettings(
      showReadingIndicators:
          showReadingIndicators ?? this.showReadingIndicators,
      showHolidayIndicators:
          showHolidayIndicators ?? this.showHolidayIndicators,
      showFullMoonIndicators:
          showFullMoonIndicators ?? this.showFullMoonIndicators,
      showHolidayDetails: showHolidayDetails ?? this.showHolidayDetails,
      holidayFilter: holidayFilter ?? this.holidayFilter,
      calendarTheme: calendarTheme ?? this.calendarTheme,
    );
  }
}

enum HolidayTypeFilter { all, majorOnly, traditionalOnly, buddhistOnly }

enum CalendarTheme { buddhist, modern, minimalist }

class CalendarSettingsNotifier extends StateNotifier<CalendarSettings> {
  CalendarSettingsNotifier() : super(const CalendarSettings());

  void toggleReadingIndicators() {
    state = state.copyWith(showReadingIndicators: !state.showReadingIndicators);
  }

  void toggleHolidayIndicators() {
    state = state.copyWith(showHolidayIndicators: !state.showHolidayIndicators);
  }

  void toggleFullMoonIndicators() {
    state = state.copyWith(
      showFullMoonIndicators: !state.showFullMoonIndicators,
    );
  }

  void toggleHolidayDetails() {
    state = state.copyWith(showHolidayDetails: !state.showHolidayDetails);
  }

  void setHolidayFilter(HolidayTypeFilter filter) {
    state = state.copyWith(holidayFilter: filter);
  }

  void setCalendarTheme(CalendarTheme theme) {
    state = state.copyWith(calendarTheme: theme);
  }

  void resetToDefaults() {
    state = const CalendarSettings();
  }
}

// Calendar settings page
class CalendarSettingsPage extends ConsumerWidget {
  const CalendarSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(calendarSettingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Cài Đặt Lịch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Visual Indicators Section
          _buildSectionHeader(context, 'Chỉ Báo Trực Quan'),

          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Hiển thị ngày có bài đọc'),
                  subtitle: const Text('Chấm xanh cho ngày có bài đọc'),
                  value: settings.showReadingIndicators,
                  onChanged: (value) {
                    ref
                        .read(calendarSettingsProvider.notifier)
                        .toggleReadingIndicators();
                  },
                ),
                SwitchListTile(
                  title: const Text('Hiển thị ngày lễ'),
                  subtitle: const Text('Chấm vàng cho ngày lễ Phật giáo'),
                  value: settings.showHolidayIndicators,
                  onChanged: (value) {
                    ref
                        .read(calendarSettingsProvider.notifier)
                        .toggleHolidayIndicators();
                  },
                ),
                SwitchListTile(
                  title: const Text('Hiển thị ngày rằm'),
                  subtitle: const Text('Chấm xanh dương cho ngày rằm'),
                  value: settings.showFullMoonIndicators,
                  onChanged: (value) {
                    ref
                        .read(calendarSettingsProvider.notifier)
                        .toggleFullMoonIndicators();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Holiday Filter Section
          _buildSectionHeader(context, 'Lọc Ngày Lễ'),

          Card(
            child: Column(
              children: [
                RadioListTile<HolidayTypeFilter>(
                  title: const Text('Tất cả ngày lễ'),
                  value: HolidayTypeFilter.all,
                  groupValue: settings.holidayFilter,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(calendarSettingsProvider.notifier)
                          .setHolidayFilter(value);
                    }
                  },
                ),
                RadioListTile<HolidayTypeFilter>(
                  title: const Text('Chỉ ngày lễ lớn'),
                  subtitle: const Text('Tết, Phật Đản, Vu Lan'),
                  value: HolidayTypeFilter.majorOnly,
                  groupValue: settings.holidayFilter,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(calendarSettingsProvider.notifier)
                          .setHolidayFilter(value);
                    }
                  },
                ),
                RadioListTile<HolidayTypeFilter>(
                  title: const Text('Chỉ ngày lễ truyền thống'),
                  subtitle: const Text('Tết, Trung Thu, Valentine'),
                  value: HolidayTypeFilter.traditionalOnly,
                  groupValue: settings.holidayFilter,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(calendarSettingsProvider.notifier)
                          .setHolidayFilter(value);
                    }
                  },
                ),
                RadioListTile<HolidayTypeFilter>(
                  title: const Text('Chỉ ngày lễ Phật giáo'),
                  subtitle: const Text('Phật Đản, Vu Lan, Thành Đạo'),
                  value: HolidayTypeFilter.buddhistOnly,
                  groupValue: settings.holidayFilter,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(calendarSettingsProvider.notifier)
                          .setHolidayFilter(value);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Calendar Theme Section
          _buildSectionHeader(context, 'Giao Diện Lịch'),

          Card(
            child: Column(
              children: [
                RadioListTile<CalendarTheme>(
                  title: const Text('Phật giáo'),
                  subtitle: const Text('Màu sắc và biểu tượng Phật giáo'),
                  value: CalendarTheme.buddhist,
                  groupValue: settings.calendarTheme,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(calendarSettingsProvider.notifier)
                          .setCalendarTheme(value);
                    }
                  },
                ),
                RadioListTile<CalendarTheme>(
                  title: const Text('Hiện đại'),
                  subtitle: const Text('Thiết kế tối giản và hiện đại'),
                  value: CalendarTheme.modern,
                  groupValue: settings.calendarTheme,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(calendarSettingsProvider.notifier)
                          .setCalendarTheme(value);
                    }
                  },
                ),
                RadioListTile<CalendarTheme>(
                  title: const Text('Tối giản'),
                  subtitle: const Text('Thiết kế đơn giản, ít màu sắc'),
                  value: CalendarTheme.minimalist,
                  groupValue: settings.calendarTheme,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(calendarSettingsProvider.notifier)
                          .setCalendarTheme(value);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Holiday Details Section
          _buildSectionHeader(context, 'Chi Tiết Ngày Lễ'),

          Card(
            child: SwitchListTile(
              title: const Text('Hiển thị chi tiết ngày lễ'),
              subtitle: const Text('Mô tả và thông tin về từng ngày lễ'),
              value: settings.showHolidayDetails,
              onChanged: (value) {
                ref
                    .read(calendarSettingsProvider.notifier)
                    .toggleHolidayDetails();
              },
            ),
          ),

          const SizedBox(height: 32),

          // Reset Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ref.read(calendarSettingsProvider.notifier).resetToDefaults();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã đặt lại cài đặt về mặc định'),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Đặt lại mặc định'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
