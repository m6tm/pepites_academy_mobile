import '../entities/presence.dart';

/// Contrat pour la gestion des présences (scans QR).
abstract class PresenceRepository {
  /// Enregistre une présence.
  Future<Presence> mark(Presence presence);

  /// Récupère toutes les présences d'une séance spécifique.
  Future<List<Presence>> getBySeance(String seanceId);

  /// Récupère l'historique de présence d'un profil (académicien ou encadreur).
  Future<List<Presence>> getByProfil(String profilId);
}
