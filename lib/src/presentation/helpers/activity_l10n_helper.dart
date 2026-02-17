import '../../../l10n/app_localizations.dart';
import '../../domain/entities/activity.dart';

/// Helper pour traduire les titres et descriptions des activites
/// en fonction du type et de la langue active.
/// Les descriptions brutes sont stockees au format "donnee1|donnee2".
class ActivityL10nHelper {
  final AppLocalizations _l10n;

  ActivityL10nHelper(this._l10n);

  /// Retourne le titre traduit pour une activite.
  String titre(Activity activity) {
    switch (activity.type) {
      case ActivityType.seanceOuverte:
        return _l10n.activitySessionOpened;
      case ActivityType.seanceCloturee:
        return _l10n.activitySessionClosed;
      case ActivityType.seanceProgrammee:
        return _l10n.activitySessionScheduled;
      case ActivityType.academicienInscrit:
        return _l10n.activityNewAcademician;
      case ActivityType.academicienSupprime:
        return _l10n.activityAcademicianRemoved;
      case ActivityType.encadreurInscrit:
        return _l10n.activityNewCoach;
      case ActivityType.presenceEnregistree:
        return _l10n.activityAttendanceRecorded;
      case ActivityType.smsEnvoye:
        return _l10n.activitySmsSent;
      case ActivityType.smsEchec:
        return _l10n.activitySmsFailed;
      case ActivityType.bulletinGenere:
        return _l10n.activityReportGenerated;
      case ActivityType.referentielPosteAjoute:
      case ActivityType.referentielPosteModifie:
      case ActivityType.referentielPosteSupprime:
      case ActivityType.referentielNiveauAjoute:
      case ActivityType.referentielNiveauModifie:
      case ActivityType.referentielNiveauSupprime:
        return _l10n.activityReferentialUpdated;
    }
  }

  /// Retourne la description traduite pour une activite.
  /// Parse les donnees brutes separees par | et reconstruit
  /// la phrase traduite selon le type d'activite.
  String description(Activity activity) {
    final raw = activity.description;
    final parts = raw.split('|');

    switch (activity.type) {
      case ActivityType.seanceOuverte:
      case ActivityType.seanceProgrammee:
        return raw;

      case ActivityType.seanceCloturee:
        if (parts.length >= 2) {
          final count = int.tryParse(parts[1]) ?? 0;
          return _l10n.activitySessionClosedDesc(parts[0], count);
        }
        return raw;

      case ActivityType.academicienInscrit:
        return _l10n.activityAcademicianRegistered(raw);

      case ActivityType.academicienSupprime:
        return _l10n.activityAcademicianRemovedDesc(raw);

      case ActivityType.encadreurInscrit:
        if (parts.length >= 2) {
          return '${parts[0]} - ${parts[1]}';
        }
        return raw;

      case ActivityType.presenceEnregistree:
        if (parts.length >= 2) {
          final type = parts[0] == 'Academicien'
              ? _l10n.profileAcademician
              : _l10n.profileCoach;
          return _l10n.activityAttendanceDesc(type, parts[1]);
        }
        return raw;

      case ActivityType.smsEnvoye:
        if (parts.length >= 2) {
          final count = int.tryParse(parts[0]) ?? 0;
          return _l10n.activitySmsSentDesc(count, parts[1]);
        }
        return raw;

      case ActivityType.smsEchec:
        return _l10n.activitySmsFailedDesc;

      case ActivityType.bulletinGenere:
        if (parts.length >= 2) {
          return '${parts[0]} - ${parts[1]}';
        }
        return raw;

      case ActivityType.referentielPosteAjoute:
        return _l10n.activityNewPosition(raw);
      case ActivityType.referentielPosteModifie:
        return _l10n.activityPositionModified(raw);
      case ActivityType.referentielPosteSupprime:
        return _l10n.activityPositionRemoved(raw);
      case ActivityType.referentielNiveauAjoute:
        return _l10n.activityNewLevel(raw);
      case ActivityType.referentielNiveauModifie:
        return _l10n.activityLevelModified(raw);
      case ActivityType.referentielNiveauSupprime:
        return _l10n.activityLevelRemoved(raw);
    }
  }
}
