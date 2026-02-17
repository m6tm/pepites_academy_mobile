// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Pepites Academy';

  @override
  String get login => 'Connexion';

  @override
  String get loginSubtitle =>
      'Accedez a votre espace encadreur ou administrateur';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'votre@email.com';

  @override
  String get emailRequired => 'Veuillez saisir votre email';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordRequired => 'Veuillez saisir votre mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublie ?';

  @override
  String get signIn => 'Se connecter';

  @override
  String get noAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get createAccount => 'Creer un compte';

  @override
  String get welcomeBack => 'Bienvenue !';

  @override
  String connectedAs(String role) {
    return 'Connecte en tant que $role';
  }

  @override
  String get loginFailed => 'Echec de connexion';

  @override
  String get loginFailedDescription =>
      'Identifiants incorrects. Utilisez les comptes de test.';

  @override
  String get logout => 'Se deconnecter';

  @override
  String get register => 'Inscription';

  @override
  String get resetPassword => 'Reinitialiser le mot de passe';

  @override
  String get otpVerification => 'Verification OTP';

  @override
  String get settings => 'Parametres';

  @override
  String get settingsSubtitle => 'Configuration de l\'application';

  @override
  String get general => 'General';

  @override
  String get administration => 'Administration';

  @override
  String get language => 'Langue';

  @override
  String get languageActive => 'Langue active';

  @override
  String get languageInfo =>
      'La langue est appliquee immediatement et sauvegardee pour les prochaines sessions.';

  @override
  String get french => 'Francais';

  @override
  String get english => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeSystem => 'Systeme';

  @override
  String get themeLightDescription => 'Apparence claire en permanence';

  @override
  String get themeDarkDescription => 'Apparence sombre en permanence';

  @override
  String get themeSystemDescription => 'Suit le reglage de l\'appareil';

  @override
  String themeActiveLabel(String label) {
    return 'Theme actif : $label';
  }

  @override
  String get themeInfo =>
      'Le theme est applique immediatement et sauvegarde pour les prochaines sessions.';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get appearance => 'APPARENCE';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Activees';

  @override
  String get about => 'A propos';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get referentials => 'Referentiels';

  @override
  String get referentialsSubtitle => 'Postes, Niveaux';

  @override
  String get categories => 'CATEGORIES';

  @override
  String get footballPositions => 'Postes de football';

  @override
  String get footballPositionsSubtitle =>
      'Gardien, Defenseur, Milieu, Attaquant...';

  @override
  String get footballPositionsDescription =>
      'Gerez les postes attribues aux academiciens';

  @override
  String get schoolLevels => 'Niveaux scolaires';

  @override
  String get schoolLevelsSubtitle => 'CP, CE1, 6eme, 3eme, Terminale...';

  @override
  String get schoolLevelsDescription =>
      'Gerez les niveaux scolaires des academiciens';

  @override
  String get home => 'Accueil';

  @override
  String get academy => 'Academie';

  @override
  String get sessions => 'Seances';

  @override
  String get communication => 'Communication';

  @override
  String get profile => 'Profil';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get administrator => 'Administrateur';

  @override
  String get coach => 'Encadreur';

  @override
  String get overview => 'Vue d\'ensemble';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get sessionOfTheDay => 'Seance du jour';

  @override
  String get history => 'Historique';

  @override
  String get globalPerformance => 'Performance globale';

  @override
  String get recentActivity => 'Activite recente';

  @override
  String get viewAll => 'Tout voir';

  @override
  String get academicians => 'Academiciens';

  @override
  String get coaches => 'Encadreurs';

  @override
  String get sessionsMonth => 'Seances (mois)';

  @override
  String get attendanceRate => 'Taux presence';

  @override
  String get register_action => 'Inscrire';

  @override
  String get newAcademician => 'Nouvel academicien';

  @override
  String get scanQr => 'Scanner QR';

  @override
  String get accessControl => 'Controle d\'acces';

  @override
  String get players => 'Joueurs';

  @override
  String get academiciansList => 'Liste des academiciens';

  @override
  String get coachManagement => 'Gestion des coachs';

  @override
  String get manageAcademy =>
      'Gerez l\'ensemble de votre academie depuis cet espace centralise.';

  @override
  String get averageAttendance => 'Presence\nmoyenne';

  @override
  String get goalsAchieved => 'Objectifs\natteints';

  @override
  String get coachSatisfaction => 'Satisfaction\nencadreurs';

  @override
  String get positiveTrend =>
      'Tendance positive : +8% de presence en Fevrier par rapport a Janvier.';

  @override
  String get noRecentActivity => 'Aucune activite recente.';

  @override
  String get noSessionRecorded => 'Aucune seance enregistree.';

  @override
  String get justNow => 'A l\'instant';

  @override
  String minutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String hoursAgo(int hours) {
    return 'Il y a ${hours}h';
  }

  @override
  String get yesterday => 'Hier';

  @override
  String daysAgo(int days) {
    return 'Il y a $days jours';
  }

  @override
  String get noSessionInProgress => 'Aucune seance en cours';

  @override
  String get openSessionBeforeScan =>
      'Veuillez ouvrir une seance avant de scanner.';

  @override
  String get openSessionBeforeWorkshops =>
      'Veuillez ouvrir une seance avant de gerer les ateliers.';

  @override
  String get readyForField => 'Pret pour le terrain';

  @override
  String get manageSessionsDescription =>
      'Gerez vos seances, evaluez vos joueurs et suivez leur progression.';

  @override
  String get sessionInProgress => 'SEANCE EN COURS';

  @override
  String get inProgress => 'En cours';

  @override
  String get present => 'Presents';

  @override
  String get workshops => 'Ateliers';

  @override
  String get annotations => 'Annotations';

  @override
  String get addWorkshop => 'Ajouter atelier';

  @override
  String get closeSession => 'Fermer seance';

  @override
  String get noCurrentSession => 'Aucune seance en cours';

  @override
  String get openSessionToStart => 'Ouvrez une seance pour commencer.';

  @override
  String get myActivity => 'Mon activite';

  @override
  String get fieldActions => 'Actions terrain';

  @override
  String get myAcademicians => 'Mes academiciens';

  @override
  String get myIndicators => 'Mes indicateurs';

  @override
  String get myRecentAnnotations => 'Mes dernieres annotations';

  @override
  String get sessionsConducted => 'Seances dirigees';

  @override
  String get workshopsCreated => 'Ateliers crees';

  @override
  String get averageAttendanceShort => 'Presence moy.';

  @override
  String get myAnnotations => 'Mes annotations';

  @override
  String get evaluateAcademician => 'Evaluer un academicien';

  @override
  String get myWorkshops => 'Mes ateliers';

  @override
  String get manageExercises => 'Gerer les exercices';

  @override
  String get attendance => 'Presences';

  @override
  String get scanArrivals => 'Scanner les arrivees';

  @override
  String get attendanceRateLabel => 'Taux de\npresence';

  @override
  String get annotationsPerSession => 'Annotations\npar seance';

  @override
  String get closedSessions => 'Seances\ncloturees';

  @override
  String get activityLevel => 'Niveau d\'activite';

  @override
  String get expert => 'Expert';

  @override
  String toNextLevel(int percent) {
    return '$percent% vers le niveau suivant';
  }

  @override
  String get smsAndNotifications => 'SMS et notifications';

  @override
  String get sent => 'Envoyes';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get failed => 'En echec';

  @override
  String get newMessage => 'Nouveau message';

  @override
  String get writeAndSendSms => 'Rediger et envoyer un SMS';

  @override
  String get groupMessage => 'Message groupe';

  @override
  String get sendToFilteredGroup => 'Envoyer a un groupe filtre';

  @override
  String get smsHistory => 'Historique SMS';

  @override
  String get viewSentMessages => 'Consulter les messages envoyes';

  @override
  String get lastMessages => 'Derniers messages';

  @override
  String get noMessageSentYet => 'Aucun message envoye pour le moment.';

  @override
  String get destinataire => 'destinataire';

  @override
  String get destinataires => 'destinataires';

  @override
  String get newSms => 'Nouveau SMS';

  @override
  String get writeYourMessage => 'Redigez votre message';

  @override
  String get smsWillBeSent =>
      'Le message sera envoye par SMS aux destinataires selectionnes.';

  @override
  String get typeMessageHere => 'Saisissez votre message ici...';

  @override
  String get characters => 'caractere';

  @override
  String get charactersPlural => 'caracteres';

  @override
  String get remaining => 'restants';

  @override
  String get chooseRecipients => 'Choisir les destinataires';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get summary => 'Recapitulatif';

  @override
  String get verifyBeforeSending => 'Verifiez les informations avant l\'envoi.';

  @override
  String get smsPerPerson => 'SMS / personne';

  @override
  String get totalSms => 'SMS total';

  @override
  String get message => 'Message';

  @override
  String get confirmSending => 'Confirmer l\'envoi';

  @override
  String aboutToSend(int count, String plural) {
    return 'Vous etes sur le point d\'envoyer ce message a $count destinataire$plural.\n\nCette action est irreversible.';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get sendSms => 'Envoyer les SMS';

  @override
  String get smsSent => 'SMS envoye !';

  @override
  String get messageSentSuccess => 'Le message a ete envoye avec succes.';

  @override
  String get back => 'Retour';

  @override
  String get sendError => 'Erreur lors de l\'envoi.';

  @override
  String get noSmsSent => 'Aucun SMS envoye';

  @override
  String get sentMessagesWillAppear => 'Les messages envoyes apparaitront ici.';

  @override
  String get deleteThisSms => 'Supprimer ce SMS ?';

  @override
  String get messageWillBeRemoved => 'Ce message sera retire de l\'historique.';

  @override
  String get delete => 'Supprimer';

  @override
  String sessionsCount(int count) {
    return '$count seance(s) - Historique et suivi';
  }

  @override
  String get all => 'Toutes';

  @override
  String get completed => 'Terminees';

  @override
  String get upcoming => 'A venir';

  @override
  String get tapToViewDetails => 'Appuyez pour consulter le detail';

  @override
  String get noSession => 'Aucune seance';

  @override
  String get sessionsFromCoaches =>
      'Les seances creees par les encadreurs\napparaitront ici.';

  @override
  String get noPositionAvailable => 'Aucun poste disponible';

  @override
  String get search => 'Rechercher';

  @override
  String get save => 'Enregistrer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get close => 'Fermer';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Precedent';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succes';

  @override
  String get warning => 'Attention';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';
}
