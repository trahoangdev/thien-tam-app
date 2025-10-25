import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/tts_service.dart';
import '../../../../core/settings_providers.dart';

// Provider for available voices
final appVoicesProvider = FutureProvider<List<AppVoice>>((ref) async {
  final ttsService = TTSService();
  return await ttsService.getAppVoices();
});

class VoiceSelectorWidget extends ConsumerWidget {
  const VoiceSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVoiceId = ref.watch(ttsVoiceIdProvider);
    final voicesAsync = ref.watch(appVoicesProvider);

    return voicesAsync.when(
      data: (voices) {
        if (voices.isEmpty) {
          return ListTile(
            leading: const Icon(Icons.record_voice_over),
            title: const Text('Giọng đọc'),
            subtitle: const Text('Không có giọng đọc khả dụng'),
            trailing: const Icon(Icons.error_outline, color: Colors.red),
          );
        }

        final selectedVoice = voices.firstWhere(
          (v) => v.id == selectedVoiceId,
          orElse: () => voices.first,
        );

        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.record_voice_over),
              title: const Text('Giọng đọc'),
              subtitle: Text(selectedVoice.name),
              trailing: TextButton(
                onPressed: () => _showVoiceSelector(context, ref, voices),
                child: const Text('Thay đổi'),
              ),
            ),
            // Voice info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Text(
                        selectedVoice.genderIcon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              selectedVoice.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selectedVoice.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedVoice.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Mặc định',
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => ListTile(
        leading: const Icon(Icons.record_voice_over),
        title: const Text('Giọng đọc'),
        subtitle: const Text('Đang tải...'),
        trailing: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, stack) => ListTile(
        leading: const Icon(Icons.record_voice_over),
        title: const Text('Giọng đọc'),
        subtitle: Text('Lỗi: $error'),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.invalidate(appVoicesProvider),
        ),
      ),
    );
  }

  void _showVoiceSelector(
    BuildContext context,
    WidgetRef ref,
    List<AppVoice> voices,
  ) {
    final selectedVoiceId = ref.read(ttsVoiceIdProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.record_voice_over),
                  const SizedBox(width: 12),
                  const Text(
                    'Chọn giọng đọc',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Voice list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: voices.length,
                itemBuilder: (context, index) {
                  final voice = voices[index];
                  final isSelected = voice.id == selectedVoiceId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[200],
                      child: Text(
                        voice.genderIcon,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          voice.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (voice.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Mặc định',
                              style: TextStyle(
                                fontSize: 9,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Text(
                      voice.description,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    selected: isSelected,
                    onTap: () async {
                      // Update voice selection
                      ref.read(ttsVoiceIdProvider.notifier).state = voice.id;
                      final settingsService = ref.read(settingsServiceProvider);
                      await settingsService.setTTSVoiceId(voice.id);

                      // Show feedback
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã chọn giọng: ${voice.name}'),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
