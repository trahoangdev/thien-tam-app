import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/topic_api_client.dart';
import '../../data/models/topic.dart';
import 'admin_providers.dart';

// API Client Provider
final topicApiClientProvider = Provider((ref) {
  final client = TopicApiClient();
  final accessToken = ref.watch(accessTokenProvider);
  client.setAccessToken(accessToken);
  return client;
});

// Topics List Provider
final adminTopicsProvider =
    FutureProvider.family<
      Map<String, dynamic>,
      ({int page, int limit, String? search})
    >((ref, params) async {
      final apiClient = ref.read(topicApiClientProvider);
      return await apiClient.getTopics(
        page: params.page,
        limit: params.limit,
        search: params.search,
      );
    });

// Single Topic Provider
final adminTopicProvider = FutureProvider.family<Topic, String>((
  ref,
  id,
) async {
  final apiClient = ref.read(topicApiClientProvider);
  return await apiClient.getTopic(id);
});

// Topic Stats Provider
final adminTopicStatsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final apiClient = ref.read(topicApiClientProvider);
  return await apiClient.getTopicStats();
});

// Topic Form State Provider
class TopicFormState {
  final String slug;
  final String name;
  final String description;
  final String color;
  final String icon;
  final bool isActive;
  final int sortOrder;
  final bool isLoading;
  final String? error;

  TopicFormState({
    this.slug = '',
    this.name = '',
    this.description = '',
    this.color = '#4CAF50',
    this.icon = 'label',
    this.isActive = true,
    this.sortOrder = 0,
    this.isLoading = false,
    this.error,
  });

  TopicFormState copyWith({
    String? slug,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    int? sortOrder,
    bool? isLoading,
    String? error,
  }) {
    return TopicFormState(
      slug: slug ?? this.slug,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isValid =>
      slug.isNotEmpty &&
      name.isNotEmpty &&
      RegExp(r'^[a-z0-9-]+$').hasMatch(slug);
}

class TopicFormNotifier extends StateNotifier<TopicFormState> {
  TopicFormNotifier() : super(TopicFormState());

  void updateSlug(String slug) {
    state = state.copyWith(slug: slug.toLowerCase().trim());
  }

  void updateName(String name) {
    state = state.copyWith(name: name.trim());
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description.trim());
  }

  void updateColor(String color) {
    state = state.copyWith(color: color);
  }

  void updateIcon(String icon) {
    state = state.copyWith(icon: icon.trim());
  }

  void updateIsActive(bool isActive) {
    state = state.copyWith(isActive: isActive);
  }

  void updateSortOrder(int sortOrder) {
    state = state.copyWith(sortOrder: sortOrder);
  }

  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void reset() {
    state = TopicFormState();
  }

  void loadTopic(Topic topic) {
    state = TopicFormState(
      slug: topic.slug,
      name: topic.name,
      description: topic.description,
      color: topic.color,
      icon: topic.icon,
      isActive: topic.isActive,
      sortOrder: topic.sortOrder,
    );
  }
}

final topicFormProvider =
    StateNotifierProvider<TopicFormNotifier, TopicFormState>(
      (ref) => TopicFormNotifier(),
    );
