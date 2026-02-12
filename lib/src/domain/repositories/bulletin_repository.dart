import '../entities/bulletin.dart';

/// Contrat pour la gestion des bulletins.
abstract class BulletinRepository {
  /// Crée un nouveau bulletin.
  Future<Bulletin> create(Bulletin bulletin);

  /// Récupère les bulletins d'un académicien.
  Future<List<Bulletin>> getByAcademicien(String academicienId);
}
