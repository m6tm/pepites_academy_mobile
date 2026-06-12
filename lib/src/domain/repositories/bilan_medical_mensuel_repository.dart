import '../entities/bilan_medical_mensuel.dart';

/// Contrat du repository pour la gestion des bilans medicaux mensuels.
abstract class BilanMedicalMensuelRepository {
  /// Retourne la liste des bilans medicaux mensuels d'un academicien.
  Future<List<BilanMedicalMensuel>> getByAcademicienId(String academicienId);

  /// Retourne un bilan medical mensuel par son ID.
  Future<BilanMedicalMensuel?> getById(String id);

  /// Cree un nouveau bilan medical mensuel.
  Future<BilanMedicalMensuel> create(BilanMedicalMensuel bilan);

  /// Met a jour un bilan medical mensuel existant.
  Future<BilanMedicalMensuel> update(BilanMedicalMensuel bilan);

  /// Supprime un bilan medical mensuel.
  Future<void> delete(String id);

  /// Synchronise les bilans medicaux mensuels d'un academicien depuis le backend.
  Future<bool> syncFromApi(String academicienId);

  /// Vide les caches memoire.
  void clearCache();
}
