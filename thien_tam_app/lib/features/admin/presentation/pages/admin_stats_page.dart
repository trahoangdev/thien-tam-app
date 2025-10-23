import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_readings_providers.dart';
import '../../../../core/app_lifecycle.dart';

class AdminStatsPage extends ConsumerWidget {
  const AdminStatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    // Listen to app lifecycle for auto-refresh
    ref.listen<AppLifecycleState>(appLifecycleProvider, (previous, next) {
      if (previous != AppLifecycleState.resumed &&
          next == AppLifecycleState.resumed) {
        // Auto-refresh admin stats after app resume
        Future.delayed(const Duration(milliseconds: 500), () {
          ref.invalidate(adminStatsProvider);
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminStatsProvider);
            },
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => _buildStatsContent(context, stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Lỗi tải thống kê',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(adminStatsProvider);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, Map<String, dynamic> stats) {
    final totalReadings = stats['totalReadings'] as int? ?? 0;
    final topicCounts = stats['topicCounts'] as List? ?? [];
    final recentReadings = stats['recentReadings'] as List? ?? [];
    final monthlyStats = stats['monthlyStats'] as List? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          _buildOverviewCards(context, totalReadings, topicCounts),
          const SizedBox(height: 24),

          // Topic Distribution
          if (topicCounts.isNotEmpty) ...[
            _buildSectionTitle(context, 'Phân bố theo chủ đề'),
            const SizedBox(height: 16),
            _buildTopicDistribution(context, topicCounts),
            const SizedBox(height: 24),
          ],

          // Monthly Statistics
          if (monthlyStats.isNotEmpty) ...[
            _buildSectionTitle(context, 'Thống kê theo tháng'),
            const SizedBox(height: 16),
            _buildMonthlyStats(context, monthlyStats),
            const SizedBox(height: 24),
          ],

          // Recent Readings
          if (recentReadings.isNotEmpty) ...[
            _buildSectionTitle(context, 'Bài đọc gần đây'),
            const SizedBox(height: 16),
            _buildRecentReadings(context, recentReadings),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    int totalReadings,
    List topicCounts,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.article,
            title: 'Tổng số bài đọc',
            value: totalReadings.toString(),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.label,
            title: 'Số chủ đề',
            value: topicCounts.length.toString(),
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTopicDistribution(BuildContext context, List topicCounts) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: topicCounts.map<Widget>((topic) {
            final topicName = topic['topic'] as String? ?? 'Không xác định';
            final count = topic['count'] as int? ?? 0;
            final percentage = topicCounts.isNotEmpty
                ? (count /
                          topicCounts.fold<int>(
                            0,
                            (sum, t) => sum + (t['count'] as int? ?? 0),
                          )) *
                      100
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      topicName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '$count (${percentage.toStringAsFixed(1)}%)',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMonthlyStats(BuildContext context, List monthlyStats) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: monthlyStats.map<Widget>((month) {
            final monthName = month['month'] as String? ?? '';
            final count = month['count'] as int? ?? 0;

            return ListTile(
              leading: Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(monthName),
              trailing: Text(
                '$count bài',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRecentReadings(BuildContext context, List recentReadings) {
    return Card(
      elevation: 2,
      child: Column(
        children: recentReadings.take(5).map<Widget>((reading) {
          final title = reading['title'] as String? ?? 'Không có tiêu đề';
          final date = reading['date'] as String? ?? '';
          final topic = reading['topic'] as String? ?? '';

          return ListTile(
            leading: Icon(
              Icons.article,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '$date • $topic',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }).toList(),
      ),
    );
  }
}
