import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/user_providers.dart';
import '../providers/admin_providers.dart';
import '../../../auth/data/models/user.dart';
import 'admin_user_form_page.dart';

class AdminUsersListPage extends ConsumerStatefulWidget {
  const AdminUsersListPage({super.key});

  @override
  ConsumerState<AdminUsersListPage> createState() => _AdminUsersListPageState();
}

class _AdminUsersListPageState extends ConsumerState<AdminUsersListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(userSearchQueryProvider);
    final selectedRole = ref.watch(userSelectedRoleProvider);
    final isActiveFilter = ref.watch(userIsActiveFilterProvider);
    final currentPage = ref.watch(userCurrentPageProvider);
    final sortBy = ref.watch(userSortByProvider);
    final sortOrder = ref.watch(userSortOrderProvider);

    final params = AdminUsersParams(
      role: selectedRole,
      search: searchQuery.isEmpty ? null : searchQuery,
      isActive: isActiveFilter,
      page: currentPage,
      limit: 20,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    final usersAsync = ref.watch(adminUsersProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Người Dùng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminUsersProvider);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminUserFormPage()),
          );
          if (result == true) {
            ref.invalidate(adminUsersProvider);
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm người dùng'),
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
                    hintText: 'Tìm kiếm người dùng...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(userSearchQueryProvider.notifier).state =
                                  '';
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(userSearchQueryProvider.notifier).state = value;
                    ref.read(userCurrentPageProvider.notifier).state = 1;
                  },
                ),
                const SizedBox(height: 12),
                // Filters Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Role Filter - Ẩn vì chỉ có 1 role
                      // DropdownButton<String?>(
                      //   value: selectedRole,
                      //   hint: const Text('Vai trò'),
                      //   items: const [
                      //     DropdownMenuItem(value: null, child: Text('Tất cả')),
                      //     DropdownMenuItem(value: 'USER', child: Text('User')),
                      //   ],
                      //   onChanged: (value) {
                      //     ref.read(userSelectedRoleProvider.notifier).state =
                      //         value;
                      //     ref.read(userCurrentPageProvider.notifier).state = 1;
                      //   },
                      // ),
                      const SizedBox(width: 12),
                      // Active Filter
                      DropdownButton<bool?>(
                        value: isActiveFilter,
                        hint: const Text('Trạng thái'),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Tất cả')),
                          DropdownMenuItem(
                            value: true,
                            child: Text('Hoạt động'),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text('Bị khóa'),
                          ),
                        ],
                        onChanged: (value) {
                          ref.read(userIsActiveFilterProvider.notifier).state =
                              value;
                          ref.read(userCurrentPageProvider.notifier).state = 1;
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
                          DropdownMenuItem(value: 'name', child: Text('Tên')),
                          DropdownMenuItem(
                            value: 'email',
                            child: Text('Email'),
                          ),
                          DropdownMenuItem(
                            value: 'lastLoginAt',
                            child: Text('Lần đăng nhập'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            ref.read(userSortByProvider.notifier).state = value;
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
                          ref.read(userSortOrderProvider.notifier).state =
                              sortOrder == 'asc' ? 'desc' : 'asc';
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Users List
          Expanded(
            child: usersAsync.when(
              data: (data) {
                final users =
                    (data['users'] as List?)
                        ?.map((u) => User.fromJson(u))
                        .toList() ??
                    [];
                final total = (data['total'] as int?) ?? 0;
                final totalPages = (data['totalPages'] as int?) ?? 1;

                if (users.isEmpty) {
                  return const Center(child: Text('Không có người dùng nào'));
                }

                return Column(
                  children: [
                    // Stats
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Tìm thấy $total người dùng',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    // List
                    Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _UserListTile(user: user);
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
                                                userCurrentPageProvider
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
                                                userCurrentPageProvider
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
                        ref.invalidate(adminUsersProvider);
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
    );
  }
}

class _UserListTile extends ConsumerWidget {
  final User user;

  const _UserListTile({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role.value),
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildBadge(
                  context,
                  user.role.displayName,
                  _getRoleColor(user.role.value),
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  context,
                  user.isActive ? 'Hoạt động' : 'Bị khóa',
                  user.isActive ? Colors.green : Colors.red,
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Ngày tạo',
                  DateFormat('dd/MM/yyyy HH:mm').format(user.createdAt),
                ),
                if (user.lastLoginAt != null)
                  _buildInfoRow(
                    'Lần đăng nhập cuối',
                    DateFormat('dd/MM/yyyy HH:mm').format(user.lastLoginAt!),
                  ),
                _buildInfoRow('Tổng bài đọc', '${user.stats.totalReadings}'),
                _buildInfoRow(
                  'Thời gian đọc',
                  '${user.stats.totalReadingTime} phút',
                ),
                _buildInfoRow('Chuỗi ngày', '${user.stats.streakDays} ngày'),
                const SizedBox(height: 16),
                // Action buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Ẩn nút đổi vai trò vì chỉ có 1 role
                    // ElevatedButton.icon(
                    //   onPressed: () => _showRoleDialog(context, ref),
                    //   icon: const Icon(Icons.admin_panel_settings, size: 16),
                    //   label: const Text('Đổi vai trò'),
                    //   style: ElevatedButton.styleFrom(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 12,
                    //       vertical: 8,
                    //     ),
                    //   ),
                    // ),
                    ElevatedButton.icon(
                      onPressed: () => _toggleUserStatus(context, ref),
                      icon: Icon(
                        user.isActive ? Icons.block : Icons.check_circle,
                        size: 16,
                      ),
                      label: Text(user.isActive ? 'Khóa' : 'Mở khóa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user.isActive
                            ? Colors.orange
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToEditUser(context, ref),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Sửa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _showDeleteDialog(context, ref),
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Xóa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'VIP_USER':
        return Colors.purple;
      case 'PREMIUM_USER':
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }

  Future<void> _navigateToEditUser(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminUserFormPage(user: user)),
    );

    if (result == true) {
      ref.invalidate(adminUsersProvider);
    }
  }

  Future<void> _toggleUserStatus(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.isActive ? 'Khóa người dùng?' : 'Mở khóa người dùng?'),
        content: Text(
          user.isActive
              ? 'Người dùng sẽ không thể đăng nhập vào hệ thống.'
              : 'Người dùng sẽ có thể đăng nhập lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: user.isActive ? Colors.red : Colors.green,
            ),
            child: Text(user.isActive ? 'Khóa' : 'Mở khóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final apiClient = ref.read(userApiClientProvider);
        final token = ref.read(accessTokenProvider);

        if (token == null) {
          throw Exception('No admin token');
        }

        await apiClient.updateUserStatus(
          id: user.id,
          isActive: !user.isActive,
          token: token,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                user.isActive ? 'Đã khóa người dùng' : 'Đã mở khóa người dùng',
              ),
            ),
          );
          ref.invalidate(adminUsersProvider);
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

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa người dùng "${user.name}"?'),
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
        final apiClient = ref.read(userApiClientProvider);
        final token = ref.read(accessTokenProvider);

        if (token == null) {
          throw Exception('No admin token');
        }

        await apiClient.deleteUser(user.id, token: token);

        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đã xóa người dùng')));
          ref.invalidate(adminUsersProvider);
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
