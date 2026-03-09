import 'permission.dart';
import 'role.dart';

/// Entité représentant un utilisateur de l'application.
///
/// Contient les informations de base de l'utilisateur ainsi que son rôle
/// qui détermine ses permissions et accès aux fonctionnalités.
class User {
  /// Identifiant unique de l'utilisateur.
  final String id;

  /// Prénom de l'utilisateur.
  final String firstName;

  /// Nom de l'utilisateur.
  final String lastName;

  /// Adresse e-mail de l'utilisateur.
  final String email;

  /// Rôle de l'utilisateur déterminant ses permissions.
  final Role role;

  /// URL de la photo de profil (optionnelle).
  final String? photoUrl;

  /// Date de création du compte.
  final DateTime? createdAt;

  /// Date de dernière modification du compte.
  final DateTime? updatedAt;

  /// Indique si le compte est actif.
  final bool isActive;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Retourne le nom complet de l'utilisateur.
  String get fullName => '$firstName $lastName';

  /// Retourne les initiales de l'utilisateur.
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    }
    return firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';
  }

  /// Vérifie si l'utilisateur possède une permission spécifique.
  bool hasPermission(Permission permission) => role.hasPermission(permission);

  /// Vérifie si l'utilisateur possède toutes les permissions spécifiées.
  bool hasAllPermissions(Iterable<Permission> permissions) =>
      role.hasAllPermissions(permissions);

  /// Vérifie si l'utilisateur possède au moins une des permissions spécifiées.
  bool hasAnyPermission(Iterable<Permission> permissions) =>
      role.hasAnyPermission(permissions);

  /// Vérifie si l'utilisateur a un rôle supérieur ou égal à [other].
  bool hasRoleHigherOrEqualTo(Role other) => role.isHigherOrEqualTo(other);

  /// Vérifie si l'utilisateur a un rôle strictement supérieur à [other].
  bool hasRoleHigherThan(Role other) => role.isHigherThan(other);

  /// Crée une copie de l'utilisateur avec des champs modifiés.
  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    Role? role,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Crée une instance depuis un JSON (réponse API).
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: Role.fromId(json['role'] as String? ?? ''),
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convertit l'instance en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'role': role.id,
      'photo_url': photoUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, email: $email, role: $role)';
}
