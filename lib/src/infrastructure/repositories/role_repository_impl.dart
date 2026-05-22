import '../../core/cache/cache_ttl.dart';
import '../../core/cache/repository_cache.dart';
import '../../core/events/domain_event_bus.dart';
import '../../core/events/invalidation_registry.dart';
import '../../core/events/role_events.dart';
import '../../core/network/connectivity_guard.dart';
import '../../domain/exceptions/network_exception.dart';
import '../../domain/entities/permission.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/role_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementation du depot des roles et permissions.
///
/// Gere le stockage local du role pour le mode hors-ligne et
/// les verifications de permissions cote client.
class RoleRepositoryImpl implements RoleRepository {
  final DioClient _dioClient;
  final SharedPreferences _sharedPrefs;

  final RepositoryCache<List<User>> _usersCache = RepositoryCache<List<User>>();

  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyUserFirstName = 'user_first_name';
  static const String _keyUserLastName = 'user_last_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhoto = 'user_photo';

  Role? _cachedRole;
  User? _cachedUser;

  DomainEventBus? _eventBus;
  InvalidationRegistry? _invalidationRegistry;
  ConnectivityGuard? _connectivityGuard;

  RoleRepositoryImpl(this._dioClient, this._sharedPrefs);

  void setEventBus(DomainEventBus bus) {
    _eventBus = bus;
  }

  void setInvalidationRegistry(InvalidationRegistry registry) {
    _invalidationRegistry = registry;
  }

  void setConnectivityGuard(ConnectivityGuard guard) {
    _connectivityGuard = guard;
  }

  /// Retourne le role en cache de maniere synchrone.
  Role? get cachedRole => _cachedRole;

  @override
  Future<Role> getCurrentUserRole() async {
    if (_cachedRole != null) {
      return _cachedRole!;
    }

    final roleId = _sharedPrefs.getString(_keyUserRole);
    if (roleId != null && roleId.isNotEmpty) {
      _cachedRole = Role.fromId(roleId);
      return _cachedRole!;
    }

    return Role.visiteur;
  }

  @override
  Future<NetworkFailure?> updateCurrentUserRole(Role newRole) async {
    try {
      final result = await _dioClient.get(ApiEndpoints.encadreurs);

      return result.fold((failure) => failure, (data) async {
        if (data is Map<String, dynamic> || data is List) {
          await persistRoleLocally(newRole);
          _cachedRole = newRole;
          _cachedUser = null;
          _usersCache.invalidateByTag('users');
          _invalidationRegistry?.markInvalidated<RoleAssignedEvent>();
          _eventBus?.emit(const RoleAssignedEvent(userId: '', roleId: ''));
        }
        return null;
      });
    } catch (e) {
      return const NetworkFailure(
        type: NetworkFailureType.serverError,
        message: 'Erreur lors de la mise a jour du role',
      );
    }
  }

  @override
  List<Role> getAllRoles() {
    return Role.values;
  }

  @override
  Set<Permission> getPermissionsForRole(Role role) {
    return role.permissions;
  }

  @override
  Future<NetworkFailure?> assignRoleToUser({
    required String userId,
    required Role newRole,
  }) async {
    final online = await _connectivityGuard?.isOnline ?? true;
    if (!online) {
      return const NetworkFailure(
        type: NetworkFailureType.noConnection,
        message: 'Aucune connexion internet',
      );
    }
    try {
      final result = await _dioClient.put(
        '${ApiEndpoints.roleUsers}/$userId/role',
        data: {'role': newRole.id},
      );

      return result.fold((failure) => failure, (_) {
        _usersCache.invalidateByTag('users');
        _invalidationRegistry?.markInvalidated<RoleAssignedEvent>();
        _eventBus?.emit(RoleAssignedEvent(userId: userId, roleId: newRole.id));
        return null;
      });
    } catch (e) {
      return const NetworkFailure(
        type: NetworkFailureType.serverError,
        message: 'Erreur lors de l\'attribution du role',
      );
    }
  }

  @override
  Future<(List<User>?, NetworkFailure?)> getUsersByRole(Role role) async {
    try {
      final result = await _dioClient.get(
        ApiEndpoints.roleUsers,
        queryParameters: {'role': role.id},
      );

      return result.fold((failure) => (null, failure), (data) {
        if (data is Map<String, dynamic> && data['items'] is List) {
          final users = (data['items'] as List)
              .map((json) => User.fromJson(json as Map<String, dynamic>))
              .toList();
          return (users, null);
        }
        if (data is List) {
          final users = data
              .map((json) => User.fromJson(json as Map<String, dynamic>))
              .toList();
          return (users, null);
        }
        return (
          null,
          const NetworkFailure(
            type: NetworkFailureType.serverError,
            message: 'Format de reponse invalide',
          ),
        );
      });
    } catch (e) {
      return (
        null,
        const NetworkFailure(
          type: NetworkFailureType.serverError,
          message: 'Erreur lors de la recuperation des utilisateurs',
        ),
      );
    }
  }

  @override
  Future<(List<User>?, NetworkFailure?, bool isFromCache)>
  getAllUsersWithRoles({
    int page = 1,
    int limit = 20,
    Role? filterByRole,
    bool forceRefresh = false,
  }) async {
    final key = 'users_${filterByRole?.id ?? 'all'}';

    if (!forceRefresh && page == 1) {
      final cached = _usersCache.get(key);
      if (cached != null) {
        return (cached, null, true);
      }
    }

    if (_connectivityGuard != null && !await _connectivityGuard!.isOnline) {
      final stale = _usersCache.getStale(key);
      if (stale != null) return (stale, null, true);
      throw const OfflineException();
    }

    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (filterByRole != null) {
        params['role'] = filterByRole.id;
      }

      final result = await _dioClient.get(
        ApiEndpoints.roleUsers,
        queryParameters: params,
      );

      return result.fold((failure) => (null, failure, false), (data) {
        if (data is Map<String, dynamic> && data['items'] is List) {
          final users = (data['items'] as List)
              .map((json) => User.fromJson(json as Map<String, dynamic>))
              .toList();
          if (page == 1) {
            _usersCache.set(
              key,
              users,
              ttl: CacheTtl.roles,
              tags: {'users', key},
            );
          }
          return (users, null, false);
        }
        if (data is List) {
          final users = data
              .map((json) => User.fromJson(json as Map<String, dynamic>))
              .toList();
          if (page == 1) {
            _usersCache.set(
              key,
              users,
              ttl: CacheTtl.roles,
              tags: {'users', key},
            );
          }
          return (users, null, false);
        }
        return (
          null,
          const NetworkFailure(
            type: NetworkFailureType.serverError,
            message: 'Format de reponse invalide',
          ),
          false,
        );
      });
    } catch (e) {
      return (
        null,
        const NetworkFailure(
          type: NetworkFailureType.serverError,
          message: 'Erreur lors de la recuperation des utilisateurs',
        ),
        false,
      );
    }
  }

  @override
  bool hasPermission(Permission permission) {
    final role = _cachedRole;
    if (role != null) {
      return role.hasPermission(permission);
    }

    final roleId = _sharedPrefs.getString(_keyUserRole);
    if (roleId != null && roleId.isNotEmpty) {
      final currentRole = Role.fromId(roleId);
      _cachedRole = currentRole;
      return currentRole.hasPermission(permission);
    }

    return false;
  }

  @override
  bool hasAllPermissions(Iterable<Permission> permissions) {
    final role = _cachedRole;
    if (role != null) {
      return role.hasAllPermissions(permissions);
    }

    final roleId = _sharedPrefs.getString(_keyUserRole);
    if (roleId != null && roleId.isNotEmpty) {
      final currentRole = Role.fromId(roleId);
      _cachedRole = currentRole;
      return currentRole.hasAllPermissions(permissions);
    }

    return false;
  }

  @override
  bool hasAnyPermission(Iterable<Permission> permissions) {
    final role = _cachedRole;
    if (role != null) {
      return role.hasAnyPermission(permissions);
    }

    final roleId = _sharedPrefs.getString(_keyUserRole);
    if (roleId != null && roleId.isNotEmpty) {
      final currentRole = Role.fromId(roleId);
      _cachedRole = currentRole;
      return currentRole.hasAnyPermission(permissions);
    }

    return false;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_cachedUser != null) {
      return _cachedUser;
    }

    final roleId = _sharedPrefs.getString(_keyUserRole);
    final userId = _sharedPrefs.getString(_keyUserId);
    final firstName = _sharedPrefs.getString(_keyUserFirstName) ?? '';
    final lastName = _sharedPrefs.getString(_keyUserLastName) ?? '';
    final email = _sharedPrefs.getString(_keyUserEmail) ?? '';
    final photoUrl = _sharedPrefs.getString(_keyUserPhoto);

    if (roleId == null || userId == null) {
      return null;
    }

    _cachedUser = User(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: Role.fromId(roleId),
      photoUrl: photoUrl,
    );

    return _cachedUser;
  }

  @override
  Future<void> persistRoleLocally(Role role) async {
    await _sharedPrefs.setString(_keyUserRole, role.id);
    _cachedRole = role;
  }

  @override
  Future<void> clearLocalRole() async {
    await _sharedPrefs.remove(_keyUserRole);
    await _sharedPrefs.remove(_keyUserId);
    await _sharedPrefs.remove(_keyUserFirstName);
    await _sharedPrefs.remove(_keyUserLastName);
    await _sharedPrefs.remove(_keyUserEmail);
    await _sharedPrefs.remove(_keyUserPhoto);

    _cachedRole = null;
    _cachedUser = null;
    _usersCache.clear();
  }

  /// Persiste les informations completes de l'utilisateur localement.
  Future<void> persistUserLocally({
    required String userId,
    required String role,
    required String firstName,
    required String lastName,
    required String email,
    String? photoUrl,
  }) async {
    await _sharedPrefs.setString(_keyUserId, userId);
    await _sharedPrefs.setString(_keyUserRole, role);
    await _sharedPrefs.setString(_keyUserFirstName, firstName);
    await _sharedPrefs.setString(_keyUserLastName, lastName);
    await _sharedPrefs.setString(_keyUserEmail, email);
    if (photoUrl != null && photoUrl.isNotEmpty) {
      await _sharedPrefs.setString(_keyUserPhoto, photoUrl);
    }

    _cachedRole = Role.fromId(role);
    _cachedUser = User(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      role: _cachedRole!,
      photoUrl: photoUrl,
    );
  }

  /// Rafraichit le role depuis l'API.
  Future<Role?> refreshRoleFromApi() async {
    try {
      final result = await _dioClient.get(ApiEndpoints.encadreurs);

      return result.fold((failure) => null, (data) {
        if (data is Map<String, dynamic>) {
          final userData = data['encadreur'] as Map<String, dynamic>? ?? data;
          final roleId = userData['role'] as String?;
          if (roleId != null) {
            final role = Role.fromId(roleId);
            _cachedRole = role;
            _sharedPrefs.setString(_keyUserRole, roleId);
            return role;
          }
        }
        return null;
      });
    } catch (e) {
      return null;
    }
  }

  /// Invalide le cache des utilisateurs.
  Future<void> invalidateUsersCache() async {
    _usersCache.invalidateByTag('users');
  }

  /// Verifie si le cache des utilisateurs existe et est valide.
  bool hasValidUsersCache() {
    return _usersCache.get('users_all') != null;
  }

  /// Recupere les utilisateurs en cache de maniere synchrone.
  List<User>? getCachedUsersSync() {
    return _usersCache.getStale('users_all');
  }

  @override
  Future<(List<RoleChangeHistory>?, NetworkFailure?)> getRoleChangeHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await _dioClient.get(
        ApiEndpoints.roleUserHistory(userId),
        queryParameters: {'page': page, 'limit': limit},
      );

      return result.fold((failure) => (null, failure), (data) {
        if (data is Map<String, dynamic> && data['items'] is List) {
          final history = (data['items'] as List)
              .map(
                (json) =>
                    RoleChangeHistory.fromJson(json as Map<String, dynamic>),
              )
              .toList();
          return (history, null);
        }
        return (
          null,
          const NetworkFailure(
            type: NetworkFailureType.serverError,
            message: 'Format de reponse invalide',
          ),
        );
      });
    } catch (e) {
      return (
        null,
        const NetworkFailure(
          type: NetworkFailureType.serverError,
          message: 'Erreur lors de la recuperation de l\'historique',
        ),
      );
    }
  }
}
