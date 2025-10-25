import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

// Enum for user roles with clear permissions
enum UserRole {
  guest('GUEST', 'Khách', 0),
  user('USER', 'Người dùng', 1);

  const UserRole(this.value, this.displayName, this.level);
  final String value;
  final String displayName;
  final int level; // Higher level = more permissions

  static UserRole fromString(String value) {
    switch (value) {
      case 'USER':
        return UserRole.user;
      case 'GUEST':
      default:
        return UserRole.guest;
    }
  }

  // Permission checks
  bool get canReadContent => level >= UserRole.guest.level;
  bool get canBookmark => level >= UserRole.user.level;
  bool get canViewHistory => level >= UserRole.user.level;
  bool get canUpdateProfile => level >= UserRole.user.level;
  bool get canManageContent => false; // Không có premium nữa
  bool get canManageUsers => false; // Không có VIP nữa
  bool get canAccessAdminPanel => false; // User thường không access admin
  bool get canDeleteContent => false;

  // Role hierarchy checks
  bool get isGuest => this == UserRole.guest;
  bool get isUser => level >= UserRole.user.level;
  bool get isPremium => false;
  bool get isVip => false;
}

// Permission service
class PermissionService {
  static bool hasPermission(UserRole? userRole, Permission permission) {
    if (userRole == null) return false;

    switch (permission) {
      case Permission.readContent:
        return userRole.canReadContent;
      case Permission.bookmark:
        return userRole.canBookmark;
      case Permission.viewHistory:
        return userRole.canViewHistory;
      case Permission.updateProfile:
        return userRole.canUpdateProfile;
      case Permission.manageContent:
        return userRole.canManageContent;
      case Permission.manageUsers:
        return userRole.canManageUsers;
      case Permission.adminPanel:
        return userRole.canAccessAdminPanel;
      case Permission.deleteContent:
        return userRole.canDeleteContent;
    }
  }

  static List<Permission> getPermissions(UserRole? userRole) {
    if (userRole == null) return [];

    List<Permission> permissions = [];

    if (userRole.canReadContent) permissions.add(Permission.readContent);
    if (userRole.canBookmark) permissions.add(Permission.bookmark);
    if (userRole.canViewHistory) permissions.add(Permission.viewHistory);
    if (userRole.canUpdateProfile) permissions.add(Permission.updateProfile);
    if (userRole.canManageContent) permissions.add(Permission.manageContent);
    if (userRole.canManageUsers) permissions.add(Permission.manageUsers);
    if (userRole.canAccessAdminPanel) permissions.add(Permission.adminPanel);
    if (userRole.canDeleteContent) permissions.add(Permission.deleteContent);

    return permissions;
  }
}

// Permission enum
enum Permission {
  readContent,
  bookmark,
  viewHistory,
  updateProfile,
  manageContent,
  manageUsers,
  adminPanel,
  deleteContent,
}

// Current user role provider
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser != null) {
    return UserRole.fromString(currentUser.role.value);
  }
  return null;
});

// Guest mode provider
final isGuestModeProvider = StateProvider<bool>((ref) => false);

// Effective role provider (considers guest mode)
final effectiveUserRoleProvider = Provider<UserRole>((ref) {
  final isGuestMode = ref.watch(isGuestModeProvider);
  if (isGuestMode) {
    return UserRole.guest;
  }

  final userRole = ref.watch(currentUserRoleProvider);
  return userRole ?? UserRole.guest;
});

// Permission providers
final canReadContentProvider = Provider<bool>((ref) {
  final role = ref.watch(effectiveUserRoleProvider);
  return PermissionService.hasPermission(role, Permission.readContent);
});

final canBookmarkProvider = Provider<bool>((ref) {
  final role = ref.watch(effectiveUserRoleProvider);
  return PermissionService.hasPermission(role, Permission.bookmark);
});

final canViewHistoryProvider = Provider<bool>((ref) {
  final role = ref.watch(effectiveUserRoleProvider);
  return PermissionService.hasPermission(role, Permission.viewHistory);
});

final canUpdateProfileProvider = Provider<bool>((ref) {
  final role = ref.watch(effectiveUserRoleProvider);
  return PermissionService.hasPermission(role, Permission.updateProfile);
});

final canManageContentProvider = Provider<bool>((ref) {
  final role = ref.watch(effectiveUserRoleProvider);
  return PermissionService.hasPermission(role, Permission.manageContent);
});

final canManageUsersProvider = Provider<bool>((ref) {
  final role = ref.watch(effectiveUserRoleProvider);
  return PermissionService.hasPermission(role, Permission.manageUsers);
});

final canAccessAdminPanelProvider = Provider<bool>((ref) {
  final role = ref.watch(effectiveUserRoleProvider);
  return PermissionService.hasPermission(role, Permission.adminPanel);
});

final canDeleteContentProvider = Provider<bool>((ref) {
  final role = ref.watch(effectiveUserRoleProvider);
  return PermissionService.hasPermission(role, Permission.deleteContent);
});
