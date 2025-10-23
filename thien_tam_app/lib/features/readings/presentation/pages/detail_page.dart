import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../providers/reading_providers.dart';
import '../../data/reading_stats_service.dart';
import 'package:intl/intl.dart';
import 'not_found_page.dart';
import '../../../../core/settings_providers.dart';
import '../../../tts/presentation/widgets/tts_widget.dart';

class DetailPage extends ConsumerStatefulWidget {
  final DateTime date;

  const DetailPage({super.key, required this.date});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  DateTime? _startTime;
  Timer? _readingTimer;

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
        await ref
            .read(readingStatsProvider.notifier)
            .addReading(readingTimeMinutes: readingTime);
        _startTime = DateTime.now(); // Reset start time
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readingByDateProvider(widget.date));
    final fontSize = ref.watch(fontSizeProvider);
    final lineHeight = ref.watch(lineHeightProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bài đọc ${DateFormat('dd/MM/yyyy').format(widget.date)}'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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

          // Show first reading (or could show list if multiple)
          final reading = readings.first;

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
                      DateFormat('dd/MM/yyyy', 'vi').format(reading.date),
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
