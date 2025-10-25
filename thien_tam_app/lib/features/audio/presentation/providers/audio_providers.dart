import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../data/audio_service.dart';
import '../../data/models/audio.dart';

// Audio service provider
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

// Audio player provider
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  return AudioPlayer();
});

// Categories provider
final categoriesProvider = FutureProvider<List<AudioCategory>>((ref) async {
  final service = ref.read(audioServiceProvider);
  return service.getCategories();
});

// Selected category provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// Audios list provider (with filters)
final audiosProvider = FutureProvider<List<Audio>>((ref) async {
  final service = ref.read(audioServiceProvider);
  final category = ref.watch(selectedCategoryProvider);
  final search = ref.watch(searchQueryProvider);

  return service.getAudios(
    category: category,
    search: search.isEmpty ? null : search,
    isPublic: true,
    page: 1,
    limit: 50,
    sortBy: 'createdAt',
    sortOrder: 'desc',
  );
});

// Popular audios provider
final popularAudiosProvider = FutureProvider<List<Audio>>((ref) async {
  final service = ref.read(audioServiceProvider);
  return service.getPopularAudios(limit: 10);
});

// Currently playing audio provider
final currentAudioProvider = StateProvider<Audio?>((ref) => null);

// Player state provider
class AudioPlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final bool isLooping;

  AudioPlayerState({
    required this.isPlaying,
    required this.position,
    required this.duration,
    this.isLooping = false,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    bool? isLooping,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isLooping: isLooping ?? this.isLooping,
    );
  }
}

final playerStateProvider = StateProvider<AudioPlayerState>((ref) {
  return AudioPlayerState(
    isPlaying: false,
    position: Duration.zero,
    duration: Duration.zero,
    isLooping: false,
  );
});
