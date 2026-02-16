import '../../domain/entities/presence.dart';
import '../../infrastructure/repositories/academicien_repository_impl.dart';
import '../../infrastructure/repositories/encadreur_repository_impl.dart';
import '../../infrastructure/repositories/presence_repository_impl.dart';
import '../../infrastructure/repositories/seance_repository_impl.dart';
import 'activity_service.dart';

/// Resultat du scan QR contenant les informations du profil identifie.
class ScanResult {
  final bool success;
  final String message;
  final ProfilType? typeProfil;
  final String? profilId;
  final String? nom;
  final String? prenom;
  final String? photoUrl;
  final bool dejaPresent;

  const ScanResult({
    required this.success,
    required this.message,
    this.typeProfil,
    this.profilId,
    this.nom,
    this.prenom,
    this.photoUrl,
    this.dejaPresent = false,
  });

  /// Resultat d'echec generique.
  factory ScanResult.failure(String message) {
    return ScanResult(success: false, message: message);
  }

  String get nomComplet => '${prenom ?? ''} ${nom ?? ''}'.trim();
}

/// Service applicatif gerant la logique metier du scan QR.
/// Identifie le profil scanne et enregistre la presence.
class QrScannerService {
  final AcademicienRepositoryImpl _academicienRepository;
  final EncadreurRepositoryImpl _encadreurRepository;
  final PresenceRepositoryImpl _presenceRepository;
  final SeanceRepositoryImpl _seanceRepository;
  ActivityService? _activityService;

  QrScannerService({
    required AcademicienRepositoryImpl academicienRepository,
    required EncadreurRepositoryImpl encadreurRepository,
    required PresenceRepositoryImpl presenceRepository,
    required SeanceRepositoryImpl seanceRepository,
  }) : _academicienRepository = academicienRepository,
       _encadreurRepository = encadreurRepository,
       _presenceRepository = presenceRepository,
       _seanceRepository = seanceRepository;

  /// Injecte le service d'activites.
  void setActivityService(ActivityService service) {
    _activityService = service;
  }

  /// Identifie un profil a partir d'un code QR scanne.
  /// Recherche d'abord parmi les academiciens, puis les encadreurs.
  Future<ScanResult> identifyQrCode(String qrCode, String seanceId) async {
    // Recherche dans les academiciens
    final academicien = await _academicienRepository.getByQrCode(qrCode);
    if (academicien != null) {
      final dejaPresent = _presenceRepository.isAlreadyPresent(
        academicien.id,
        seanceId,
      );
      return ScanResult(
        success: true,
        message: dejaPresent
            ? 'Presence deja enregistree'
            : 'Academicien identifie',
        typeProfil: ProfilType.academicien,
        profilId: academicien.id,
        nom: academicien.nom,
        prenom: academicien.prenom,
        photoUrl: academicien.photoUrl,
        dejaPresent: dejaPresent,
      );
    }

    // Recherche dans les encadreurs
    final encadreur = await _encadreurRepository.getByQrCode(qrCode);
    if (encadreur != null) {
      final dejaPresent = _presenceRepository.isAlreadyPresent(
        encadreur.id,
        seanceId,
      );
      return ScanResult(
        success: true,
        message: dejaPresent
            ? 'Presence deja enregistree'
            : 'Encadreur identifie',
        typeProfil: ProfilType.encadreur,
        profilId: encadreur.id,
        nom: encadreur.nom,
        prenom: encadreur.prenom,
        photoUrl: encadreur.photoUrl,
        dejaPresent: dejaPresent,
      );
    }

    return ScanResult.failure('Code QR non reconnu');
  }

  /// Enregistre la presence d'un profil pour une seance.
  /// Met aussi a jour la seance avec le profilId dans la liste correspondante.
  Future<Presence> enregistrerPresence({
    required ProfilType typeProfil,
    required String profilId,
    required String seanceId,
  }) async {
    final presence = Presence(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      horodateArrivee: DateTime.now(),
      typeProfil: typeProfil,
      profilId: profilId,
      seanceId: seanceId,
    );
    final saved = await _presenceRepository.mark(presence);

    // Mise a jour de la seance avec le profil present
    final seance = await _seanceRepository.getById(seanceId);
    if (seance != null) {
      final updatedAcademicienIds = List<String>.from(seance.academicienIds);
      final updatedEncadreurIds = List<String>.from(seance.encadreurIds);

      if (typeProfil == ProfilType.academicien &&
          !updatedAcademicienIds.contains(profilId)) {
        updatedAcademicienIds.add(profilId);
      } else if (typeProfil == ProfilType.encadreur &&
          !updatedEncadreurIds.contains(profilId)) {
        updatedEncadreurIds.add(profilId);
      }

      final presences = await _presenceRepository.getBySeance(seanceId);
      await _seanceRepository.update(
        seance.copyWith(
          academicienIds: updatedAcademicienIds,
          encadreurIds: updatedEncadreurIds,
          nbPresents: presences.length,
        ),
      );
    }

    // Enregistrement de l'activite
    final typeLabel = typeProfil == ProfilType.academicien
        ? 'Academicien'
        : 'Encadreur';
    String nomComplet = typeLabel;
    if (typeProfil == ProfilType.academicien) {
      final acad = await _academicienRepository.getById(profilId);
      if (acad != null) {
        nomComplet = '${acad.prenom} ${acad.nom}';
      }
    } else {
      final enc = await _encadreurRepository.getById(profilId);
      if (enc != null) {
        nomComplet = '${enc.prenom} ${enc.nom}';
      }
    }
    await _activityService?.enregistrerPresence(
      typeLabel,
      nomComplet,
      saved.id,
    );

    return saved;
  }

  /// Recupere le nombre de presences pour une seance.
  Future<int> getNbPresences(String seanceId) async {
    final presences = await _presenceRepository.getBySeance(seanceId);
    return presences.length;
  }
}
