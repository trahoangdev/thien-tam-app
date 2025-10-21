/// Request to create a new reading
class ReadingCreateRequest {
  final DateTime date;
  final String title;
  final String body;
  final List<String> topicSlugs;
  final List<String> keywords;
  final String source;
  final String lang;

  ReadingCreateRequest({
    required this.date,
    required this.title,
    required this.body,
    this.topicSlugs = const [],
    this.keywords = const [],
    this.source = 'Admin',
    this.lang = 'vi',
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'title': title,
      'body': body,
      'topicSlugs': topicSlugs,
      'keywords': keywords,
      'source': source,
      'lang': lang,
    };
  }
}
