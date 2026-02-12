import '../../domain/entities/user_role.dart';

/// Identifiants de test pour le développement.
class DevCredentials {
  /// Compte Administrateur de test.
  static const String adminEmail = 'admin@pepites.com';
  static const String adminPassword = 'AdminPassword123!';
  static const UserRole adminRole = UserRole.admin;

  /// Compte Encadreur de test.
  static const String coachEmail = 'coach@pepites.com';
  static const String coachPassword = 'CoachPassword123!';
  static const UserRole coachRole = UserRole.encadreur;

  /// Vérifie si les identifiants fournis correspondent à un compte de test.
  static bool isValid(String email, String password) {
    final cleanEmail = email.toLowerCase().trim();
    return (cleanEmail == adminEmail.toLowerCase() &&
            password == adminPassword) ||
        (cleanEmail == coachEmail.toLowerCase() && password == coachPassword);
  }

  /// Récupère le rôle associé à un email de test.
  static UserRole? getRole(String email) {
    final cleanEmail = email.toLowerCase().trim();
    if (cleanEmail == adminEmail.toLowerCase()) return adminRole;
    if (cleanEmail == coachEmail.toLowerCase()) return coachRole;
    return null;
  }
}
