/// Request to update an existing reading
class ReadingUpdateRequest {
  final String? title;
  final String? body;
  final List<String>? topicSlugs;
  final List<String>? keywords;
  final String? source;
  final String? lang;

  ReadingUpdateRequest({
    this.title,
    this.body,
    this.topicSlugs,
    this.keywords,
    this.source,
    this.lang,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (body != null) map['body'] = body;
    if (topicSlugs != null) map['topicSlugs'] = topicSlugs;
    if (keywords != null) map['keywords'] = keywords;
    if (source != null) map['source'] = source;
    if (lang != null) map['lang'] = lang;
    return map;
  }
}
