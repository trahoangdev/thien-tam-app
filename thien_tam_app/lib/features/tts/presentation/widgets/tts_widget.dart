import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/tts_providers.dart';
import 'voice_selector_widget.dart';

class TTSWidget extends ConsumerWidget {
  final String text;
  final String? voiceId;
  final bool showControls;
  final bool autoPlay;
  final bool showVoiceSelector;

  const TTSWidget({
    super.key,
    required this.text,
    this.voiceId,
    this.showControls = true,
    this.autoPlay = false,
    this.showVoiceSelector = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerStateProvider);
    final ttsStatus = ref.watch(ttsServiceStatusProvider);

    return ttsStatus.when(
      data: (isConfigured) {
        if (!isConfigured) {
          return const SizedBox.shrink();
        }

        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.volume_up_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Đọc bằng giọng nói',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (audioState.isLoading) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Đang tạo giọng nói...',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (audioState.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Theme.of(context).colorScheme.error,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              audioState.error!,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(audioPlayerStateProvider.notifier)
                                  .clearError();
                            },
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Play/Pause button
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: audioState.isPlaying
                                  ? () => ref
                                        .read(audioPlayerStateProvider.notifier)
                                        .pauseAudio()
                                  : audioState.isPaused
                                  ? () => ref
                                        .read(audioPlayerStateProvider.notifier)
                                        .resumeAudio()
                                  : () => ref
                                        .read(audioPlayerStateProvider.notifier)
                                        .speakText(text, voiceId: voiceId),
                              icon: Icon(
                                audioState.isPlaying
                                    ? Icons.pause_rounded
                                    : audioState.isPaused
                                    ? Icons.play_arrow_rounded
                                    : audioState.currentAudioPath != null
                                    ? Icons.replay_rounded
                                    : Icons.play_arrow_rounded,
                                size: 28,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Status text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  audioState.isPlaying
                                      ? 'Đang phát...'
                                      : audioState.isPaused
                                      ? 'Tạm dừng'
                                      : audioState.currentAudioPath != null
                                      ? 'Đã hoàn thành'
                                      : 'Nhấn để nghe',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                                if (audioState.isPlaying ||
                                    audioState.isPaused ||
                                    audioState.currentAudioPath != null)
                                  Text(
                                    'Phật pháp vô biên',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                              ],
                            ),
                          ),

                          // Stop button (only show when playing or paused)
                          if (audioState.isPlaying || audioState.isPaused)
                            IconButton(
                              onPressed: () => ref
                                  .read(audioPlayerStateProvider.notifier)
                                  .stopAudio(),
                              icon: Icon(
                                Icons.stop_rounded,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              tooltip: 'Dừng',
                            ),
                        ],
                      ),
                    ),
                  ],

                  if (showControls &&
                      !audioState.isLoading &&
                      audioState.error == null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tính năng này giúp bạn nghe bài đọc khi mắt đã mỏi',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Voice Selector
                  if (showVoiceSelector) ...[
                    const SizedBox(height: 16),
                    const VoiceSelectorWidget(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}

// Compact TTS button for use in app bars or smaller spaces
class TTSButton extends ConsumerWidget {
  final String text;
  final String? voiceId;
  final bool showLabel;

  const TTSButton({
    super.key,
    required this.text,
    this.voiceId,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerStateProvider);
    final ttsStatus = ref.watch(ttsServiceStatusProvider);

    return ttsStatus.when(
      data: (isConfigured) {
        if (!isConfigured) return const SizedBox.shrink();

        return Wrap(
          alignment: WrapAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: audioState.isLoading
                    ? null
                    : audioState.isPlaying
                    ? () => ref
                          .read(audioPlayerStateProvider.notifier)
                          .pauseAudio()
                    : audioState.isPaused
                    ? () => ref
                          .read(audioPlayerStateProvider.notifier)
                          .resumeAudio()
                    : () => ref
                          .read(audioPlayerStateProvider.notifier)
                          .speakText(text, voiceId: voiceId),
                icon: audioState.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Icon(
                        audioState.isPlaying
                            ? Icons.pause_rounded
                            : audioState.isPaused
                            ? Icons.play_arrow_rounded
                            : audioState.currentAudioPath != null
                            ? Icons.replay_rounded
                            : Icons.volume_up_rounded,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 24,
                      ),
                tooltip: audioState.isPlaying
                    ? 'Tạm dừng'
                    : audioState.isPaused
                    ? 'Tiếp tục'
                    : audioState.currentAudioPath != null
                    ? 'Phát lại'
                    : 'Đọc bằng giọng nói',
              ),
            ),
            if (showLabel) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  audioState.isPlaying
                      ? 'Đang phát'
                      : audioState.isPaused
                      ? 'Tạm dừng'
                      : audioState.currentAudioPath != null
                      ? 'Hoàn thành'
                      : '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
