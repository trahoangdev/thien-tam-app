import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/book_category_api_client.dart';
import '../../../books/data/models/book_category.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// API Client provider
final bookCategoryApiClientProvider = Provider<BookCategoryApiClient>((ref) {
  return BookCategoryApiClient();
});

// Categories list provider (for admin)
final adminBookCategoriesProvider =
    FutureProvider.autoDispose<List<BookCategory>>((ref) async {
      final client = ref.read(bookCategoryApiClientProvider);
      final token = ref.read(accessTokenProvider);
      return await client.getCategories(token: token);
    });

// State notifier for category management
class BookCategoryNotifier
    extends StateNotifier<AsyncValue<List<BookCategory>>> {
  final BookCategoryApiClient _client;
  final String? _token;

  BookCategoryNotifier(this._client, this._token)
    : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _client.getCategories(token: _token);
      state = AsyncValue.data(categories);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<bool> createCategory(Map<String, dynamic> data) async {
    if (_token == null) return false;

    try {
      await _client.createCategory(data, _token!);
      await loadCategories(); // Reload list
      return true;
    } catch (error) {
      print('Create category error: $error');
      return false;
    }
  }

  Future<bool> updateCategory(String id, Map<String, dynamic> data) async {
    if (_token == null) return false;

    try {
      await _client.updateCategory(id, data, _token!);
      await loadCategories(); // Reload list
      return true;
    } catch (error) {
      print('Update category error: $error');
      return false;
    }
  }

  Future<bool> deleteCategory(String id) async {
    if (_token == null) return false;

    try {
      await _client.deleteCategory(id, _token!);
      await loadCategories(); // Reload list
      return true;
    } catch (error) {
      print('Delete category error: $error');
      return false;
    }
  }

  Future<bool> reorderCategories(List<String> categoryIds) async {
    if (_token == null) return false;

    try {
      await _client.reorderCategories(categoryIds, _token!);
      await loadCategories(); // Reload list
      return true;
    } catch (error) {
      print('Reorder categories error: $error');
      return false;
    }
  }
}

// Category management provider
final bookCategoryNotifierProvider =
    StateNotifierProvider.autoDispose<
      BookCategoryNotifier,
      AsyncValue<List<BookCategory>>
    >((ref) {
      final client = ref.watch(bookCategoryApiClientProvider);
      final token = ref.watch(accessTokenProvider);
      return BookCategoryNotifier(client, token);
    });
