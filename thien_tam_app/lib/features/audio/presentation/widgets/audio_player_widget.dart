import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:audioplayers/audioplayers.dart' show AudioPlayer, UrlSource;
import '../providers/audio_providers.dart';
import '../../data/models/audio.dart';

class AudioPlayerWidget extends ConsumerStatefulWidget {
  const AudioPlayerWidget({super.key});

  @override
  ConsumerState<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends ConsumerState<AudioPlayerWidget> {
  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = ref.read(audioPlayerProvider);
    _initializePlayer();
  }

  void _initializePlayer() {
    // Set release mode to loop if needed
    _player.setReleaseMode(audioplayers.ReleaseMode.stop);

    // Listen to player state
    _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        final currentState = ref.read(playerStateProvider);
        ref.read(playerStateProvider.notifier).state = currentState.copyWith(
          isPlaying: state == audioplayers.PlayerState.playing,
        );
      }
    });

    // Listen to duration
    _player.onDurationChanged.listen((duration) {
      if (mounted) {
        final currentState = ref.read(playerStateProvider);
        ref.read(playerStateProvider.notifier).state = currentState.copyWith(
          duration: duration,
        );
      }
    });

    // Listen to position
    _player.onPositionChanged.listen((position) {
      if (mounted) {
        final currentState = ref.read(playerStateProvider);
        ref.read(playerStateProvider.notifier).state = currentState.copyWith(
          position: position,
        );
      }
    });

    // Listen to completion
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        ref.read(playerStateProvider.notifier).state = AudioPlayerState(
          isPlaying: false,
          position: Duration.zero,
          duration: ref.read(playerStateProvider).duration,
        );
      }
    });
  }

  Future<void> _pauseAudio() async {
    await _player.pause();
  }

  Future<void> _resumeAudio() async {
    await _player.resume();
  }

  Future<void> _stopAudio() async {
    await _player.stop();
    ref.read(currentAudioProvider.notifier).state = null;
    ref.read(playerStateProvider.notifier).state = AudioPlayerState(
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
    );
  }

  Future<void> _seekTo(Duration position) async {
    await _player.seek(position);
  }

  Future<void> _toggleLoop() async {
    final currentState = ref.read(playerStateProvider);
    final newLoopState = !currentState.isLooping;

    // Update state
    ref.read(playerStateProvider.notifier).state = currentState.copyWith(
      isLooping: newLoopState,
    );

    // Set player release mode
    await _player.setReleaseMode(
      newLoopState
          ? audioplayers.ReleaseMode.loop
          : audioplayers.ReleaseMode.stop,
    );
  }

  @override
  void dispose() {
    // Don't dispose player here, it's managed by provider
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAudio = ref.watch(currentAudioProvider);
    final playerState = ref.watch(playerStateProvider);

    if (currentAudio == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: playerState.position.inSeconds.toDouble(),
                max: playerState.duration.inSeconds.toDouble().clamp(
                  1,
                  double.infinity,
                ),
                onChanged: (value) {
                  _seekTo(Duration(seconds: value.toInt()));
                },
              ),
            ),

            // Player controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Audio info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentAudio.title,
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (currentAudio.artist != null)
                          Text(
                            currentAudio.artist!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          '${_formatDuration(playerState.position)} / ${_formatDuration(playerState.duration)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),

                  // Loop button
                  IconButton(
                    icon: Icon(
                      playerState.isLooping ? Icons.repeat_one : Icons.repeat,
                      color: playerState.isLooping
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade600,
                    ),
                    onPressed: _toggleLoop,
                    tooltip: playerState.isLooping ? 'Tắt lặp lại' : 'Lặp lại',
                  ),

                  // Play/Pause button
                  IconButton(
                    icon: Icon(
                      playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 32,
                    ),
                    onPressed: () {
                      if (playerState.isPlaying) {
                        _pauseAudio();
                      } else {
                        _resumeAudio();
                      }
                    },
                  ),

                  // Stop button
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: _stopAudio,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// Export play function for external use
extension AudioPlayerExtension on WidgetRef {
  Future<void> playAudio(Audio audio) async {
    final player = read(audioPlayerProvider);
    final service = read(audioServiceProvider);

    try {
      // Set current audio
      read(currentAudioProvider.notifier).state = audio;

      // Increment play count
      service.incrementPlayCount(audio.id);

      // Play audio
      await player.play(UrlSource(audio.streamUrl));
    } catch (e) {
      print('Error playing audio: $e');
    }
  }
}
