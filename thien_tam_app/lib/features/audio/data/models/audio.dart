class Audio {
  final String id;
  final String title;
  final String? description;
  final String? artist;
  final int? duration; // in seconds
  final String category;
  final List<String> tags;
  final String cloudinaryPublicId;
  final String cloudinaryUrl;
  final String cloudinarySecureUrl;
  final int? fileSize;
  final String? format;
  final int playCount;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;

  Audio({
    required this.id,
    required this.title,
    this.description,
    this.artist,
    this.duration,
    required this.category,
    required this.tags,
    required this.cloudinaryPublicId,
    required this.cloudinaryUrl,
    required this.cloudinarySecureUrl,
    this.fileSize,
    this.format,
    required this.playCount,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Audio.fromJson(Map<String, dynamic> json) {
    return Audio(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      artist: json['artist'] as String?,
      duration: json['duration']?.toInt(),
      category: json['category'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      cloudinaryPublicId: json['cloudinaryPublicId'] as String,
      cloudinaryUrl: json['cloudinaryUrl'] as String,
      cloudinarySecureUrl: json['cloudinarySecureUrl'] as String,
      fileSize: json['fileSize'] as int?,
      format: json['format'] as String?,
      playCount: json['playCount'] as int? ?? 0,
      isPublic: json['isPublic'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  String get streamUrl => cloudinarySecureUrl;

  String get durationFormatted {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get fileSizeFormatted {
    if (fileSize == null) return '--';
    if (fileSize! < 1024) return '${fileSize}B';
    if (fileSize! < 1024 * 1024)
      return '${(fileSize! / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class AudioCategory {
  final String value;
  final String label;
  final String description;

  AudioCategory({
    required this.value,
    required this.label,
    required this.description,
  });

  factory AudioCategory.fromJson(Map<String, dynamic> json) {
    return AudioCategory(
      value: json['value'] as String,
      label: json['label'] as String,
      description: json['description'] as String,
    );
  }
}
