import '../../domain/entities/activity.dart';
import '../../domain/entities/bilan_medical_mensuel.dart';
import '../../domain/repositories/bilan_medical_mensuel_repository.dart';
import 'activity_service.dart';

/// Service applicatif pour la gestion des bilans medicaux mensuels.
/// Orchestrate les repositories et enregistre les activites associees.
class BilanMedicalMensuelService {
  final BilanMedicalMensuelRepository _repository;
  final ActivityService? _activityService;

  BilanMedicalMensuelService({
    required BilanMedicalMensuelRepository repository,
    ActivityService? activityService,
  }) : _repository = repository,
       _activityService = activityService;

  /// Retourne la liste des bilans medicaux mensuels d'un academicien.
  Future<List<BilanMedicalMensuel>> getByAcademicienId(String academicienId) {
    return _repository.getByAcademicienId(academicienId);
  }

  /// Retourne un bilan medical mensuel par son ID.
  Future<BilanMedicalMensuel?> getById(String id) {
    return _repository.getById(id);
  }

  /// Cree un nouveau bilan medical mensuel.
  Future<BilanMedicalMensuel> create(BilanMedicalMensuel bilan) async {
    final created = await _repository.create(bilan);
    await _activityService?.enregistrer(
      type: ActivityType.bilanMedicalMensuelCree,
      titre: 'bilanMedicalMensuelCree',
      description: '${created.periodeLabel}|${created.academicienId}',
      referenceId: created.id,
    );
    return created;
  }

  /// Met a jour un bilan medical mensuel existant.
  Future<BilanMedicalMensuel> update(BilanMedicalMensuel bilan) async {
    final updated = await _repository.update(bilan);
    await _activityService?.enregistrer(
      type: ActivityType.bilanMedicalMensuelModifie,
      titre: 'bilanMedicalMensuelModifie',
      description: '${updated.periodeLabel}|${updated.academicienId}',
      referenceId: updated.id,
    );
    return updated;
  }

  /// Supprime un bilan medical mensuel.
  Future<void> delete(String id) async {
    await _repository.delete(id);
    await _activityService?.enregistrer(
      type: ActivityType.bilanMedicalMensuelSupprime,
      titre: 'bilanMedicalMensuelSupprime',
      description: id,
      referenceId: id,
    );
  }
}
