import '../entities/seance.dart';

/// Resultat combine seance + statistiques.
class SeanceWithStats {
  final Seance seance;
  final int nbPresents;
  final int nbAteliers;
  final int nbAnnotations;
  final List<Map<String, dynamic>> ateliers;

  SeanceWithStats({
    required this.seance,
    required this.nbPresents,
    required this.nbAteliers,
    required this.nbAnnotations,
    required this.ateliers,
  });
}

/// Contrat pour la gestion des seances d'entrainement.
abstract class SeanceRepository {
  Future<Seance?> getById(String id);
  Future<List<Seance>> getAll();
  Future<Seance?> getSeanceOuverte();
  Future<SeanceWithStats?> getSeanceEncoursWithStats();
  Future<Seance> create(Seance seance);
  Future<Seance> update(Seance seance);
  Future<Seance> ouvrir(String id);
  Future<Seance> fermer(String id);
  Future<void> delete(String id);
}
