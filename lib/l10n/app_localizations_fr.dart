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
  String get registerSubtitle => 'Rejoignez l\'elite de la formation sportive';

  @override
  String get lastName => 'Nom';

  @override
  String get lastNameHint => 'Votre nom';

  @override
  String get lastNameRequired => 'Veuillez saisir votre nom';

  @override
  String get firstName => 'Prenom';

  @override
  String get firstNameHint => 'Votre prenom';

  @override
  String get firstNameRequired => 'Veuillez saisir votre prenom';

  @override
  String get createMyAccount => 'Creer mon compte';

  @override
  String get alreadyHaveAccount => 'Deja un compte ?';

  @override
  String get passwordStrengthWeak => 'Faible';

  @override
  String get passwordStrengthMedium => 'Moyen';

  @override
  String get passwordStrengthStrong => 'Fort';

  @override
  String get passwordStrengthExcellent => 'Excellent';

  @override
  String get passwordMinChars => 'Au moins 8 caracteres';

  @override
  String get passwordUppercase => 'Une majuscule';

  @override
  String get passwordDigit => 'Un chiffre';

  @override
  String get passwordSpecialChar => 'Un caractere special';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get resetPassword => 'Reinitialiser le mot de passe';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublie';

  @override
  String get forgotPasswordDescription =>
      'Saisissez votre email pour recevoir un code de verification a 6 chiffres.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get backToLogin => 'Retour a la connexion';

  @override
  String get otpVerification => 'Verification OTP';

  @override
  String get otpTitle => 'Verification';

  @override
  String otpDescription(String email) {
    return 'Saisissez le code a 6 chiffres envoye a\n$email';
  }

  @override
  String get verifyCode => 'Verifier le code';

  @override
  String get noCodeReceived => 'Vous n\'avez pas recu de code ? ';

  @override
  String get resend => 'Renvoyer';

  @override
  String get newPasswordTitle => 'Nouveau mot de passe';

  @override
  String get newPasswordSubtitle =>
      'Creez un nouveau mot de passe securise pour votre compte.';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get newPasswordRequired => 'Veuillez saisir un mot de passe';

  @override
  String get passwordMustBeStronger => 'Le mot de passe doit etre plus fort';

  @override
  String get resetPasswordButton => 'Reinitialiser';

  @override
  String get passwordResetSuccess => 'Mot de passe reinitialise avec succes';

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
  String get systemMode => 'Systeme';

  @override
  String get lightModeDesc => 'Apparence claire en permanence';

  @override
  String get darkModeDesc => 'Apparence sombre en permanence';

  @override
  String get systemModeDesc => 'Suit le reglage de l\'appareil';

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
  String get footballPositionsDesc =>
      'Gerez les postes attribues aux academiciens';

  @override
  String get schoolLevels => 'Niveaux scolaires';

  @override
  String get schoolLevelsSubtitle => 'CP, CE1, 6eme, 3eme, Terminale...';

  @override
  String get schoolLevelsDesc => 'Gerez les niveaux scolaires des academiciens';

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
  String get splashTagline => 'L\'excellence du football';

  @override
  String get defaultUser => 'Utilisateur';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String get onboardingTitle1 => 'Bienvenue dans l\'Excellence';

  @override
  String get onboardingDesc1 =>
      'Gerez votre academie de football avec des outils modernes, precis et concus pour la performance de haut niveau.';

  @override
  String get onboardingTitle2 => 'Presence par QR Code';

  @override
  String get onboardingDesc2 =>
      'Scannez, validez et enregistrez les acces en quelques secondes grace a un systeme rapide et securise.';

  @override
  String get onboardingTitle3 => 'Maitrisez Chaque Seance';

  @override
  String get onboardingDesc3 =>
      'Ouvrez, configurez et cloturez vos entrainements tout en gardant un controle total sur chaque activite.';

  @override
  String get onboardingTitle4 => 'Suivi des Performances';

  @override
  String get onboardingDesc4 =>
      'Ajoutez des annotations structurees et suivez la progression de chaque academicien avec precision.';

  @override
  String get onboardingTitle5 => 'Des Donnees au Service du Talent';

  @override
  String get onboardingDesc5 =>
      'Generez des bulletins professionnels, visualisez l\'evolution et optimisez le developpement de vos joueurs.';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingAfternoon => 'Bon apres-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get logoutTitle => 'Deconnexion';

  @override
  String get logoutConfirmation =>
      'Etes-vous sur de vouloir vous deconnecter ?';

  @override
  String get logoutButton => 'Deconnecter';

  @override
  String get scanLabel => 'SCAN';

  @override
  String get badgeNew => 'Nouveau';

  @override
  String get badgeGo => 'Go';

  @override
  String get activitySessionOpened => 'Seance ouverte';

  @override
  String get activitySessionClosed => 'Seance cloturee';

  @override
  String activitySessionClosedDesc(String title, int count) {
    return '$title - $count presents';
  }

  @override
  String get activitySessionScheduled => 'Seance programmee';

  @override
  String get activityNewAcademician => 'Nouvel academicien';

  @override
  String activityAcademicianRegistered(String name) {
    return '$name inscrit avec succes';
  }

  @override
  String get activityAcademicianRemoved => 'Academicien supprime';

  @override
  String activityAcademicianRemovedDesc(String name) {
    return '$name supprime du systeme';
  }

  @override
  String get activityNewCoach => 'Nouvel encadreur';

  @override
  String get activityAttendanceRecorded => 'Presence enregistree';

  @override
  String activityAttendanceDesc(String type, String name) {
    return '$type : $name';
  }

  @override
  String get activitySmsSent => 'SMS envoye';

  @override
  String activitySmsSentDesc(int count, String preview) {
    return '$count destinataires - $preview';
  }

  @override
  String get activitySmsFailed => 'SMS en echec';

  @override
  String get activitySmsFailedDesc => 'Echec de l\'envoi du message';

  @override
  String get activityReportGenerated => 'Bulletin genere';

  @override
  String get activityReferentialUpdated => 'Referentiel mis a jour';

  @override
  String activityNewPosition(String name) {
    return 'Nouveau poste : $name';
  }

  @override
  String activityPositionModified(String name) {
    return 'Poste modifie : $name';
  }

  @override
  String activityPositionRemoved(String name) {
    return 'Poste supprime : $name';
  }

  @override
  String activityNewLevel(String name) {
    return 'Nouveau niveau : $name';
  }

  @override
  String activityLevelModified(String name) {
    return 'Niveau modifie : $name';
  }

  @override
  String activityLevelRemoved(String name) {
    return 'Niveau supprime : $name';
  }

  @override
  String get profileAcademician => 'Academicien';

  @override
  String get profileCoach => 'Encadreur';

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

  @override
  String get academicianRegistrationTitle => 'Inscription Académicien';

  @override
  String get academicianPhotoLabel => 'Photo de l\'académicien';

  @override
  String get optionalLabel => '(Optionnel)';

  @override
  String get identityLabel => 'Identité';

  @override
  String get academicianPersonalDetails =>
      'Informations personnelles de l\'académicien';

  @override
  String get requiredFields => 'Champs requis';

  @override
  String get requiredField => 'Champ requis';

  @override
  String get requiredLabel => 'Requis';

  @override
  String get registrationSuccessTitle => 'Inscription réussie !';

  @override
  String get academicianQrBadgeSubtitle =>
      'Le badge QR unique de l\'académicien a été généré avec succès. Vous pouvez le partager ou le télécharger.';

  @override
  String get selectPosteAndPiedError =>
      'Veuillez sélectionner un poste et un pied fort';

  @override
  String get selectSchoolLevelError =>
      'Veuillez sélectionner un niveau scolaire';

  @override
  String get galleryOpenError => 'Impossible d\'ouvrir la galerie';

  @override
  String academicianSaveError(String error) {
    return 'Impossible d\'enregistrer l\'académicien : $error';
  }

  @override
  String get enterLastName => 'Saisir le nom';

  @override
  String get enterFirstName => 'Saisir le prénom';

  @override
  String get birthDateLabel => 'Date de naissance';

  @override
  String get birthDateFormat => 'JJ/MM/AAAA';

  @override
  String get parentPhoneLabel => 'Téléphone Parent';

  @override
  String get phoneHint => '+221 -- --- -- --';

  @override
  String get footballLabel => 'Football';

  @override
  String get sportsProfileSubtitle => 'Profil sportif sur le terrain';

  @override
  String get preferredPositionLabel => 'Poste de prédilection';

  @override
  String get strongFootLabel => 'Pied fort';

  @override
  String get rightFooted => 'Droitier';

  @override
  String get leftFooted => 'Gaucher';

  @override
  String get ambidextrous => 'Ambidextre';

  @override
  String get schoolingLabel => 'Scolarité';

  @override
  String get currentAcademicLevelSubtitle => 'Niveau académique actuel';

  @override
  String get continue_label => 'Continuer';

  @override
  String get confirm_label => 'Confirmer';

  @override
  String get previousLabel => 'Précédent';

  @override
  String get notSpecified => 'Non spécifié';

  @override
  String get notProvided => 'Non renseigné';

  @override
  String get academicianBadgeTitle => 'Badge Académicien';

  @override
  String get recapTitle => 'Récapitulatif';

  @override
  String get fullNameLabel => 'Nom complet';

  @override
  String get roleLabel => 'Rôle';

  @override
  String get posteLabel => 'Poste';

  @override
  String get registrationDateLabel => 'Date d\'inscription';

  @override
  String get academicianBadgeType => 'ACADEMICIEN';

  @override
  String get coachBadgeType => 'ENCADREUR';

  @override
  String get newCoachRegistrationTitle => 'Nouvel Encadreur';

  @override
  String get coachPersonalDetails =>
      'Informations personnelles de l\'encadreur';

  @override
  String get enterCoachLastNameHint => 'Saisir le nom de famille';

  @override
  String get enterCoachFirstNameHint => 'Saisir le prénom';

  @override
  String get phoneNumberLabel => 'Numéro de téléphone';

  @override
  String get phoneRequired => 'Le téléphone est requis';

  @override
  String get specialtyLabel => 'Spécialité';

  @override
  String get sportExpertiseSubtitle => 'Domaine d\'expertise sportive';

  @override
  String get coachSpecialtyInstructions =>
      'Sélectionnez la spécialité principale de l\'encadreur. Cela déterminera les types d\'ateliers qu\'il pourra diriger.';

  @override
  String get coachRegisteredSuccess => 'Encadreur enregistré !';

  @override
  String get specialtyRequiredError => 'Veuillez sélectionner une spécialité';

  @override
  String coachSaveError(String error) {
    return 'Impossible de créer l\'encadreur : $error';
  }

  @override
  String get qrBadgeGeneratedSuccess => 'Le badge QR a été généré avec succès.';

  @override
  String get shareLabel => 'Partager';

  @override
  String get finishLabel => 'Terminer';

  @override
  String get specialityTechnique => 'Technique';

  @override
  String get specialityTechniqueDesc => 'Dribbles, passes, tirs';

  @override
  String get specialityPhysique => 'Physique';

  @override
  String get specialityPhysiqueDesc => 'Endurance, vitesse, force';

  @override
  String get specialityTactique => 'Tactique';

  @override
  String get specialityTactiqueDesc => 'Placement, stratégie, jeu';

  @override
  String get specialityGardien => 'Gardien';

  @override
  String get specialityGardienDesc => 'Arrêts, relances, placement';

  @override
  String get specialityFormationJeunes => 'Formation jeunes';

  @override
  String get specialityFormationJeunesDesc => 'Pédagogie, initiation';

  @override
  String get specialityPreparationMentale => 'Préparation mentale';

  @override
  String get specialityPreparationMentaleDesc => 'Concentration, motivation';

  @override
  String get notificationsDisabled => 'Desactivees';

  @override
  String get notifSeancesDesc => 'Ouverture et fermeture de seances';

  @override
  String get notifPresencesDesc => 'Scans et pointages des academiciens';

  @override
  String get notifAnnotationsDesc => 'Nouvelles evaluations et observations';

  @override
  String get notifMessagesDesc => 'Communications et annonces';

  @override
  String get notifRappels => 'Rappels';

  @override
  String get notifRappelsDesc => 'Rappels de seances et echeances';

  @override
  String get notifStorageInfo =>
      'Les preferences de notifications sont enregistrees localement sur cet appareil.';

  @override
  String get appPlatformDesc =>
      'Plateforme de gestion et de suivi\ndes academiciens de football';

  @override
  String get lastUpdate => 'Derniere mise a jour';

  @override
  String get lastUpdateValue => 'Fevrier 2026';

  @override
  String get storage => 'Stockage';

  @override
  String get localStorage => 'Local (hors-ligne)';

  @override
  String get team => 'EQUIPE';

  @override
  String get developedBy => 'Developpe par';

  @override
  String get designedFor => 'Concu pour';

  @override
  String get legalInformation => 'INFORMATIONS LEGALES';

  @override
  String copyright(String app) {
    return '$app - Tous droits reserves.';
  }

  @override
  String legalUsageDesc(String app) {
    return 'Cette application est destinee a un usage interne pour la gestion des academiciens, des seances d\'entrainement, des ateliers et du suivi de performance au sein de l\'academie de football $app.';
  }

  @override
  String get legalDataDesc =>
      'Les donnees sont stockees localement sur l\'appareil. Aucune information personnelle n\'est transmise a des tiers.';

  @override
  String get madeWithPassion => 'Fait avec passion pour le football';

  @override
  String get referentialsDataDesc => 'Donnees de base de l\'application';

  @override
  String get referentialsUsageInfo =>
      'Les referentiels alimentent les formulaires d\'inscription et les filtres de l\'application.';

  @override
  String roleWithSpeciality(String role, String speciality) {
    return '$role - $speciality';
  }

  @override
  String get academiciansStat => 'Academiciens';

  @override
  String get annotationsStat => 'Annotations';

  @override
  String get workshopsStat => 'Ateliers';

  @override
  String get all_masculine => 'Tous';

  @override
  String yearsOld(int age) {
    return '$age ans';
  }

  @override
  String get deletePlayer => 'Supprimer le joueur';

  @override
  String deletePlayerConfirmation(String name) {
    return 'Êtes-vous sûr de vouloir supprimer $name ? Cette action est irréversible.';
  }

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get saveModifications => 'Enregistrer les modifications';

  @override
  String get modificationsSaved => 'Modifications enregistrées';

  @override
  String playerUpdatedSuccess(String name) {
    return '$name a été mis à jour avec succès.';
  }

  @override
  String get academiciansRegisteredSubtitle =>
      'Académiciens inscrits à l\'académie';

  @override
  String get searchPlayerHint => 'Rechercher un joueur...';

  @override
  String get totalLabel => 'Total';

  @override
  String get gardiensLabel => 'Gardiens';

  @override
  String get defLabel => 'Déf.';

  @override
  String get milLabel => 'Mil.';

  @override
  String get attLabel => 'Att.';

  @override
  String get noPlayerFound => 'Aucun joueur';

  @override
  String get noSearchResult =>
      'Aucun résultat pour cette recherche.\nEssayez avec d\'autres critères.';

  @override
  String get startByRegistering =>
      'Commencez par inscrire votre\npremier académicien pour démarrer.';

  @override
  String get registerPlayerAction => 'Inscrire un joueur';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get evaluations => 'Évaluations';

  @override
  String get sportProfile => 'Profil sportif';

  @override
  String get trainingReport => 'Bulletin de formation';

  @override
  String get trainingReportDesc =>
      'Consulter et générer le bulletin de formation périodique.';

  @override
  String get accessReport => 'Accéder au bulletin';

  @override
  String get tapToEnlargeBadge => 'Appuyez sur le badge pour l\'agrandir';

  @override
  String get downloadLabel => 'Télécharger';

  @override
  String updateError(String error) {
    return 'Impossible de mettre à jour : $error';
  }

  @override
  String academicianBadgeReady(String name) {
    return 'Le badge de $name est prêt.';
  }

  @override
  String get officialBadge => 'BADGE OFFICIEL';

  @override
  String get shareBadgeAction => 'PARTAGER LE BADGE';

  @override
  String get backToDashboard => 'RETOUR AU DASHBOARD';

  @override
  String get sharingInProgress => 'Partage en cours...';

  @override
  String get featureComingSoon => 'Fonctionnalité bientôt disponible.';

  @override
  String get sportProfileDesc =>
      'Définissez le rôle de l\'élève sur le terrain.';

  @override
  String get selectPositionHint => 'Sélectionnez un poste';

  @override
  String get selectFootHint => 'Sélectionnez le pied';

  @override
  String get confirmRegistration => 'CONFIRMER L\'INSCRIPTION';

  @override
  String get selectDate => 'Sélectionner une date';

  @override
  String get recapSubtitle =>
      'Vérifiez les informations avant la validation finale.';

  @override
  String get futureAcademician => 'Futur Académicien';

  @override
  String get qrBadgeValidationWarning =>
      'La validation générera automatiquement un Badge QR unique pour cet élève.';

  @override
  String get academicLevelTitle => 'Niveau Académique';

  @override
  String get academicStepDesc => 'Suivi de la scolarité de l\'académicien.';

  @override
  String get selectSchoolLevelHint => 'Sélectionnez le niveau';

  @override
  String get academicStepInfo =>
      'Ces informations permettent de filtrer les communications SMS et d\'adapter les rapports.';

  @override
  String get bulletinTitle => 'Bulletin de formation';

  @override
  String get bulletinSubtitle => 'Bulletin de Formation Périodique';

  @override
  String get historyTitle => 'Historique des bulletins';

  @override
  String get observationsLabel => 'Observations générales';

  @override
  String get observationsHint =>
      'Rédigez vos observations pour cette période...';

  @override
  String get encadreurLabel => 'Encadreur';

  @override
  String get sessionsLabel => 'Séances';

  @override
  String get presenceLabel => 'Présence';

  @override
  String get annotationsLabel => 'Annotations';

  @override
  String bornOn(String date) {
    return 'Né(e) le $date';
  }

  @override
  String generatedOn(String date) {
    return 'Généré le $date';
  }

  @override
  String get generateBulletin => 'Générer le bulletin';

  @override
  String get generatingInProgress => 'Génération en cours...';

  @override
  String get exportImage => 'Exporter image';

  @override
  String get noAppreciation => 'Aucune appréciation disponible';

  @override
  String get appreciationGenerationNote =>
      'Les appréciations seront générées à partir des annotations.';

  @override
  String get noObservation => 'Aucune observation rédigée.';

  @override
  String bulletinsGeneratedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bulletins générés',
      one: '1 bulletin généré',
      zero: 'Aucun bulletin généré',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughDataEvolution =>
      'Pas assez de données pour afficher l\'évolution.\nGénérez plusieurs bulletins pour voir les courbes.';

  @override
  String get radarChartTitle => 'Radar des compétences';

  @override
  String get evolutionChartTitle => 'Évolution des compétences';

  @override
  String get actualLabel => 'Actuel';

  @override
  String get competenceTechnique => 'Technique';

  @override
  String get competencePhysique => 'Physique';

  @override
  String get competenceTactique => 'Tactique';

  @override
  String get competenceMental => 'Mental';

  @override
  String get competenceEspritEquipe => 'Esprit d\'équipe';

  @override
  String get periodTitle => 'Période du bulletin';

  @override
  String get periodMonth => 'Mois';

  @override
  String get periodQuarter => 'Trimestre';

  @override
  String get periodSeason => 'Saison';

  @override
  String quarterLabel(int count, int year) {
    return 'Trimestre $count - $year';
  }

  @override
  String seasonLabel(int start, int end) {
    return 'Saison $start-$end';
  }

  @override
  String get bulletinCaptured =>
      'Bulletin capturé. Fonctionnalité de partage disponible prochainement.';

  @override
  String exportError(String error) {
    return 'Erreur lors de l\'export : $error';
  }

  @override
  String get annotationPageTitle => 'Annotations';

  @override
  String get tapToAnnotate => 'Appuyez pour annoter';

  @override
  String get noAcademicianPresent => 'Aucun academicien present';

  @override
  String get noAcademicianPresentDesc =>
      'Les academiciens presents dans la seance\napparaitront ici pour etre annotes.';

  @override
  String academiciansCount(int count) {
    return '$count academiciens';
  }

  @override
  String annotationsCount(int count) {
    return '$count annotations';
  }

  @override
  String get quickTags => 'Tags rapides';

  @override
  String get tagPositif => 'Positif';

  @override
  String get tagExcellent => 'Excellent';

  @override
  String get tagEnProgres => 'En progres';

  @override
  String get tagBonneAttitude => 'Bonne attitude';

  @override
  String get tagCreatif => 'Creatif';

  @override
  String get tagATravailler => 'A travailler';

  @override
  String get tagInsuffisant => 'Insuffisant';

  @override
  String get tagManqueEffort => 'Manque d\'effort';

  @override
  String get tagDistrait => 'Distrait';

  @override
  String get tagTechnique => 'Technique';

  @override
  String get tagDribble => 'Dribble';

  @override
  String get tagPasse => 'Passe';

  @override
  String get tagTir => 'Tir';

  @override
  String get tagPlacement => 'Placement';

  @override
  String get tagEndurance => 'Endurance';

  @override
  String get detailedObservation => 'Observation detaillee';

  @override
  String get observationHintAnnotation =>
      'Ex: Bonne lecture du jeu, manque d\'appui...';

  @override
  String get noteOptional => 'Note (optionnel)';

  @override
  String noteFormat(String note) {
    return '$note/10';
  }

  @override
  String get saving => 'Enregistrement...';

  @override
  String get saveAnnotation => 'Enregistrer l\'annotation';

  @override
  String historyCountLabel(int count) {
    return 'Historique ($count)';
  }

  @override
  String get noPreviousAnnotation => 'Aucune annotation precedente';

  @override
  String get communicationTitle => 'Communication';

  @override
  String get sentLabel => 'Envoyes';

  @override
  String get thisMonthLabel => 'Ce mois';

  @override
  String get failedLabel => 'En echec';

  @override
  String get composeAndSendSms => 'Rediger et envoyer un SMS';

  @override
  String get historyActionLabel => 'Historique';

  @override
  String recipientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count destinataires',
      one: '1 destinataire',
    );
    return '$_temp0';
  }

  @override
  String get sessionsTitle => 'Seances';

  @override
  String sessionsCountSubtitle(int count) {
    return '$count seance(s) - Historique et suivi';
  }

  @override
  String get filterAll => 'Toutes';

  @override
  String get filterInProgress => 'En cours';

  @override
  String get filterCompleted => 'Terminees';

  @override
  String get filterUpcoming => 'A venir';

  @override
  String get sessionInProgressBanner => 'SEANCE EN COURS';

  @override
  String get tapToViewDetail => 'Appuyez pour consulter le detail';

  @override
  String get sessionsCreatedByCoaches =>
      'Les seances creees par les encadreurs\napparaitront ici.';

  @override
  String get mySessionsTitle => 'Mes seances';

  @override
  String get openSessionTooltip => 'Ouvrir une seance';

  @override
  String get openFirstSession =>
      'Ouvrez votre premiere seance\npour commencer l\'entrainement.';

  @override
  String get openSession => 'Ouvrir une seance';

  @override
  String get closeThisSession => 'Fermer cette seance';

  @override
  String get fillInfoToStart => 'Remplissez les informations pour demarrer.';

  @override
  String get sessionTitleLabel => 'Titre de la seance';

  @override
  String get sessionTitleHint => 'Ex: Entrainement Technique';

  @override
  String get startLabel => 'Debut';

  @override
  String get endLabel => 'Fin';

  @override
  String get startSession => 'Demarrer la seance';

  @override
  String get pleaseEnterTitle => 'Veuillez saisir un titre.';

  @override
  String get sessionInProgressDialogTitle => 'Seance en cours';

  @override
  String get understoodButton => 'Compris';

  @override
  String get closeSessionButton => 'Fermer la seance';

  @override
  String get closeSessionDialogTitle => 'Fermer la seance';

  @override
  String get closeSessionConfirmation => 'Voulez-vous cloturer cette seance ?';

  @override
  String get dataFrozenNote =>
      'Les donnees seront figees et la seance passera en lecture seule.';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get confirmButton => 'Confirmer';

  @override
  String get sessionClosed => 'Seance cloturee';

  @override
  String get presentsRecapLabel => 'Presents';

  @override
  String get workshopsRecapLabel => 'Ateliers';

  @override
  String get perfectButton => 'Parfait';

  @override
  String presentCount(int count) {
    return '$count present(s)';
  }

  @override
  String workshopCount(int count) {
    return '$count atelier(s)';
  }

  @override
  String get meLabel => 'Moi';

  @override
  String get annotationsScreenTitle => 'Annotations';

  @override
  String get myObservationsSubtitle => 'Mes observations et evaluations';

  @override
  String get positivesLabel => 'Positives';

  @override
  String get toWorkOnLabel => 'A travailler';

  @override
  String get allTagFilter => 'Tous';

  @override
  String get inProgressTagFilter => 'En progres';

  @override
  String get techniqueTagFilter => 'Technique';

  @override
  String get encadreurSmsSubtitle =>
      'Envoyez des SMS aux academiciens et parents';

  @override
  String get statusInProgress => 'En cours';

  @override
  String get statusCompleted => 'Terminee';

  @override
  String get statusUpcoming => 'A venir';

  @override
  String presentsInfoLabel(int count) {
    return '$count presents';
  }

  @override
  String workshopsInfoLabel(int count) {
    return '$count ateliers';
  }

  @override
  String get workshopCompositionTitle => 'Ateliers';

  @override
  String workshopProgrammed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 's',
      one: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'programmes',
      one: 'programme',
    );
    return '$count atelier$_temp0 $_temp1';
  }

  @override
  String get noWorkshopProgrammed => 'Aucun atelier programme';

  @override
  String get workshopCompositionSubtitle =>
      'Composez votre seance en ajoutant des ateliers.\nChaque atelier represente un bloc d\'activite.';

  @override
  String get addWorkshopTitle => 'Ajouter un atelier';

  @override
  String get editWorkshopTitle => 'Modifier l\'atelier';

  @override
  String get deleteWorkshopTitle => 'Supprimer l\'atelier ?';

  @override
  String deleteWorkshopConfirmation(String name) {
    return 'L\'atelier \"$name\" sera definitivement supprime.';
  }

  @override
  String get selectExerciseType => 'Selectionnez un type d\'exercice';

  @override
  String get workshopNameLabel => 'Nom de l\'atelier';

  @override
  String get workshopNameHint => 'Ex: Dribble en slalom';

  @override
  String get workshopNameRequired => 'Le nom est requis';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'Ex: Travail des appuis et conduite de balle';

  @override
  String get saveWorkshop => 'Ajouter cet atelier';

  @override
  String get annotateAction => 'Annoter';

  @override
  String get workshopTypeDribble => 'Dribble';

  @override
  String get workshopTypePasses => 'Passes';

  @override
  String get workshopTypeFinition => 'Finition';

  @override
  String get workshopTypePhysique => 'Condition physique';

  @override
  String get workshopTypeJeuEnSituation => 'Jeu en situation';

  @override
  String get workshopTypeTactique => 'Tactique';

  @override
  String get workshopTypeGardien => 'Gardien';

  @override
  String get workshopTypeEchauffement => 'Echauffement';

  @override
  String get workshopTypePersonnalise => 'Personnalise';

  @override
  String get sessionAddAtLeastOneWorkshop =>
      'Ajoutez au moins un atelier pour pouvoir annoter.';

  @override
  String get presentCoaches => 'Encadreurs presents';

  @override
  String get responsibleLabel => 'Responsable';

  @override
  String get horaireLabel => 'Horaire';

  @override
  String get manageAction => 'Gerer';

  @override
  String get noCoachRegistered => 'Aucun encadreur enregistre';

  @override
  String get noAcademicianRegistered => 'Aucun academicien enregistre';

  @override
  String get searchHint => 'Rechercher un academicien, encadreur, seance...';

  @override
  String get recentSearches => 'Recherches recentes';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get universalSearch => 'Recherche universelle';

  @override
  String get universalSearchDesc =>
      'Trouvez rapidement un academicien, un encadreur ou une seance.';

  @override
  String get noResultsFound => 'Aucun resultat';

  @override
  String get noResultsDesc => 'Essayez avec d\'autres termes de recherche.';

  @override
  String get playerLabel => 'Joueur';

  @override
  String get academicianFile => 'Fiche Academicien';

  @override
  String get infosTab => 'Infos';

  @override
  String get presencesTab => 'Presences';

  @override
  String get notesTab => 'Notes';

  @override
  String get bulletinsTab => 'Bulletins';

  @override
  String get personalInfos => 'Informations personnelles';

  @override
  String get sportInfos => 'Informations sportives';

  @override
  String get ageLabel => 'Age';

  @override
  String get noPresenceRecorded => 'Aucune presence enregistree';

  @override
  String get noAnnotationRecorded => 'Aucune annotation enregistree';

  @override
  String get noBulletinGenerated => 'Aucun bulletin genere';

  @override
  String get coachFile => 'Fiche Encadreur';

  @override
  String get statsTab => 'Stats';

  @override
  String get activityLabel => 'Activite';

  @override
  String get conductedSessions => 'Seances dirigees';

  @override
  String get conductedAnnotations => 'Annotations realisees';

  @override
  String get recordedPresences => 'Presences enregistrees';

  @override
  String get noConductedSession => 'Aucune seance dirigee';

  @override
  String get closedSessionsStat => 'Seances cloturees';

  @override
  String get avgPresents => 'Moy. presents';

  @override
  String get totalWorkshops => 'Total ateliers';

  @override
  String get closureRate => 'Taux de cloture';

  @override
  String get keyFigures => 'Chiffres cles';

  @override
  String get scannedPresences => 'Presences scannees';

  @override
  String get teamTab => 'Equipe';

  @override
  String get recapTab => 'Recap';

  @override
  String get sessionDetailTitle => 'Detail Seance';

  @override
  String get cancelAction => 'Annuler';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get saveAction => 'Enregistrer';

  @override
  String get addAction => 'Ajouter';

  @override
  String get editAction => 'Modifier';

  @override
  String get sessionStatusOpen => 'En cours';

  @override
  String get sessionStatusClosed => 'Fermee';

  @override
  String get sessionStatusUpcoming => 'A venir';

  @override
  String lastUpdateWithDate(String date) {
    return 'Mis a jour le $date';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get positionLabel => 'Poste';

  @override
  String get schoolLevelLabel => 'Niveau scolaire';

  @override
  String get qrCodeLabel => 'Code QR';

  @override
  String noteLabel(String note) {
    return 'Note : $note/10';
  }

  @override
  String get phoneLabel => 'Telephone';

  @override
  String get registeredOnLabel => 'Inscrit le';

  @override
  String get sessionLabel => 'Seance';

  @override
  String get coachLabel => 'Coach';

  @override
  String presentCountLabel(String count) {
    return '$count present(s)';
  }

  @override
  String workshopCountLabel(String count) {
    return '$count atelier(s)';
  }

  @override
  String coachWithNumber(int number) {
    return 'Encadreur $number';
  }

  @override
  String academicianWithNumber(int number) {
    return 'Academicien $number';
  }

  @override
  String get academicianProfileTitle => 'Fiche Academicien';

  @override
  String get academicianBadgeTypeMention => 'ACADEMICIEN';

  @override
  String get coachProfileTitle => 'Fiche Encadreur';

  @override
  String get coachBadgeTypeMention => 'ENCADREUR';

  @override
  String get recapLabel => 'Recapitulatif';

  @override
  String get statsLabel => 'Statistiques';

  @override
  String get sessionsTab => 'Séances';

  @override
  String get presentLabel => 'Présent';

  @override
  String sessionWithIdLabel(String id) {
    return 'Seance $id...';
  }

  @override
  String get statusLabel => 'Statut';

  @override
  String get generalInformation => 'Informations générales';

  @override
  String get presentAcademicians => 'Académiciens présents';

  @override
  String get completedWorkshops => 'Ateliers réalisés';

  @override
  String get noCoachRecorded => 'Aucun encadreur enregistré';

  @override
  String get noAcademicianRecorded => 'Aucun académicien enregistré';

  @override
  String get noWorkshopRecorded => 'Aucun atelier enregistré';

  @override
  String get at => ' à ';

  @override
  String notesInfoLabel(int count) {
    return '$count notes';
  }

  @override
  String get smsComposeTitle => 'Nouveau SMS';

  @override
  String get smsComposeHeader => 'Rédigez votre message';

  @override
  String get smsComposeSubHeader =>
      'Le message sera envoyé par SMS aux destinataires sélectionnés.';

  @override
  String get smsComposeHint => 'Saisissez votre message ici...';

  @override
  String smsComposeCharCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count caractères',
      one: '$count caractère',
    );
    return '$_temp0';
  }

  @override
  String smsComposeSmsCount(int count) {
    return '$count SMS';
  }

  @override
  String smsComposeRemainingChars(int count) {
    return '$count restants';
  }

  @override
  String get smsComposeChooseRecipients => 'Choisir les destinataires';

  @override
  String get smsConfirmationTitle => 'Confirmation';

  @override
  String get smsConfirmationSummary => 'Récapitulatif';

  @override
  String get smsConfirmationCheckInfo =>
      'Vérifiez les informations avant l\'envoi.';

  @override
  String smsConfirmationRecipient(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Destinataires',
      one: 'Destinataire',
    );
    return '$_temp0';
  }

  @override
  String get smsConfirmationSmsPerPerson => 'SMS / personne';

  @override
  String get smsConfirmationTotalSms => 'SMS total';

  @override
  String get smsConfirmationMessage => 'Message';

  @override
  String smsConfirmationMessageInfo(int length, int count) {
    return '$length caractères - $count SMS';
  }

  @override
  String smsConfirmationRecipientsCount(int count) {
    return 'Destinataires ($count)';
  }

  @override
  String get smsConfirmationSendSms => 'Envoyer les SMS';

  @override
  String get smsConfirmationConfirmSend => 'Confirmer l\'envoi';

  @override
  String smsConfirmationDialogBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'destinataires',
      one: 'destinataire',
    );
    return 'Vous êtes sur le point d\'envoyer ce message à $count $_temp0.\n\nCette action est irréversible.';
  }

  @override
  String get smsConfirmationCancel => 'Annuler';

  @override
  String get smsConfirmationConfirm => 'Confirmer';

  @override
  String get smsConfirmationSuccessTitle => 'SMS envoyé !';

  @override
  String get smsConfirmationSuccessBody =>
      'Le message a été envoyé avec succès.';

  @override
  String get smsConfirmationBack => 'Retour';

  @override
  String get smsConfirmationError => 'Erreur lors de l\'envoi.';

  @override
  String get smsHistoryTitle => 'Historique SMS';

  @override
  String get smsHistoryNoSms => 'Aucun SMS envoyé';

  @override
  String get smsHistoryNoSmsDescription =>
      'Les messages envoyés apparaîtront ici.';

  @override
  String get smsStatusSent => 'Envoyé';

  @override
  String get smsStatusFailed => 'Échec';

  @override
  String get smsStatusPending => 'En attente';

  @override
  String get dateTimeJustNow => 'À l\'instant';

  @override
  String dateTimeMinutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String dateTimeHoursAgo(int hours) {
    return 'Il y a ${hours}h';
  }

  @override
  String get dateTimeYesterday => 'Hier';

  @override
  String dateTimeDaysAgo(int days) {
    return 'Il y a $days jours';
  }

  @override
  String smsHistoryMoreRecipients(int count) {
    return '+$count';
  }

  @override
  String get smsHistoryMessage => 'Message';

  @override
  String smsHistoryRecipients(int count) {
    return 'Destinataires ($count)';
  }

  @override
  String get smsHistoryDeleteTitle => 'Supprimer ce SMS ?';

  @override
  String get smsHistoryDeleteBody => 'Ce message sera retiré de l\'historique.';

  @override
  String get smsHistoryDeleteCancel => 'Annuler';

  @override
  String get smsHistoryDeleteConfirm => 'Supprimer';

  @override
  String get smsRecipientsTitle => 'Destinataires';

  @override
  String get smsRecipientsTabIndividual => 'Individuel';

  @override
  String get smsRecipientsTabFilters => 'Filtres';

  @override
  String get smsRecipientsTabSelection => 'Sélection';

  @override
  String get smsRecipientsSearchHint => 'Rechercher par nom...';

  @override
  String get smsRecipientsAcademiciens => 'Académiciens';

  @override
  String get smsRecipientsNoAcademiciens => 'Aucun académicien trouvé';

  @override
  String get smsRecipientsEncadreurs => 'Encadreurs';

  @override
  String get smsRecipientsNoEncadreurs => 'Aucun encadreur trouvé';

  @override
  String get smsRecipientsQuickSelection => 'Sélection rapide';

  @override
  String get smsRecipientsAllAcademiciens => 'Tous les académiciens';

  @override
  String get smsRecipientsAllEncadreurs => 'Tous les encadreurs';

  @override
  String get smsRecipientsByFootballPoste => 'Par poste de football';

  @override
  String get smsRecipientsNoPosteAvailable => 'Aucun poste disponible';

  @override
  String get smsRecipientsBySchoolLevel => 'Par niveau scolaire';

  @override
  String get smsRecipientsNoLevelAvailable => 'Aucun niveau disponible';

  @override
  String get smsRecipientsNoRecipientSelected =>
      'Aucun destinataire sélectionné';

  @override
  String get smsRecipientsNoRecipientSelectedDesc =>
      'Utilisez les onglets Individuel ou Filtres\npour ajouter des destinataires.';

  @override
  String smsRecipientsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '$count sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get smsRecipientsRemoveAll => 'Tout retirer';

  @override
  String get smsRecipientsPreview => 'Prévisualiser';

  @override
  String get workshops => 'Ateliers';

  @override
  String get academician => 'Académicien';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get deleteLevel => 'Supprimer le niveau';

  @override
  String deleteLevelConfirmation(String name) {
    return 'Voulez-vous vraiment supprimer le niveau \"$name\" ?';
  }

  @override
  String get editLevel => 'Modifier le niveau';

  @override
  String get newLevel => 'Nouveau niveau';

  @override
  String get levelName => 'Nom du niveau';

  @override
  String get nameRequired => 'Le nom est obligatoire';

  @override
  String get displayOrder => 'Ordre d\'affichage';

  @override
  String get orderRequired => 'L\'ordre est obligatoire';

  @override
  String get enterNumberError => 'Veuillez saisir un nombre';

  @override
  String levelsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count niveaux',
      one: '1 niveau',
      zero: 'Aucun niveau',
    );
    return '$_temp0';
  }

  @override
  String get manageAcademicLevels => 'Gestion des niveaux académiques';

  @override
  String get noLevel => 'Aucun niveau';

  @override
  String get addFirstLevel =>
      'Ajoutez votre premier niveau scolaire\npour commencer.';

  @override
  String get deletePosition => 'Supprimer le poste';

  @override
  String deletePositionConfirmation(String name) {
    return 'Voulez-vous vraiment supprimer le poste \"$name\" ?';
  }

  @override
  String get editPosition => 'Modifier le poste';

  @override
  String get newPosition => 'Nouveau poste';

  @override
  String get positionName => 'Nom du poste';

  @override
  String get descriptionOptional => 'Description (optionnelle)';

  @override
  String positionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count postes',
      one: '1 poste',
      zero: 'Aucun poste',
    );
    return '$_temp0';
  }

  @override
  String get managePositions => 'Gestion des postes de jeu';

  @override
  String get noPosition => 'Aucun poste';

  @override
  String get addFirstPosition =>
      'Ajoutez votre premier poste de football\npour commencer.';

  @override
  String unreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count non lues',
      one: '1 non lue',
      zero: 'Aucune non lue',
    );
    return '$_temp0';
  }

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get deleteRead => 'Supprimer les lues';

  @override
  String get registrations => 'Inscriptions';

  @override
  String get smsLabel => 'SMS';

  @override
  String get reminders => 'Rappels';

  @override
  String get system => 'Système';

  @override
  String get unreadOnly => 'Non lues uniquement';

  @override
  String get noNotification => 'Aucune notification';

  @override
  String get notificationsUpToDate =>
      'Vous êtes à jour ! Les nouvelles notifications apparaîtront ici.';

  @override
  String get deleteThisNotification => 'Supprimer cette notification';

  @override
  String get deleteReadConfirmation =>
      'Voulez-vous supprimer toutes les notifications déjà lues ?';

  @override
  String get placeQrInViewfinder => 'Placez le code QR dans le viseur';

  @override
  String get rapidEntry => 'Entrée Rapide';

  @override
  String get rapidEntryDesc => 'Enchaîner les scans automatiquement';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get attendanceRecordedSuccess => 'Présence enregistrée';

  @override
  String get alreadyRegisteredForSession => 'Déjà enregistré pour cette séance';

  @override
  String get nextScan => 'Scanner suivant';

  @override
  String get presences => 'Présences';

  @override
  String get bulletin => 'Bulletin';

  @override
  String get low => 'BASSE';

  @override
  String get normal => 'NORMALE';

  @override
  String get high => 'HAUTE';

  @override
  String get urgent => 'URGENTE';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get january => 'Janvier';

  @override
  String get february => 'Février';

  @override
  String get march => 'Mars';

  @override
  String get april => 'Avril';

  @override
  String get may => 'Mai';

  @override
  String get june => 'Juin';

  @override
  String get july => 'Juillet';

  @override
  String get august => 'Août';

  @override
  String get september => 'Septembre';

  @override
  String get october => 'Octobre';

  @override
  String get november => 'Novembre';

  @override
  String get december => 'Décembre';

  @override
  String get qrScanner => 'Scanner QR';

  @override
  String get encadreursPageTitle => 'Encadreurs';

  @override
  String get coachTeamManagement => 'Gestion de l\'equipe d\'encadrement';

  @override
  String get searchCoachHint => 'Rechercher un encadreur...';

  @override
  String get statActifs => 'Actifs';

  @override
  String get noCoachFound => 'Aucun encadreur';

  @override
  String get addCoachAction => 'Ajouter un encadreur';

  @override
  String get startByRegisteringCoach =>
      'Commencez par enregistrer votre\npremier encadreur pour demarrer.';

  @override
  String get deleteCoachTitle => 'Supprimer l\'encadreur';

  @override
  String deleteCoachConfirmation(String name) {
    return 'Etes-vous sur de vouloir supprimer $name ? Cette action est irreversible.';
  }

  @override
  String get tabBadgeQr => 'Badge QR';

  @override
  String get identifiantsSection => 'Identifiants';

  @override
  String get noSessionConductedHist => 'Aucune seance dirigee';

  @override
  String get sessionHistoryWillAppear =>
      'L\'historique des seances apparaitra ici\nune fois que l\'encadreur aura dirige des seances.';

  @override
  String sessionNumber(int num) {
    return 'Seance #$num';
  }

  @override
  String sessionTrainingType(String specialty) {
    return 'Entrainement $specialty';
  }

  @override
  String get viewQrBadgeOption => 'Voir le badge QR';

  @override
  String get shareProfileOption => 'Partager le profil';

  @override
  String get badgeEncadreurLabel => 'BADGE ENCADREUR';

  @override
  String get statusConnected => 'Connecte';

  @override
  String get statusOffline => 'Hors-ligne';

  @override
  String get statusSyncing => 'Synchronisation...';

  @override
  String get syncStatusTitle => 'Statut de synchronisation';

  @override
  String get connectionLabel => 'Connexion';

  @override
  String get pendingOperationsLabel => 'Operations en attente';

  @override
  String get lastSyncLabel => 'Derniere synchronisation';

  @override
  String syncSuccessResult(int success, int failures) {
    return '$success reussie(s), $failures echec(s)';
  }

  @override
  String get syncNowLabel => 'Synchroniser maintenant';

  @override
  String get syncInProgressLabel => 'Synchronisation en cours...';

  @override
  String get offlineModeActive => 'Mode hors-ligne actif';

  @override
  String pendingOperationsCount(int count) {
    return '$count operation(s) en attente';
  }

  @override
  String get syncOnReconnect =>
      'Les donnees seront synchronisees au retour du reseau';

  @override
  String get exceptionNetworkDefault => 'Pas de connexion internet';

  @override
  String get exceptionNetworkCheck =>
      'Pas de connexion internet. Verifiez votre reseau.';

  @override
  String get exceptionTimeoutDefault => 'Le delai d\'attente a expire';

  @override
  String get exceptionTimeoutServer =>
      'Le serveur met trop de temps a repondre.';

  @override
  String get exceptionServerDefault => 'Erreur interne du serveur';

  @override
  String get exceptionServerHttp => 'Erreur de protocole HTTP.';

  @override
  String get exceptionRequestBad => 'Format de donnees invalide.';

  @override
  String get exceptionRequestBadDetails => 'JSON malforme ou type incorrect.';

  @override
  String get exceptionNotFoundDefault => 'Ressource introuvable';

  @override
  String get exceptionAuthDefault => 'Non authentifie';

  @override
  String get exceptionPermissionDefault => 'Acces refuse';

  @override
  String get exceptionCacheDefault =>
      'Erreur de chargement des donnees locales';

  @override
  String get exceptionUnknownDefault => 'Une erreur inattendue est survenue';

  @override
  String get exceptionUnknownTechnical =>
      'Une erreur inattendue est survenue (technique).';

  @override
  String exceptionCacheReadKey(String key, String error) {
    return 'Erreur lors de la lecture de la cle \'\'$key\'\' : $error';
  }

  @override
  String exceptionCacheWriteKey(String key, String error) {
    return 'Erreur lors de l\'\'ecriture de la cle \'\'$key\'\' : $error';
  }

  @override
  String exceptionCacheReadString(String key, String error) {
    return 'Erreur lors de la lecture de la chaine \'\'$key\'\' : $error';
  }

  @override
  String exceptionCacheWriteString(String key, String error) {
    return 'Erreur lors de l\'\'ecriture de la chaine \'\'$key\'\' : $error';
  }

  @override
  String exceptionCacheDeleteKey(String key, String error) {
    return 'Erreur lors de la suppression de la cle \'\'$key\'\' : $error';
  }

  @override
  String exceptionCacheResetPrefs(String error) {
    return 'Erreur lors de la reinitialisation des preferences : $error';
  }

  @override
  String get serviceSeanceNotFound => 'Seance introuvable.';

  @override
  String get serviceSeanceAlreadyClosed => 'Cette seance est deja cloturee.';

  @override
  String serviceSeanceCannotOpen(String title) {
    return 'Impossible d\'\'ouvrir une nouvelle seance. La seance \"$title\" est encore ouverte. Veuillez la cloturer avant d\'\'en ouvrir une nouvelle.';
  }

  @override
  String serviceSeanceOpenedSuccess(String title) {
    return 'Seance \"$title\" ouverte avec succes.';
  }

  @override
  String serviceSeanceClosedSuccess(String title) {
    return 'Seance \"$title\" cloturee avec succes.';
  }

  @override
  String get serviceRefPosteExists => 'Un poste avec ce nom existe deja.';

  @override
  String get serviceRefPosteOtherExists =>
      'Un autre poste avec ce nom existe deja.';

  @override
  String serviceRefPosteCreated(String name) {
    return 'Poste \"$name\" cree avec succes.';
  }

  @override
  String serviceRefPosteUpdated(String name) {
    return 'Poste \"$name\" modifie avec succes.';
  }

  @override
  String get serviceRefPosteDeleted => 'Poste supprime avec succes.';

  @override
  String serviceRefPosteCannotDelete(int count) {
    return 'Impossible de supprimer ce poste : $count academicien(s) rattache(s).';
  }

  @override
  String get serviceRefNiveauExists => 'Un niveau avec ce nom existe deja.';

  @override
  String get serviceRefNiveauOtherExists =>
      'Un autre niveau avec ce nom existe deja.';

  @override
  String serviceRefNiveauCreated(String name) {
    return 'Niveau \"$name\" cree avec succes.';
  }

  @override
  String serviceRefNiveauUpdated(String name) {
    return 'Niveau \"$name\" modifie avec succes.';
  }

  @override
  String get serviceRefNiveauDeleted => 'Niveau supprime avec succes.';

  @override
  String serviceRefNiveauCannotDelete(int count) {
    return 'Impossible de supprimer ce niveau : $count academicien(s) rattache(s).';
  }

  @override
  String get serviceScanPresenceAlreadyRecorded => 'Presence deja enregistree';

  @override
  String get serviceScanAcademicianIdentified => 'Academicien identifie';

  @override
  String get serviceScanCoachIdentified => 'Encadreur identifie';

  @override
  String get serviceScanQrNotRecognized => 'Code QR non reconnu';

  @override
  String get serviceScanTypeAcademician => 'Academicien';

  @override
  String get serviceScanTypeCoach => 'Encadreur';

  @override
  String serviceAtelierSeanceNotFound(String id) {
    return 'Seance introuvable : $id';
  }

  @override
  String serviceAtelierNotFound(String id) {
    return 'Atelier introuvable : $id';
  }

  @override
  String serviceBulletinNotFound(String id) {
    return 'Bulletin introuvable : $id';
  }

  @override
  String get serviceSyncMaxRetries => 'Nombre maximum de tentatives atteint';

  @override
  String get serviceSearchAcademicianSubtitle => 'Academicien';

  @override
  String serviceSearchCoachSubtitle(String specialty) {
    return 'Encadreur - $specialty';
  }

  @override
  String infraSeanceNotFound(String id) {
    return 'Seance non trouvee : $id';
  }

  @override
  String infraSmsNotFound(String id) {
    return 'SMS introuvable : $id';
  }

  @override
  String get domaineTechnique => 'Technique';

  @override
  String get domainePhysique => 'Physique';

  @override
  String get domaineTactique => 'Tactique';

  @override
  String get domaineMental => 'Mental';

  @override
  String get domaineEspritEquipe => 'Esprit d\'\'equipe';

  @override
  String get domaineGeneral => 'General';

  @override
  String bulletinObservationsResume(int count, String content) {
    return '$count observations. Derniere : $content';
  }
}
