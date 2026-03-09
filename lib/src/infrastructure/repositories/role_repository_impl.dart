import '../../domain/entities/permission.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/network_failure.dart';
import '../../domain/repositories/role_repository.dart';
import '../network/api_endpoints.dart';
import '../network/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implémentation du dépôt des rôles et permissions.
///
/// Gère le stockage local du rôle pour le mode hors-ligne et
/// les vérifications de permissions côté client.
class RoleRepositoryImpl implements RoleRepository {
  final DioClient _dioClient;
  final SharedPreferences _sharedPrefs;

  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyUserFirstName = 'user_first_name';
  static const String _keyUserLastName = 'user_last_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhoto = 'user_photo';

  Role? _cachedRole;
  User? _cachedUser;

  RoleRepositoryImpl(this._dioClient, this._sharedPrefs);

  @override
  Future<Role> getCurrentUserRole() async {
    // Retourner le rôle en cache si disponible
    if (_cachedRole != null) {
      return _cachedRole!;
    }

    // Sinon, charger depuis le stockage local
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
      // Utiliser l'endpoint encadreurs pour récupérer le profil
      final result = await _dioClient.get(ApiEndpoints.encadreurs);

      return result.fold((failure) => failure, (data) async {
        if (data is Map<String, dynamic> || data is List) {
          await persistRoleLocally(newRole);
          _cachedRole = newRole;
          _cachedUser = null; // Invalider le cache utilisateur
        }
        return null;
      });
    } catch (e) {
      return const NetworkFailure(
        type: NetworkFailureType.serverError,
        message: 'Erreur lors de la mise à jour du rôle',
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
    try {
      final result = await _dioClient.put(
        '${ApiEndpoints.roleUsers}/$userId/role',
        data: {'role': newRole.id},
      );

      return result.fold((failure) => failure, (_) => null);
    } catch (e) {
      return const NetworkFailure(
        type: NetworkFailureType.serverError,
        message: 'Erreur lors de l\'attribution du rôle',
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
            message: 'Format de réponse invalide',
          ),
        );
      });
    } catch (e) {
      return (
        null,
        const NetworkFailure(
          type: NetworkFailureType.serverError,
          message: 'Erreur lors de la récupération des utilisateurs',
        ),
      );
    }
  }

  @override
  Future<(List<User>?, NetworkFailure?)> getAllUsersWithRoles({
    int page = 1,
    int limit = 20,
    Role? filterByRole,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (filterByRole != null) {
        params['role'] = filterByRole.id;
      }

      final result = await _dioClient.get(
        ApiEndpoints.roleUsers,
        queryParameters: params,
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
            message: 'Format de réponse invalide',
          ),
        );
      });
    } catch (e) {
      return (
        null,
        const NetworkFailure(
          type: NetworkFailureType.serverError,
          message: 'Erreur lors de la récupération des utilisateurs',
        ),
      );
    }
  }

  @override
  bool hasPermission(Permission permission) {
    // Utiliser le rôle en cache ou charger synchrone
    final role = _cachedRole;
    if (role != null) {
      return role.hasPermission(permission);
    }

    // Chargement synchrone depuis SharedPreferences
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
    // Retourner l'utilisateur en cache si disponible
    if (_cachedUser != null) {
      return _cachedUser;
    }

    // Charger depuis le stockage local
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
  }

  /// Persiste les informations complètes de l'utilisateur localement.
  ///
  /// Appelé lors de la connexion pour permettre le fonctionnement hors-ligne.
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

    // Mettre à jour le cache
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

  /// Rafraîchit le rôle depuis l'API.
  ///
  /// Utile pour vérifier si le rôle a changé côté serveur.
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
}
