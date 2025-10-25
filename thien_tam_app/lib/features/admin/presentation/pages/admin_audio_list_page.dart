import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_providers.dart';
import '../providers/admin_providers.dart';
import '../../../audio/data/models/audio.dart';
import 'admin_audio_form_page.dart';

class AdminAudioListPage extends ConsumerStatefulWidget {
  const AdminAudioListPage({super.key});

  @override
  ConsumerState<AdminAudioListPage> createState() => _AdminAudioListPageState();
}

class _AdminAudioListPageState extends ConsumerState<AdminAudioListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(audioSearchQueryProvider);
    final selectedCategory = ref.watch(audioSelectedCategoryProvider);
    final isPublicFilter = ref.watch(audioIsPublicFilterProvider);
    final currentPage = ref.watch(audioCurrentPageProvider);
    final sortBy = ref.watch(audioSortByProvider);
    final sortOrder = ref.watch(audioSortOrderProvider);

    final params = AdminAudiosParams(
      category: selectedCategory,
      search: searchQuery.isEmpty ? null : searchQuery,
      isPublic: isPublicFilter,
      page: currentPage,
      limit: 20,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final audiosAsync = ref.watch(adminAudiosProvider(params));
    final categoriesAsync = ref.watch(audioCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Audio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminAudiosProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm audio...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                      .read(audioSearchQueryProvider.notifier)
                                      .state =
                                  '';
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(audioSearchQueryProvider.notifier).state = value;
                    ref.read(audioCurrentPageProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: 12),
                // Filters Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Category Filter
                      categoriesAsync.when(
                        data: (categories) => DropdownButton<String?>(
                          value: selectedCategory,
                          hint: const Text('Danh mục'),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Tất cả'),
                            ),
                            ...categories.map(
                              (cat) => DropdownMenuItem(
                                value: cat.value,
                                child: Text(cat.label),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            ref
                                    .read(
                                      audioSelectedCategoryProvider.notifier,
                                    )
                                    .state =
                                value;
                            ref.read(audioCurrentPageProvider.notifier).state =
                                1;
                          },
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Lỗi'),
                      ),
                      const SizedBox(width: 12),
                      // Public Filter
                      DropdownButton<bool?>(
                        value: isPublicFilter,
                        hint: const Text('Trạng thái'),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tất cả')),
                          DropdownMenuItem(
                            value: true,
                            child: Text('Công khai'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Riêng tư'),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(audioIsPublicFilterProvider.notifier).state =
                              value;
                          ref.read(audioCurrentPageProvider.notifier).state = 1;
                        },
                      ),
                      const SizedBox(width: 12),
                      // Sort By
                      DropdownButton<String>(
                        value: sortBy,
                        items: const [
                          DropdownMenuItem(
                            value: 'createdAt',
                            child: Text('Ngày tạo'),
                          ),
                          DropdownMenuItem(
                            value: 'title',
                            child: Text('Tiêu đề'),
                          ),
                          DropdownMenuItem(
                            value: 'playCount',
                            child: Text('Lượt nghe'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(audioSortByProvider.notifier).state =
                                value;
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      // Sort Order
                      IconButton(
                        icon: Icon(
                          sortOrder == 'asc'
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                        ),
                        onPressed: () {
                          ref.read(audioSortOrderProvider.notifier).state =
                              sortOrder == 'asc' ? 'desc' : 'asc';
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Audio List
          Expanded(
            child: audiosAsync.when(
              data: (data) {
                final audios =
                    (data['audios'] as List?)
                        ?.map((a) => Audio.fromJson(a))
                        .toList() ??
                    [];
                final total = (data['total'] as int?) ?? 0;
                final totalPages = (data['totalPages'] as int?) ?? 1;

                if (audios.isEmpty) {
                  return const Center(child: Text('Không có audio nào'));
                }

                return Column(
                  children: [
                    // Stats
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Tìm thấy $total audio',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    // List
                    Expanded(
                      child: ListView.builder(
                        itemCount: audios.length,
                        itemBuilder: (context, index) {
                          final audio = audios[index];
                          return _AudioListTile(audio: audio);
                        },
                      ),
                    ),
                    // Pagination
                    if (totalPages > 1)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: currentPage > 1
                                  ? () {
                                      ref
                                              .read(
                                                audioCurrentPageProvider
                                                    .notifier,
                                              )
                                              .state =
                                          currentPage - 1;
                                    }
                                  : null,
                            ),
                            Text(
                              'Trang $currentPage / $totalPages',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: currentPage < totalPages
                                  ? () {
                                      ref
                                              .read(
                                                audioCurrentPageProvider
                                                    .notifier,
                                              )
                                              .state =
                                          currentPage + 1;
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Lỗi: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(adminAudiosProvider);
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminAudioFormPage()),
          ).then((_) {
            // Refresh list after adding
            ref.invalidate(adminAudiosProvider);
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm Audio'),
      ),
    );
  }
}

class _AudioListTile extends ConsumerWidget {
  final Audio audio;

  const _AudioListTile({required this.audio});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            _getCategoryIcon(audio.category),
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          audio.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (audio.artist != null) Text(audio.artist!),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  audio.isPublic ? Icons.public : Icons.lock,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  audio.isPublic ? 'Công khai' : 'Riêng tư',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.play_arrow, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${audio.playCount} lượt',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminAudioFormPage(audio: audio),
                ),
              ).then((_) {
                ref.invalidate(adminAudiosProvider);
              });
            } else if (value == 'delete') {
              _showDeleteDialog(context, ref);
            }
          },
        ),
      ),
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
        return Icons.audiotrack;
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa audio "${audio.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final apiClient = ref.read(audioApiClientProvider);
        final token = ref.read(accessTokenProvider);

        if (token == null) {
          throw Exception('No admin token');
        }

        await apiClient.deleteAudio(audio.id, token: token);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã xóa audio')));
          ref.invalidate(adminAudiosProvider);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
        }
      }
    }
  }
}
