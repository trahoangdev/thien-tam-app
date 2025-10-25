class BookCategory {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String icon;
  final String color;
  final int displayOrder;
  final bool isActive;
  final int bookCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookCategory({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    required this.icon,
    required this.color,
    required this.displayOrder,
    required this.isActive,
    required this.bookCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    return BookCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['nameEn'],
      description: json['description'],
      icon: json['icon'] ?? '📚',
      color: json['color'] ?? '#8B7355',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] ?? true,
      bookCount: (json['bookCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'nameEn': nameEn,
      'description': description,
      'icon': icon,
      'color': color,
      'displayOrder': displayOrder,
      'isActive': isActive,
      'bookCount': bookCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // For creating/updating category
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      if (nameEn != null) 'nameEn': nameEn,
      if (description != null) 'description': description,
      'icon': icon,
      'color': color,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }

  BookCategory copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? description,
    String? icon,
    String? color,
    int? displayOrder,
    bool? isActive,
    int? bookCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      bookCount: bookCount ?? this.bookCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BookCategory(id: $id, name: $name, nameEn: $nameEn, icon: $icon, bookCount: $bookCount)';
  }
}
