import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_providers.dart';
import '../widgets/audio_player_widget.dart';
import '../../data/models/audio.dart';

class AudioLibraryPage extends ConsumerStatefulWidget {
  const AudioLibraryPage({super.key});

  @override
  ConsumerState<AudioLibraryPage> createState() => _AudioLibraryPageState();
}

class _AudioLibraryPageState extends ConsumerState<AudioLibraryPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final audiosAsync = ref.watch(audiosProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư Viện Âm Thanh'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm audio...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Categories
          categoriesAsync.when(
            data: (categories) => SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Tất cả'),
                        selected: selectedCategory == null,
                        onSelected: (_) {
                          ref.read(selectedCategoryProvider.notifier).state =
                              null;
                        },
                      ),
                    );
                  }

                  final category = categories[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category.label),
                      selected: selectedCategory == category.value,
                      onSelected: (_) {
                        ref
                            .read(selectedCategoryProvider.notifier)
                            .state = selectedCategory == category.value
                            ? null
                            : category.value;
                      },
                    ),
                  );
                },
              ),
            ),
            loading: () => const SizedBox(height: 50),
            error: (error, stack) => const SizedBox(height: 50),
          ),

          const Divider(),

          // Audio list
          Expanded(
            child: audiosAsync.when(
              data: (audios) {
                if (audios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.music_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy audio',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: audios.length,
                  itemBuilder: (context, index) {
                    final audio = audios[index];
                    return _AudioListTile(audio: audio);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải dữ liệu',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(audiosProvider);
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: const AudioPlayerWidget(),
    );
  }
}

class _AudioListTile extends ConsumerWidget {
  final Audio audio;

  const _AudioListTile({required this.audio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAudio = ref.watch(currentAudioProvider);
    final isPlaying =
        currentAudio?.id == audio.id &&
        ref.watch(playerStateProvider).isPlaying;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          _getCategoryIcon(audio.category),
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(audio.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (audio.artist != null)
            Text(audio.artist!, maxLines: 1, overflow: TextOverflow.ellipsis),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                audio.durationFormatted,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.play_circle_outline,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                '${audio.playCount}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
          size: 40,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: () {
          if (isPlaying) {
            ref.read(audioPlayerProvider).pause();
          } else {
            ref.playAudio(audio);
          }
        },
      ),
      onTap: () {
        ref.playAudio(audio);
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'sutra':
        return Icons.menu_book;
      case 'mantra':
        return Icons.auto_fix_high;
      case 'dharma-talk':
        return Icons.mic;
      case 'meditation':
        return Icons.self_improvement;
      case 'chanting':
        return Icons.music_note;
      case 'music':
        return Icons.library_music;
      default:
        return Icons.audio_file;
    }
  }
}
