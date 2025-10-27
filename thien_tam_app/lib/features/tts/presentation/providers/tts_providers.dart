import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tts_service.dart';
import '../../../../core/settings_providers.dart';
import '../../data/sleep_mode_service.dart';

// TTS Service provider
final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService();
});

// Sleep Mode Service provider
final sleepModeServiceProvider = ChangeNotifierProvider<SleepModeService>((
  ref,
) {
  return SleepModeService();
});

// TTS Service status provider
final ttsServiceStatusProvider = FutureProvider<bool>((ref) async {
  final ttsService = ref.watch(ttsServiceProvider);
  return await ttsService.checkServiceStatus();
});

// Available voices provider
final ttsVoicesProvider = FutureProvider<List<TTSVoice>>((ref) async {
  final ttsService = ref.watch(ttsServiceProvider);
  return await ttsService.getVoices();
});

// Available models provider
final ttsModelsProvider = FutureProvider<List<TTSModel>>((ref) async {
  final ttsService = ref.watch(ttsServiceProvider);
  return await ttsService.getModels();
});

// Audio player state provider
final audioPlayerStateProvider =
    StateNotifierProvider<AudioPlayerStateNotifier, AudioPlayerState>((ref) {
      return AudioPlayerStateNotifier(ref.watch(ttsServiceProvider), ref);
    });

class AudioPlayerState {
  final bool isPlaying;
  final bool isPaused;
  final String? currentAudioPath;
  final bool isLoading;
  final String? error;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isPaused = false,
    this.currentAudioPath,
    this.isLoading = false,
    this.error,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isPaused,
    String? currentAudioPath,
    bool? isLoading,
    String? error,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      currentAudioPath: currentAudioPath ?? this.currentAudioPath,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AudioPlayerStateNotifier extends StateNotifier<AudioPlayerState> {
  final TTSService _ttsService;
  final Ref _ref;

  AudioPlayerStateNotifier(this._ttsService, this._ref)
    : super(const AudioPlayerState()) {
    _initializeAudioPlayer();
  }

  Future<void> _initializeAudioPlayer() async {
    await _ttsService.initialize();

    // Set callback for audio completion
    _ttsService.setOnAudioComplete(() {
      // Update state when audio completes
      state = state.copyWith(
        isPlaying: false,
        isPaused: false,
        currentAudioPath: null,
      );
    });
  }

  // Convert text to speech and play
  Future<void> speakText(String text, {String? voiceId}) async {
    try {
      // Stop any currently playing audio first to prevent overlap
      if (state.isPlaying || state.isPaused) {
        await _ttsService.stopAudio();
      }

      state = state.copyWith(isLoading: true, error: null);

      // Get selected voice from settings
      final selectedVoiceId = _ref.read(ttsVoiceIdProvider);

      // Use Vietnamese voice settings optimized for Buddhist content
      final request = TTSRequest(
        text: text,
        voiceId: voiceId ?? selectedVoiceId, // Use selected voice from settings
        voiceSettings: TTSService.defaultVietnameseSettings,
      );

      final audioPath = await _ttsService.textToSpeech(request);

      if (audioPath != null) {
        final success = await _ttsService.playAudio(audioPath);
        if (success) {
          state = state.copyWith(
            isLoading: false,
            currentAudioPath: audioPath,
            isPlaying: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: 'Failed to play audio',
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to generate speech',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Error: $e');
    }
  }

  // Pause audio
  Future<void> pauseAudio() async {
    try {
      await _ttsService.pauseAudio();
      state = state.copyWith(isPaused: true, isPlaying: false);
    } catch (e) {
      state = state.copyWith(error: 'Error pausing audio: $e');
    }
  }

  // Resume audio
  Future<void> resumeAudio() async {
    try {
      await _ttsService.resumeAudio();
      state = state.copyWith(isPlaying: true, isPaused: false);
    } catch (e) {
      state = state.copyWith(error: 'Error resuming audio: $e');
    }
  }

  // Stop audio
  Future<void> stopAudio() async {
    try {
      await _ttsService.stopAudio();
      state = state.copyWith(
        isPlaying: false,
        isPaused: false,
        currentAudioPath: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Error stopping audio: $e');
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
