import 'package:flutter/material.dart';
import '../../domain/entities/permission.dart';
import '../../domain/entities/role.dart';
import '../../injection_container.dart';

/// Widget qui affiche conditionnellement son enfant selon les permissions.
///
/// Ce widget vérifie si l'utilisateur actuel possède les permissions requises
/// et affiche ou masque le contenu en conséquence.
///
/// Note importante : L'UI masque les éléments non autorisés, mais la validation
/// finale reste côté serveur pour des raisons de sécurité.
class PermissionGuard extends StatefulWidget {
  /// L'enfant à afficher si les permissions sont accordées.
  final Widget child;

  /// Widget alternatif à afficher si les permissions sont refusées.
  /// Par défaut, rien n'est affiché (SizedBox.shrink).
  final Widget? fallback;

  /// Permission unique requise pour afficher l'enfant.
  final Permission? permission;

  /// Liste de permissions requises (toutes doivent être accordées).
  final Iterable<Permission>? permissions;

  /// Si true, l'utilisateur doit avoir au moins une des permissions.
  /// Si false (défaut), l'utilisateur doit avoir toutes les permissions.
  final bool requireAny;

  /// Rôle minimum requis pour afficher l'enfant.
  /// L'utilisateur doit avoir un rôle de niveau supérieur ou égal.
  final Role? minimumRole;

  /// Constructeur pour une permission unique.
  const PermissionGuard({
    super.key,
    required this.child,
    this.fallback,
    this.permission,
    this.permissions,
    this.requireAny = false,
    this.minimumRole,
  }) : assert(
         permission != null || permissions != null || minimumRole != null,
         'Au moins une permission ou un rôle minimum doit être spécifié',
       );

  /// Constructeur factory pour vérifier plusieurs permissions (toutes requises).
  factory PermissionGuard.all({
    Key? key,
    required Widget child,
    required Iterable<Permission> permissions,
    Widget? fallback,
    Role? minimumRole,
  }) {
    return PermissionGuard(
      key: key,
      child: child,
      permissions: permissions,
      requireAny: false,
      fallback: fallback,
      minimumRole: minimumRole,
    );
  }

  /// Constructeur factory pour vérifier au moins une permission.
  factory PermissionGuard.any({
    Key? key,
    required Widget child,
    required Iterable<Permission> permissions,
    Widget? fallback,
    Role? minimumRole,
  }) {
    return PermissionGuard(
      key: key,
      child: child,
      permissions: permissions,
      requireAny: true,
      fallback: fallback,
      minimumRole: minimumRole,
    );
  }

  /// Constructeur factory pour vérifier un rôle minimum.
  factory PermissionGuard.role({
    Key? key,
    required Widget child,
    required Role minimumRole,
    Widget? fallback,
  }) {
    return PermissionGuard(
      key: key,
      child: child,
      minimumRole: minimumRole,
      fallback: fallback,
    );
  }

  @override
  State<PermissionGuard> createState() => _PermissionGuardState();
}

class _PermissionGuardState extends State<PermissionGuard> {
  Role? _currentRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  /// Charge le rôle de l'utilisateur actuel.
  Future<void> _loadRole() async {
    // Si pas de vérification de rôle minimum, pas besoin de charger
    if (widget.minimumRole == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final role = await DependencyInjection.roleService.getCurrentUserRole();
      if (mounted) {
        setState(() {
          _currentRole = role;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher rien pendant le chargement si rôle minimum requis
    if (_isLoading && widget.minimumRole != null) {
      return const SizedBox.shrink();
    }

    final hasAccess = _checkAccess();

    if (hasAccess) {
      return widget.child;
    }

    return widget.fallback ?? const SizedBox.shrink();
  }

  /// Vérifie si l'utilisateur a accès selon les critères définis.
  bool _checkAccess() {
    // Vérification du rôle minimum si spécifié
    if (widget.minimumRole != null) {
      if (_currentRole == null ||
          !_currentRole!.isHigherOrEqualTo(widget.minimumRole!)) {
        return false;
      }
    }

    // Vérification d'une permission unique
    if (widget.permission != null) {
      return DependencyInjection.roleService.hasPermission(widget.permission!);
    }

    // Vérification de plusieurs permissions
    if (widget.permissions != null) {
      if (widget.requireAny) {
        return DependencyInjection.roleService.hasAnyPermission(
          widget.permissions!,
        );
      } else {
        return DependencyInjection.roleService.hasAllPermissions(
          widget.permissions!,
        );
      }
    }

    // Si seul le rôle minimum est vérifié et passé
    return true;
  }
}

/// Extension pour simplifier l'utilisation du PermissionGuard.
extension PermissionGuardExtension on Widget {
  /// Affiche ce widget uniquement si l'utilisateur a la permission spécifiée.
  Widget withPermission(Permission permission, {Widget? fallback}) {
    return PermissionGuard(
      permission: permission,
      fallback: fallback,
      child: this,
    );
  }

  /// Affiche ce widget uniquement si l'utilisateur a toutes les permissions.
  Widget withAllPermissions(
    Iterable<Permission> permissions, {
    Widget? fallback,
  }) {
    return PermissionGuard.all(
      permissions: permissions,
      fallback: fallback,
      child: this,
    );
  }

  /// Affiche ce widget uniquement si l'utilisateur a au moins une permission.
  Widget withAnyPermission(
    Iterable<Permission> permissions, {
    Widget? fallback,
  }) {
    return PermissionGuard.any(
      permissions: permissions,
      fallback: fallback,
      child: this,
    );
  }

  /// Affiche ce widget uniquement si l'utilisateur a un rôle suffisant.
  Widget withRole(Role minimumRole, {Widget? fallback}) {
    return PermissionGuard.role(
      minimumRole: minimumRole,
      fallback: fallback,
      child: this,
    );
  }
}
