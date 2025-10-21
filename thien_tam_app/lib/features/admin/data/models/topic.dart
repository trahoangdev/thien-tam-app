class Topic {
  final String id;
  final String slug;
  final String name;
  final String description;
  final String color;
  final String icon;
  final bool isActive;
  final int readingCount;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Topic({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.readingCount,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['_id'] ?? json['id'] ?? '',
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      color: json['color'] ?? '#4CAF50',
      icon: json['icon'] ?? 'label',
      isActive: json['isActive'] ?? true,
      readingCount: json['readingCount'] ?? 0,
      sortOrder: json['sortOrder'] ?? 0,
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
      'id': id,
      'slug': slug,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'isActive': isActive,
      'readingCount': readingCount,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Topic copyWith({
    String? id,
    String? slug,
    String? name,
    String? description,
    String? color,
    String? icon,
    bool? isActive,
    int? readingCount,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Topic(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      readingCount: readingCount ?? this.readingCount,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Topic && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Topic(id: $id, slug: $slug, name: $name, isActive: $isActive)';
  }
}
