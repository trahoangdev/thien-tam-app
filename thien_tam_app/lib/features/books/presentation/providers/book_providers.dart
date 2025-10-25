import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/book_service.dart';
import '../../data/book_category_service.dart';
import '../../data/models/book.dart';
import '../../data/models/book_category.dart';

// Service providers
final bookServiceProvider = Provider<BookService>((ref) {
  return BookService();
});

final bookCategoryServiceProvider = Provider<BookCategoryService>((ref) {
  return BookCategoryService();
});

// Categories provider (now using BookCategory model)
final bookCategoriesProvider = FutureProvider<List<BookCategory>>((ref) async {
  final service = ref.read(bookCategoryServiceProvider);
  return await service.getCategories(isActive: true);
});

// Popular books provider
final popularBooksProvider = FutureProvider<List<Book>>((ref) async {
  final service = ref.read(bookServiceProvider);
  return await service.getPopularBooks(limit: 10);
});

// Filter state providers
final bookSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedBookCategoryProvider = StateProvider<String?>((ref) => null);
final selectedBookLanguageProvider = StateProvider<String?>((ref) => null);
final bookCurrentPageProvider = StateProvider<int>((ref) => 1);
final bookSortByProvider = StateProvider<String>((ref) => 'createdAt');
final bookSortOrderProvider = StateProvider<String>((ref) => 'desc');

// Books list params class
class BooksParams {
  final String? category;
  final String? search;
  final String? bookLanguage;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  const BooksParams({
    this.category,
    this.search,
    this.bookLanguage,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooksParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          search == other.search &&
          bookLanguage == other.bookLanguage &&
          page == other.page &&
          limit == other.limit &&
          sortBy == other.sortBy &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode =>
      category.hashCode ^
      search.hashCode ^
      bookLanguage.hashCode ^
      page.hashCode ^
      limit.hashCode ^
      sortBy.hashCode ^
      sortOrder.hashCode;
}

// Books provider with filters
final booksProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, BooksParams>((ref, params) async {
      final service = ref.read(bookServiceProvider);
      return await service.getBooks(
        category: params.category,
        search: params.search,
        bookLanguage: params.bookLanguage,
        page: params.page,
        limit: params.limit,
        sortBy: params.sortBy,
        sortOrder: params.sortOrder,
      );
    });

// Book detail provider
final bookDetailProvider = FutureProvider.family<Book, String>((ref, id) async {
  final service = ref.read(bookServiceProvider);
  return await service.getBookById(id);
});

// Currently viewing book
final currentBookProvider = StateProvider<Book?>((ref) => null);
