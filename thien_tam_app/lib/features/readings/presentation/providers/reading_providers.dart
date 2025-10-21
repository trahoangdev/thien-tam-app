import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/reading_api.dart';
import '../../data/reading_repo.dart';
import '../../data/models/reading.dart';
import '../../../../main.dart';

final apiProvider = Provider((ref) => ReadingApi());

final repoProvider = Provider(
  (ref) => ReadingRepo(ref.read(apiProvider), ref.read(cacheProvider)),
);

final todayProvider = FutureProvider<List<Reading>>((ref) {
  return ref.read(repoProvider).today();
});

final readingByDateProvider = FutureProvider.family<List<Reading>, DateTime>((
  ref,
  date,
) {
  return ref.read(repoProvider).getByDate(date);
});

final monthReadingsProvider = FutureProvider.family<List<Reading>, (int, int)>((
  ref,
  params,
) {
  return ref.read(repoProvider).getMonth(params.$1, params.$2);
});

final randomReadingProvider = FutureProvider<Reading>((ref) {
  return ref.read(repoProvider).getRandom();
});
