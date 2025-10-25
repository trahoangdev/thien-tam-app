import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/user_api_client.dart';
import '../../../auth/data/models/user.dart';
import 'admin_providers.dart';

// User API Client Provider
final userApiClientProvider = Provider<UserApiClient>((ref) {
  return UserApiClient();
});

// Admin Users List Provider
final adminUsersProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, AdminUsersParams>((ref, params) async {
      final apiClient = ref.read(userApiClientProvider);
      final token = ref.read(accessTokenProvider);

      if (token == null) {
        throw Exception('No admin token found');
      }

      return await apiClient.getAllUsers(
        role: params.role,
        search: params.search,
        isActive: params.isActive,
        page: params.page,
        limit: params.limit,
        sortBy: params.sortBy,
        sortOrder: params.sortOrder,
        token: token,
      );
    });

// User Detail Provider
final userDetailProvider = FutureProvider.autoDispose.family<User, String>((
  ref,
  id,
) async {
  final apiClient = ref.read(userApiClientProvider);
  final token = ref.read(accessTokenProvider);

  if (token == null) {
    throw Exception('No admin token found');
  }

  return await apiClient.getUserById(id, token: token);
});

// User Stats Provider
final userStatsProvider = FutureProvider.autoDispose((ref) async {
  final apiClient = ref.read(userApiClientProvider);
  final token = ref.read(accessTokenProvider);

  if (token == null) {
    throw Exception('No admin token found');
  }

  return await apiClient.getUserStats(token: token);
});

// User Filter State Providers
final userSearchQueryProvider = StateProvider<String>((ref) => '');
final userSelectedRoleProvider = StateProvider<String?>((ref) => null);
final userIsActiveFilterProvider = StateProvider<bool?>((ref) => null);
final userCurrentPageProvider = StateProvider<int>((ref) => 1);
final userSortByProvider = StateProvider<String>((ref) => 'createdAt');
final userSortOrderProvider = StateProvider<String>((ref) => 'desc');

// Parameters class for admin users
class AdminUsersParams {
  final String? role;
  final String? search;
  final bool? isActive;
  final int page;
  final int limit;
  final String sortBy;
  final String sortOrder;

  AdminUsersParams({
    this.role,
    this.search,
    this.isActive,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'desc',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AdminUsersParams &&
        other.role == role &&
        other.search == search &&
        other.isActive == isActive &&
        other.page == page &&
        other.limit == limit &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode {
    return Object.hash(role, search, isActive, page, limit, sortBy, sortOrder);
  }
}
