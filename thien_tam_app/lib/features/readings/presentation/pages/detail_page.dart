import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/reading_providers.dart';
import '../../data/reading_stats_service.dart';
import '../../data/models/reading.dart';
import 'package:intl/intl.dart';
import 'not_found_page.dart';
import '../../../../core/settings_providers.dart';
import '../../../tts/presentation/widgets/tts_widget.dart';
import '../../../tts/presentation/widgets/sleep_mode_widget.dart';
import '../../../tts/presentation/providers/tts_providers.dart';

class DetailPage extends ConsumerStatefulWidget {
  final DateTime date;
  final String? readingId; // Optional reading ID for specific reading

  const DetailPage({super.key, required this.date, this.readingId});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  DateTime? _startTime;
  Timer? _readingTimer;
  String? _currentReadingId;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _startReadingTimer();
  }

  @override
  void dispose() {
    _readingTimer?.cancel();
    _trackReadingTime();
    super.dispose();
  }

  void _startReadingTimer() {
    _readingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      // Update reading time every minute
      _trackReadingTime();
    });
  }

  void _trackReadingTime() async {
    if (_startTime != null) {
      final readingTime = DateTime.now().difference(_startTime!).inMinutes;
      if (readingTime > 0) {
        // Update local stats
        await ref
            .read(readingStatsProvider.notifier)
            .addReading(readingTimeMinutes: readingTime);

        // If we have a reading ID and user is logged in, update backend
        if (_currentReadingId != null) {
          await ref
              .read(readingStatsProvider.notifier)
              .updateReadingOnBackend(
                readingId: _currentReadingId!,
                timeSpent: readingTime,
              );
        }

        _startTime = DateTime.now(); // Reset start time
      }
    }
  }

  void _showReadingSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReadingSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingByDateProvider(widget.date));
    final fontSize = ref.watch(fontSizeProvider);
    final lineHeight = ref.watch(lineHeightProvider);

    return Scaffold(
      appBar: state.when(
        data: (readings) => AppBar(
          // Use reading date for accurate display
          title: Text(
            readings.isNotEmpty
                ? 'Bài đọc ${DateFormat('dd/MM/yyyy').format(readings.first.date)}'
                : 'Bài đọc ${DateFormat('dd/MM/yyyy').format(widget.date)}',
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.text_fields),
              tooltip: 'Cài đặt đọc',
              onPressed: () {
                _showReadingSettings(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.nightlight_round),
              tooltip: 'Chế độ ngủ',
              onPressed: () {
                final sleepModeService = ref.read(sleepModeServiceProvider);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      SleepModeWidget(sleepModeService: sleepModeService),
                );
              },
            ),
          ],
        ),
        loading: () => AppBar(
          title: Text(
            'Bài đọc ${DateFormat('dd/MM/yyyy').format(widget.date)}',
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        error: (_, __) => AppBar(
          title: Text(
            'Bài đọc ${DateFormat('dd/MM/yyyy').format(widget.date)}',
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
      body: state.when(
        data: (readings) {
          if (readings.isEmpty) {
            return NotFoundPage(
              message:
                  'Không có bài đọc nào cho ngày ${DateFormat('dd/MM/yyyy').format(widget.date)}',
              onRetry: () {
                ref.invalidate(readingByDateProvider(widget.date));
              },
              onGoHome: () {
                Navigator.of(context).pop();
              },
            );
          }

          // Find specific reading by ID if provided, otherwise show first reading
          Reading reading;
          if (widget.readingId != null) {
            final foundReading = readings
                .where((r) => r.id == widget.readingId)
                .firstOrNull;
            if (foundReading != null) {
              reading = foundReading;
            } else {
              // Fallback to first reading if ID not found
              reading = readings.first;
            }
          } else {
            reading = readings.first;
          }

          // Set current reading ID for stats tracking
          if (_currentReadingId != reading.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _currentReadingId = reading.id;
              });
            });
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show indicator if multiple readings
                if (readings.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Có ${readings.length} bài đọc cho ngày này',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  reading.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20 + (fontSize * 6), // Base 20px + fontSize scale
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy', 'vi').format(
                        DateTime(
                          reading.date.year,
                          reading.date.month,
                          reading.date.day,
                        ),
                      ),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (reading.topicSlugs.isNotEmpty) ...[
                      Icon(
                        Icons.label,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reading.topicSlugs.join(', '),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                      ),
                    ],
                  ],
                ),
                const Divider(height: 32),
                Text(
                  reading.body ?? 'Nội dung đang được cập nhật...',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: lineHeight, // Use lineHeight from settings
                    fontSize: 16 + (fontSize * 4), // Base 16px + fontSize scale
                  ),
                  textAlign: TextAlign.justify,
                ),

                // Source information
                if (reading.source.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Nguồn',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reading.source,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Đức Phật Thích Ca Mâu Ni',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // TTS Widget with voice selector
                const SizedBox(height: 24),
                TTSWidget(
                  text: reading.body ?? 'Nội dung đang được cập nhật...',
                  showControls: true,
                  showVoiceSelector: true,
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return NotFoundPage(
            message: 'Lỗi khi tải bài đọc: $error',
            onRetry: () {
              ref.invalidate(readingByDateProvider(widget.date));
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

// Reading Settings Bottom Sheet Widget
class _ReadingSettingsSheet extends ConsumerStatefulWidget {
  const _ReadingSettingsSheet();

  @override
  ConsumerState<_ReadingSettingsSheet> createState() =>
      _ReadingSettingsSheetState();
}

class _ReadingSettingsSheetState extends ConsumerState<_ReadingSettingsSheet> {
  late int _tempFontSize;
  late double _tempLineHeight;

  @override
  void initState() {
    super.initState();
    _tempFontSize = ref.read(fontSizeProvider);
    _tempLineHeight = ref.read(lineHeightProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.text_fields,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cài Đặt Đọc',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Font Size Setting
              Text(
                'Kích thước chữ',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.text_fields, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _tempFontSize.toDouble(),
                      min: 0,
                      max: 2,
                      divisions: 2,
                      label: _getFontSizeLabel(_tempFontSize),
                      onChanged: (value) {
                        setState(() {
                          _tempFontSize = value.toInt();
                        });
                        ref.read(fontSizeProvider.notifier).state =
                            _tempFontSize;
                        ref
                            .read(settingsServiceProvider)
                            .setFontSize(_tempFontSize);
                      },
                    ),
                  ),
                  Text(
                    _getFontSizeLabel(_tempFontSize),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Line Height Setting
              Text(
                'Khoảng cách dòng',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.format_line_spacing, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Slider(
                      value: _tempLineHeight,
                      min: 1.0,
                      max: 3.0,
                      divisions: 20,
                      label: '${_tempLineHeight.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        setState(() {
                          _tempLineHeight = value;
                        });
                        ref.read(lineHeightProvider.notifier).state =
                            _tempLineHeight;
                        ref
                            .read(settingsServiceProvider)
                            .setLineHeight(_tempLineHeight);
                      },
                    ),
                  ),
                  Text(
                    '${_tempLineHeight.toStringAsFixed(1)}x',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preview Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  'Đây là đoạn văn mẫu để xem trước kích thước chữ và khoảng cách dòng. '
                  'Điều chỉnh các thanh trượt bên trên để tìm cài đặt phù hợp nhất với bạn.',
                  style: TextStyle(
                    fontSize: _getFontSize(_tempFontSize),
                    height: _tempLineHeight,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Áp dụng'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFontSizeLabel(int size) {
    switch (size) {
      case 0:
        return 'Nhỏ';
      case 2:
        return 'Lớn';
      default:
        return 'Vừa';
    }
  }

  double _getFontSize(int size) {
    switch (size) {
      case 0:
        return 14.0;
      case 2:
        return 18.0;
      default:
        return 16.0;
    }
  }
}
