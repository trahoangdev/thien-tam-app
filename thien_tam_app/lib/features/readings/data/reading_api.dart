import '../../../core/http.dart';
import 'models/reading.dart';

class ReadingApi {
  Future<List<Reading>> getToday() async {
    final res = await dio.get('/readings/today');
    final items = (res.data['items'] as List)
        .map((e) => Reading.fromJson(e))
        .toList();
    return items;
  }

  Future<List<Reading>> getByDate(DateTime d) async {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final da = d.day.toString().padLeft(2, '0');
    final res = await dio.get('/readings/$y-$m-$da');
    final items = (res.data['items'] as List)
        .map((e) => Reading.fromJson(e))
        .toList();
    return items;
  }

  Future<List<Reading>> getMonth(int year, int month) async {
    final res = await dio.get(
      '/readings/month/${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}',
    );
    return (res.data['items'] as List).map((e) => Reading.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> search({
    String? query,
    String? topic,
    int page = 1,
  }) async {
    final res = await dio.get(
      '/readings',
      queryParameters: {
        if (query != null && query.isNotEmpty) 'query': query,
        if (topic != null && topic.isNotEmpty) 'topic': topic,
        'page': page,
      },
    );
    return res.data;
  }

  Future<Reading> getRandom() async {
    final res = await dio.get('/readings/random');
    return Reading.fromJson(res.data);
  }
}
