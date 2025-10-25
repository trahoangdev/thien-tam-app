import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/audio_api_client.dart';
import '../../../audio/data/models/audio.dart';
import 'admin_providers.dart';

// Audio API Client Provider
final audioApiClientProvider = Provider<AudioApiClient>((ref) {
  return AudioApiClient();
});

// Admin Audios List Provider
final adminAudiosProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, AdminAudiosParams>((ref, params) async {
      final apiClient = ref.read(audioApiClientProvider);
      final token = ref.read(accessTokenProvider);

      if (token == null) {
        throw Exception('No admin token found');
      }

      return await apiClient.getAllAudios(
        category: params.category,
        search: params.search,
        isPublic: params.isPublic,
        page: params.page,
        limit: params.limit,
        sortBy: params.sortBy,
        sortOrder: params.sortOrder,
        token: token,
      );
    });

// Audio Categories Provider
final audioCategoriesProvider = FutureProvider.autoDispose((ref) async {
  final apiClient = ref.read(audioApiClientProvider);
  return await apiClient.getCategories();
});

// Popular Audios Provider
final popularAudiosProvider = FutureProvider.autoDispose
    .family<List<Audio>, int>((ref, limit) async {
      final apiClient = ref.read(audioApiClientProvider);
      return await apiClient.getPopularAudios(limit: limit);
    });

// Audio Detail Provider
final audioDetailProvider = FutureProvider.autoDispose.family<Audio, String>((
  ref,
  id,
) async {
  final apiClient = ref.read(audioApiClientProvider);
  final token = ref.read(accessTokenProvider);

  return await apiClient.getAudioById(id, token: token);
});

// Audio Upload Progress Provider
final audioUploadProgressProvider = StateProvider<double>((ref) => 0.0);

// Audio Filter State Providers
final audioSearchQueryProvider = StateProvider<String>((ref) => '');
final audioSelectedCategoryProvider = StateProvider<String?>((ref) => null);
final audioIsPublicFilterProvider = StateProvider<bool?>((ref) => null);
final audioCurrentPageProvider = StateProvider<int>((ref) => 1);
final audioSortByProvider = StateProvider<String>((ref) => 'createdAt');
final audioSortOrderProvider = StateProvider<String>((ref) => 'desc');

// Parameters class for admin audios
class AdminAudiosParams {
  final String? category;
  final String? search;
  final bool? isPublic;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  AdminAudiosParams({
    this.category,
    this.search,
    this.isPublic,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdminAudiosParams &&
        other.category == category &&
        other.search == search &&
        other.isPublic == isPublic &&
        other.page == page &&
        other.limit == limit &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(
      category,
      search,
      isPublic,
      page,
      limit,
      sortBy,
      sortOrder,
    );
  }
}
