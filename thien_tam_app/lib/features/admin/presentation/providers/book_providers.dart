import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/book_api_client.dart';
import '../../../books/data/models/book.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// API Client Provider
final bookApiClientProvider = Provider<BookApiClient>((ref) {
  final dio = Dio();
  return BookApiClient(dio);
});

// Admin Books List Provider with filters
final adminBooksProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, AdminBooksParams>((ref, params) async {
      final apiClient = ref.watch(bookApiClientProvider);
      final token = ref.watch(accessTokenProvider);

      if (token == null) {
        throw Exception('Not authenticated');
      }

      return await apiClient.getAllBooks(
        category: params.category,
        search: params.search,
        bookLanguage: params.bookLanguage,
        isPublic: params.isPublic,
        page: params.page,
        limit: params.limit,
        sortBy: params.sortBy,
        sortOrder: params.sortOrder,
        token: token,
      );
    });

// Book Detail Provider
final adminBookDetailProvider = FutureProvider.autoDispose.family<Book, String>(
  (ref, id) async {
    final apiClient = ref.watch(bookApiClientProvider);
    final token = ref.watch(accessTokenProvider);

    if (token == null) {
      throw Exception('Not authenticated');
    }

    return await apiClient.getBookById(id, token: token);
  },
);

// Filter State Providers
final adminBookSearchQueryProvider = StateProvider<String>((ref) => '');
final adminBookSelectedCategoryProvider = StateProvider<String?>((ref) => null);
final adminBookSelectedLanguageProvider = StateProvider<String?>((ref) => null);
final adminBookIsPublicFilterProvider = StateProvider<bool?>((ref) => null);
final adminBookCurrentPageProvider = StateProvider<int>((ref) => 1);
final adminBookSortByProvider = StateProvider<String>((ref) => 'createdAt');
final adminBookSortOrderProvider = StateProvider<String>((ref) => 'desc');

// Upload Progress Provider
final bookUploadProgressProvider = StateProvider<double>((ref) => 0.0);

// Parameters class for admin books query
class AdminBooksParams {
  final String? category;
  final String? search;
  final String? bookLanguage;
  final bool? isPublic;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  AdminBooksParams({
    this.category,
    this.search,
    this.bookLanguage,
    this.isPublic,
    required this.page,
    required this.limit,
    required this.sortBy,
    required this.sortOrder,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminBooksParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          search == other.search &&
          bookLanguage == other.bookLanguage &&
          isPublic == other.isPublic &&
          page == other.page &&
          limit == other.limit &&
          sortBy == other.sortBy &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      category.hashCode ^
      search.hashCode ^
      bookLanguage.hashCode ^
      isPublic.hashCode ^
      page.hashCode ^
      limit.hashCode ^
      sortBy.hashCode ^
      sortOrder.hashCode;
}
