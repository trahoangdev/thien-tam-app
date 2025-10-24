class Reading {
  final String id;
  final DateTime date;
  final String title;
  final String? body; // Nullable - month API không trả về body
  final List<String> topicSlugs;
  final List<String> keywords;
  final String source;
  final String lang;

  Reading({
    required this.id,
    required this.date,
    required this.title,
    this.body, // Optional
    required this.topicSlugs,
    this.keywords = const [],
    this.source = 'Unknown',
    this.lang = 'vi',
  });

  factory Reading.fromJson(Map<String, dynamic> j) {
    // Normalize incoming date to device local day to avoid timezone drift
    final parsed = DateTime.parse(j['date']);
    final local = parsed.toLocal();
    final normalizedLocalDate = DateTime(local.year, local.month, local.day);

    return Reading(
      id: j['_id'] ?? '',
      date: normalizedLocalDate,
      title: j['title'] ?? '',
      body: j['body'], // Có thể null
      topicSlugs: List<String>.from(j['topicSlugs'] ?? []),
      keywords: List<String>.from(j['keywords'] ?? []),
      source: j['source'] ?? 'Unknown',
      lang: j['lang'] ?? 'vi',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date.toIso8601String(),
      'title': title,
      if (body != null) 'body': body, // Chỉ include nếu không null
      'topicSlugs': topicSlugs,
      'keywords': keywords,
      'source': source,
      'lang': lang,
    };
  }
}
