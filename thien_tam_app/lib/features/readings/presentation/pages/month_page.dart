import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reading_providers.dart';
import '../../../../core/app_lifecycle.dart';
import 'package:intl/intl.dart';
import 'detail_page.dart';
import '../widgets/buddhist_calendar_widget.dart';
import 'not_found_page.dart';

class MonthPage extends ConsumerStatefulWidget {
  final int year;
  final int month;

  const MonthPage({super.key, required this.year, required this.month});

  @override
  ConsumerState<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends ConsumerState<MonthPage> {
  late int _currentYear;
  late int _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentYear = widget.year;
    _currentMonth = widget.month;
  }

  @override
  Widget build(BuildContext context) {
    // Listen to app lifecycle for auto-refresh
    ref.listen<AppLifecycleState>(appLifecycleProvider, (previous, next) {
      if (previous != AppLifecycleState.resumed &&
          next == AppLifecycleState.resumed) {
        print('🔄 Auto-refreshing month page after app resume');
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.invalidate(monthReadingsProvider);
        });
      }
    });

    final state = ref.watch(
      monthReadingsProvider((_currentYear, _currentMonth)),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tháng $_currentMonth/$_currentYear',
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
      body: state.when(
        data: (readings) {
          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate provider để force reload từ server
              ref.invalidate(monthReadingsProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Buddhist Calendar Widget
                  BuddhistCalendarWidget(
                    year: _currentYear,
                    month: _currentMonth,
                    readings: readings,
                    onDateSelected: (selectedDate) {
                      // Không navigate nữa, chỉ hiển thị thông tin ngày được chọn
                      // Bài đọc sẽ được hiển thị trực tiếp trong BuddhistCalendarWidget
                    },
                    onMonthChanged: (newYear, newMonth) {
                      // Update state instead of navigating
                      setState(() {
                        _currentYear = newYear;
                        _currentMonth = newMonth;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  // Readings list for the month
                  if (readings.isNotEmpty) ...[
                    Text(
                      'Bài đọc trong tháng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...readings.map((reading) {
                      final localDate = reading.date.toLocal();
                      // Normalize date to avoid timezone issues
                      final normalizedDate = DateTime(
                        localDate.year,
                        localDate.month,
                        localDate.day,
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            child: Text(
                              localDate.day.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(
                            reading.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            DateFormat(
                              'EEEE, dd/MM/yyyy',
                              'vi',
                            ).format(localDate),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
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
                        ),
                      );
                    }),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 48,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không có bài đọc nào trong tháng này',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return NotFoundPage(
            message:
                'Lỗi khi tải dữ liệu tháng $_currentMonth/$_currentYear: $error',
            onRetry: () {
              ref.invalidate(
                monthReadingsProvider((_currentYear, _currentMonth)),
              );
            },
            onGoHome: () {
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}
