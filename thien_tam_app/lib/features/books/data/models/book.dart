import 'book_category.dart' as cat;

class Book {
  final String id;
  final String title;
  final String? author;
  final String? translator;
  final String? description;
  final dynamic category; // Can be String (ID) or BookCategory object
  final List<String> tags;
  final String bookLanguage;

  // PDF file info
  final String cloudinaryPublicId;
  final String cloudinaryUrl;
  final String cloudinarySecureUrl;
  final int fileSize;
  final int? pageCount;

  // Cover image
  final String? coverImageUrl;
  final String? coverImagePublicId;

  // Metadata
  final String? publisher;
  final int? publishYear;
  final String? isbn;

  // Stats
  final int downloadCount;
  final int viewCount;

  // Access control
  final bool isPublic;
  final String uploadedBy;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  Book({
    required this.id,
    required this.title,
    this.author,
    this.translator,
    this.description,
    required this.category,
    required this.tags,
    required this.bookLanguage,
    required this.cloudinaryPublicId,
    required this.cloudinaryUrl,
    required this.cloudinarySecureUrl,
    required this.fileSize,
    this.pageCount,
    this.coverImageUrl,
    this.coverImagePublicId,
    this.publisher,
    this.publishYear,
    this.isbn,
    required this.downloadCount,
    required this.viewCount,
    required this.isPublic,
    required this.uploadedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // Parse category - can be String (ID) or object
    dynamic categoryValue;
    if (json['category'] is String) {
      categoryValue = json['category'];
    } else if (json['category'] is Map) {
      categoryValue = cat.BookCategory.fromJson(
        json['category'] as Map<String, dynamic>,
      );
    } else {
      categoryValue = 'other';
    }

    return Book(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'],
      translator: json['translator'],
      description: json['description'],
      category: categoryValue,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      bookLanguage: json['bookLanguage'] ?? 'vi',
      cloudinaryPublicId: json['cloudinaryPublicId'] ?? '',
      cloudinaryUrl: json['cloudinaryUrl'] ?? '',
      cloudinarySecureUrl: json['cloudinarySecureUrl'] ?? '',
      fileSize: _parseInt(json['fileSize']),
      pageCount: json['pageCount'] != null
          ? _parseInt(json['pageCount'])
          : null,
      coverImageUrl: json['coverImageUrl'],
      coverImagePublicId: json['coverImagePublicId'],
      publisher: json['publisher'],
      publishYear: json['publishYear'] != null
          ? _parseInt(json['publishYear'])
          : null,
      isbn: json['isbn'],
      downloadCount: _parseInt(json['downloadCount']),
      viewCount: _parseInt(json['viewCount']),
      isPublic: json['isPublic'] ?? true,
      uploadedBy: json['uploadedBy'] is String
          ? json['uploadedBy']
          : (json['uploadedBy'] is Map
                ? (json['uploadedBy']['_id'] ?? '')
                : ''),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Get category ID (whether category is String or BookCategory object)
  String get categoryId {
    if (category is cat.BookCategory) {
      return (category as cat.BookCategory).id;
    }
    return category.toString();
  }

  // Get category name for display
  String get categoryLabel {
    if (category is cat.BookCategory) {
      return (category as cat.BookCategory).name;
    }
    // Fallback for old string categories
    return categoryLabelLegacy;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'author': author,
      'translator': translator,
      'description': description,
      'category': category is cat.BookCategory
          ? (category as cat.BookCategory).id
          : category,
      'tags': tags,
      'bookLanguage': bookLanguage,
      'cloudinaryPublicId': cloudinaryPublicId,
      'cloudinaryUrl': cloudinaryUrl,
      'cloudinarySecureUrl': cloudinarySecureUrl,
      'fileSize': fileSize,
      'pageCount': pageCount,
      'coverImageUrl': coverImageUrl,
      'coverImagePublicId': coverImagePublicId,
      'publisher': publisher,
      'publishYear': publishYear,
      'isbn': isbn,
      'downloadCount': downloadCount,
      'viewCount': viewCount,
      'isPublic': isPublic,
      'uploadedBy': uploadedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper method to safely parse int
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  // Formatted file size
  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Category label in Vietnamese (legacy fallback)
  String get categoryLabelLegacy {
    final catStr = category.toString();
    switch (catStr) {
      case 'sutra':
        return 'Kinh điển';
      case 'commentary':
        return 'Luận giải';
      case 'biography':
        return 'Tiểu sử, truyện';
      case 'practice':
        return 'Hướng dẫn tu tập';
      case 'dharma-talk':
        return 'Pháp thoại';
      case 'history':
        return 'Lịch sử Phật giáo';
      case 'philosophy':
        return 'Triết học';
      default:
        return 'Khác';
    }
  }

  // Language label
  String get languageLabel {
    switch (bookLanguage) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      case 'pi':
        return 'Pāli';
      case 'sa':
        return 'Sanskrit';
      default:
        return bookLanguage;
    }
  }
}
