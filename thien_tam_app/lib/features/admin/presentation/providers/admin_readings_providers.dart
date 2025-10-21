import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_api_client.dart';
import '../../data/models/reading_create_request.dart';
import '../../data/models/reading_update_request.dart';
import '../../../readings/data/models/reading.dart';
import 'admin_providers.dart';

// Readings list provider with pagination
final adminReadingsProvider =
    FutureProvider.family<Map<String, dynamic>, AdminReadingsParams>((
      ref,
      params,
    ) async {
      final apiClient = ref.watch(adminApiClientProvider);
      return await apiClient.getReadings(
        page: params.page,
        limit: params.limit,
        topic: params.topic,
        search: params.search,
      );
    });

class AdminReadingsParams {
  final int page;
  final int limit;
  final String? topic;
  final String? search;

  AdminReadingsParams({
    this.page = 1,
    this.limit = 20,
    this.topic,
    this.search,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminReadingsParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          limit == other.limit &&
          topic == other.topic &&
          search == other.search;

  @override
  int get hashCode => Object.hash(page, limit, topic, search);
}

// Single reading provider
final adminReadingByIdProvider = FutureProvider.family<Reading, String>((
  ref,
  id,
) async {
  final apiClient = ref.watch(adminApiClientProvider);
  return await apiClient.getReadingById(id);
});

// Stats provider
final adminStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiClient = ref.watch(adminApiClientProvider);
  return await apiClient.getStats();
});

// CRUD operations notifier
class AdminReadingsCrudNotifier extends StateNotifier<AsyncValue<void>> {
  final AdminApiClient _apiClient;
  final Ref _ref;

  AdminReadingsCrudNotifier(this._apiClient, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> createReading(ReadingCreateRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _apiClient.createReading(request);
      state = const AsyncValue.data(null);
      // Invalidate list to refresh
      _ref.invalidate(adminReadingsProvider);
      _ref.invalidate(adminStatsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateReading(String id, ReadingUpdateRequest request) async {
    state = const AsyncValue.loading();
    try {
      await _apiClient.updateReading(id, request);
      state = const AsyncValue.data(null);
      // Invalidate related providers
      _ref.invalidate(adminReadingsProvider);
      _ref.invalidate(adminReadingByIdProvider(id));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteReading(String id) async {
    state = const AsyncValue.loading();
    try {
      await _apiClient.deleteReading(id);
      state = const AsyncValue.data(null);
      // Invalidate list to refresh
      _ref.invalidate(adminReadingsProvider);
      _ref.invalidate(adminStatsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminReadingsCrudProvider =
    StateNotifierProvider<AdminReadingsCrudNotifier, AsyncValue<void>>((ref) {
      final apiClient = ref.watch(adminApiClientProvider);
      return AdminReadingsCrudNotifier(apiClient, ref);
    });
