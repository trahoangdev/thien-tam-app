import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/history_service.dart';
import '../../../../main.dart';

// History service provider
final historyServiceProvider = Provider((ref) {
  return HistoryService(ref.read(cacheProvider));
});

// State provider to trigger UI refresh after history update
final historyRefreshProvider = StateProvider<int>((ref) => 0);
