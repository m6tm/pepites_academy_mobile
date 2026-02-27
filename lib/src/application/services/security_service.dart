import '../../domain/repositories/security_repository.dart';

/// Service de securite pour la gestion du mot de passe et des sessions.
class SecurityService {
  final SecurityRepository _repository;

  SecurityService({required SecurityRepository repository})
    : _repository = repository;

  /// Change le mot de passe de l'utilisateur.
  ///
  /// Retourne (true, null) si succes, (false, error) si echec.
  Future<(bool, String?)> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (oldPassword.isEmpty) {
      return (false, 'Le mot de passe actuel est requis');
    }
    if (newPassword.isEmpty) {
      return (false, 'Le nouveau mot de passe est requis');
    }
    if (newPassword.length < 8) {
      return (false, 'Le mot de passe doit contenir au moins 8 caracteres');
    }

    final failure = await _repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );

    if (failure != null) {
      return (false, failure.message);
    }
    return (true, null);
  }

  /// Recupere l'historique des modifications de mot de passe.
  ///
  /// Retourne une liste d'evenements de mot de passe.
  Future<List<PasswordHistoryEntry>> getPasswordHistory() async {
    final (failure, data) = await _repository.getPasswordHistory();

    if (failure != null || data == null) {
      return [];
    }

    return data.map((item) => PasswordHistoryEntry.fromJson(item)).toList();
  }

  /// Deconnecte tous les autres appareils.
  ///
  /// Retourne le nombre de sessions revoquees ou -1 si echec.
  Future<int> logoutAllDevices() async {
    final (failure, count) = await _repository.logoutAllDevices();

    if (failure != null) {
      return -1;
    }
    return count ?? 0;
  }

  /// Recupere la liste des sessions actives.
  ///
  /// Retourne une liste de sessions.
  Future<List<ActiveSession>> getActiveSessions() async {
    final (failure, data) = await _repository.getActiveSessions();

    if (failure != null || data == null) {
      return [];
    }

    return data.map((item) => ActiveSession.fromJson(item)).toList();
  }

  /// Revoque une session specifique.
  ///
  /// Retourne (true, null) si succes, (false, error) si echec.
  Future<(bool, String?)> revokeSession(String sessionId) async {
    final failure = await _repository.revokeSession(sessionId);

    if (failure != null) {
      return (false, failure.message);
    }
    return (true, null);
  }
}

/// Entree de l'historique des mots de passe.
class PasswordHistoryEntry {
  final String action;
  final DateTime date;
  final String? device;

  const PasswordHistoryEntry({
    required this.action,
    required this.date,
    this.device,
  });

  factory PasswordHistoryEntry.fromJson(Map<String, dynamic> json) {
    return PasswordHistoryEntry(
      action: json['action'] as String? ?? 'Modification',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      device: json['device'] as String?,
    );
  }
}

/// Session active d'un utilisateur.
class ActiveSession {
  final String id;
  final String deviceName;
  final String? location;
  final DateTime lastActive;
  final bool isCurrent;

  const ActiveSession({
    required this.id,
    required this.deviceName,
    this.location,
    required this.lastActive,
    this.isCurrent = false,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      id: json['id'] as String? ?? '',
      deviceName: json['device_name'] as String? ?? 'Appareil inconnu',
      location: json['location'] as String?,
      lastActive:
          DateTime.tryParse(json['last_active'] as String? ?? '') ??
          DateTime.now(),
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }
}
