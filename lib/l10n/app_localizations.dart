import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pepites Academy'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get login;

  /// No description provided for @loginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accedez a votre espace encadreur ou administrateur'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In fr, this message translates to:
  /// **'votre@email.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre email'**
  String get emailRequired;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @passwordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre mot de passe'**
  String get passwordRequired;

  /// No description provided for @forgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublie ?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas de compte ?'**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In fr, this message translates to:
  /// **'Creer un compte'**
  String get createAccount;

  /// No description provided for @welcomeBack.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue !'**
  String get welcomeBack;

  /// No description provided for @connectedAs.
  ///
  /// In fr, this message translates to:
  /// **'Connecte en tant que {role}'**
  String connectedAs(String role);

  /// No description provided for @loginFailed.
  ///
  /// In fr, this message translates to:
  /// **'Echec de connexion'**
  String get loginFailed;

  /// No description provided for @loginFailedDescription.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants incorrects. Utilisez les comptes de test.'**
  String get loginFailedDescription;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Se deconnecter'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get register;

  /// No description provided for @resetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Reinitialiser le mot de passe'**
  String get resetPassword;

  /// No description provided for @otpVerification.
  ///
  /// In fr, this message translates to:
  /// **'Verification OTP'**
  String get otpVerification;

  /// No description provided for @settings.
  ///
  /// In fr, this message translates to:
  /// **'Parametres'**
  String get settings;

  /// No description provided for @settingsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Configuration de l\'application'**
  String get settingsSubtitle;

  /// No description provided for @general.
  ///
  /// In fr, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @administration.
  ///
  /// In fr, this message translates to:
  /// **'Administration'**
  String get administration;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageActive.
  ///
  /// In fr, this message translates to:
  /// **'Langue active'**
  String get languageActive;

  /// No description provided for @languageInfo.
  ///
  /// In fr, this message translates to:
  /// **'La langue est appliquee immediatement et sauvegardee pour les prochaines sessions.'**
  String get languageInfo;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Francais'**
  String get french;

  /// No description provided for @english.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @theme.
  ///
  /// In fr, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Systeme'**
  String get themeSystem;

  /// No description provided for @themeLightDescription.
  ///
  /// In fr, this message translates to:
  /// **'Apparence claire en permanence'**
  String get themeLightDescription;

  /// No description provided for @themeDarkDescription.
  ///
  /// In fr, this message translates to:
  /// **'Apparence sombre en permanence'**
  String get themeDarkDescription;

  /// No description provided for @themeSystemDescription.
  ///
  /// In fr, this message translates to:
  /// **'Suit le reglage de l\'appareil'**
  String get themeSystemDescription;

  /// No description provided for @themeActiveLabel.
  ///
  /// In fr, this message translates to:
  /// **'Theme actif : {label}'**
  String themeActiveLabel(String label);

  /// No description provided for @themeInfo.
  ///
  /// In fr, this message translates to:
  /// **'Le theme est applique immediatement et sauvegarde pour les prochaines sessions.'**
  String get themeInfo;

  /// No description provided for @darkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode clair'**
  String get lightMode;

  /// No description provided for @appearance.
  ///
  /// In fr, this message translates to:
  /// **'APPARENCE'**
  String get appearance;

  /// No description provided for @notifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Activees'**
  String get notificationsEnabled;

  /// No description provided for @about.
  ///
  /// In fr, this message translates to:
  /// **'A propos'**
  String get about;

  /// No description provided for @version.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @referentials.
  ///
  /// In fr, this message translates to:
  /// **'Referentiels'**
  String get referentials;

  /// No description provided for @referentialsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Postes, Niveaux'**
  String get referentialsSubtitle;

  /// No description provided for @categories.
  ///
  /// In fr, this message translates to:
  /// **'CATEGORIES'**
  String get categories;

  /// No description provided for @footballPositions.
  ///
  /// In fr, this message translates to:
  /// **'Postes de football'**
  String get footballPositions;

  /// No description provided for @footballPositionsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gardien, Defenseur, Milieu, Attaquant...'**
  String get footballPositionsSubtitle;

  /// No description provided for @footballPositionsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Gerez les postes attribues aux academiciens'**
  String get footballPositionsDescription;

  /// No description provided for @schoolLevels.
  ///
  /// In fr, this message translates to:
  /// **'Niveaux scolaires'**
  String get schoolLevels;

  /// No description provided for @schoolLevelsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'CP, CE1, 6eme, 3eme, Terminale...'**
  String get schoolLevelsSubtitle;

  /// No description provided for @schoolLevelsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Gerez les niveaux scolaires des academiciens'**
  String get schoolLevelsDescription;

  /// No description provided for @home.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get home;

  /// No description provided for @academy.
  ///
  /// In fr, this message translates to:
  /// **'Academie'**
  String get academy;

  /// No description provided for @sessions.
  ///
  /// In fr, this message translates to:
  /// **'Seances'**
  String get sessions;

  /// No description provided for @communication.
  ///
  /// In fr, this message translates to:
  /// **'Communication'**
  String get communication;

  /// No description provided for @profile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @myProfile.
  ///
  /// In fr, this message translates to:
  /// **'Mon profil'**
  String get myProfile;

  /// No description provided for @administrator.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get administrator;

  /// No description provided for @coach.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur'**
  String get coach;

  /// No description provided for @overview.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble'**
  String get overview;

  /// No description provided for @quickActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions rapides'**
  String get quickActions;

  /// No description provided for @sessionOfTheDay.
  ///
  /// In fr, this message translates to:
  /// **'Seance du jour'**
  String get sessionOfTheDay;

  /// No description provided for @history.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get history;

  /// No description provided for @globalPerformance.
  ///
  /// In fr, this message translates to:
  /// **'Performance globale'**
  String get globalPerformance;

  /// No description provided for @recentActivity.
  ///
  /// In fr, this message translates to:
  /// **'Activite recente'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get viewAll;

  /// No description provided for @academicians.
  ///
  /// In fr, this message translates to:
  /// **'Academiciens'**
  String get academicians;

  /// No description provided for @coaches.
  ///
  /// In fr, this message translates to:
  /// **'Encadreurs'**
  String get coaches;

  /// No description provided for @sessionsMonth.
  ///
  /// In fr, this message translates to:
  /// **'Seances (mois)'**
  String get sessionsMonth;

  /// No description provided for @attendanceRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux presence'**
  String get attendanceRate;

  /// No description provided for @register_action.
  ///
  /// In fr, this message translates to:
  /// **'Inscrire'**
  String get register_action;

  /// No description provided for @newAcademician.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel academicien'**
  String get newAcademician;

  /// No description provided for @scanQr.
  ///
  /// In fr, this message translates to:
  /// **'Scanner QR'**
  String get scanQr;

  /// No description provided for @accessControl.
  ///
  /// In fr, this message translates to:
  /// **'Controle d\'acces'**
  String get accessControl;

  /// No description provided for @players.
  ///
  /// In fr, this message translates to:
  /// **'Joueurs'**
  String get players;

  /// No description provided for @academiciansList.
  ///
  /// In fr, this message translates to:
  /// **'Liste des academiciens'**
  String get academiciansList;

  /// No description provided for @coachManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des coachs'**
  String get coachManagement;

  /// No description provided for @manageAcademy.
  ///
  /// In fr, this message translates to:
  /// **'Gerez l\'ensemble de votre academie depuis cet espace centralise.'**
  String get manageAcademy;

  /// No description provided for @averageAttendance.
  ///
  /// In fr, this message translates to:
  /// **'Presence\nmoyenne'**
  String get averageAttendance;

  /// No description provided for @goalsAchieved.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs\natteints'**
  String get goalsAchieved;

  /// No description provided for @coachSatisfaction.
  ///
  /// In fr, this message translates to:
  /// **'Satisfaction\nencadreurs'**
  String get coachSatisfaction;

  /// No description provided for @positiveTrend.
  ///
  /// In fr, this message translates to:
  /// **'Tendance positive : +8% de presence en Fevrier par rapport a Janvier.'**
  String get positiveTrend;

  /// No description provided for @noRecentActivity.
  ///
  /// In fr, this message translates to:
  /// **'Aucune activite recente.'**
  String get noRecentActivity;

  /// No description provided for @noSessionRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucune seance enregistree.'**
  String get noSessionRecorded;

  /// No description provided for @justNow.
  ///
  /// In fr, this message translates to:
  /// **'A l\'instant'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {minutes} min'**
  String minutesAgo(int minutes);

  /// No description provided for @hoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {hours}h'**
  String hoursAgo(int hours);

  /// No description provided for @yesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {days} jours'**
  String daysAgo(int days);

  /// No description provided for @noSessionInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Aucune seance en cours'**
  String get noSessionInProgress;

  /// No description provided for @openSessionBeforeScan.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez ouvrir une seance avant de scanner.'**
  String get openSessionBeforeScan;

  /// No description provided for @openSessionBeforeWorkshops.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez ouvrir une seance avant de gerer les ateliers.'**
  String get openSessionBeforeWorkshops;

  /// No description provided for @readyForField.
  ///
  /// In fr, this message translates to:
  /// **'Pret pour le terrain'**
  String get readyForField;

  /// No description provided for @manageSessionsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Gerez vos seances, evaluez vos joueurs et suivez leur progression.'**
  String get manageSessionsDescription;

  /// No description provided for @sessionInProgress.
  ///
  /// In fr, this message translates to:
  /// **'SEANCE EN COURS'**
  String get sessionInProgress;

  /// No description provided for @inProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get inProgress;

  /// No description provided for @present.
  ///
  /// In fr, this message translates to:
  /// **'Presents'**
  String get present;

  /// No description provided for @workshops.
  ///
  /// In fr, this message translates to:
  /// **'Ateliers'**
  String get workshops;

  /// No description provided for @annotations.
  ///
  /// In fr, this message translates to:
  /// **'Annotations'**
  String get annotations;

  /// No description provided for @addWorkshop.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter atelier'**
  String get addWorkshop;

  /// No description provided for @closeSession.
  ///
  /// In fr, this message translates to:
  /// **'Fermer seance'**
  String get closeSession;

  /// No description provided for @noCurrentSession.
  ///
  /// In fr, this message translates to:
  /// **'Aucune seance en cours'**
  String get noCurrentSession;

  /// No description provided for @openSessionToStart.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez une seance pour commencer.'**
  String get openSessionToStart;

  /// No description provided for @myActivity.
  ///
  /// In fr, this message translates to:
  /// **'Mon activite'**
  String get myActivity;

  /// No description provided for @fieldActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions terrain'**
  String get fieldActions;

  /// No description provided for @myAcademicians.
  ///
  /// In fr, this message translates to:
  /// **'Mes academiciens'**
  String get myAcademicians;

  /// No description provided for @myIndicators.
  ///
  /// In fr, this message translates to:
  /// **'Mes indicateurs'**
  String get myIndicators;

  /// No description provided for @myRecentAnnotations.
  ///
  /// In fr, this message translates to:
  /// **'Mes dernieres annotations'**
  String get myRecentAnnotations;

  /// No description provided for @sessionsConducted.
  ///
  /// In fr, this message translates to:
  /// **'Seances dirigees'**
  String get sessionsConducted;

  /// No description provided for @workshopsCreated.
  ///
  /// In fr, this message translates to:
  /// **'Ateliers crees'**
  String get workshopsCreated;

  /// No description provided for @averageAttendanceShort.
  ///
  /// In fr, this message translates to:
  /// **'Presence moy.'**
  String get averageAttendanceShort;

  /// No description provided for @myAnnotations.
  ///
  /// In fr, this message translates to:
  /// **'Mes annotations'**
  String get myAnnotations;

  /// No description provided for @evaluateAcademician.
  ///
  /// In fr, this message translates to:
  /// **'Evaluer un academicien'**
  String get evaluateAcademician;

  /// No description provided for @myWorkshops.
  ///
  /// In fr, this message translates to:
  /// **'Mes ateliers'**
  String get myWorkshops;

  /// No description provided for @manageExercises.
  ///
  /// In fr, this message translates to:
  /// **'Gerer les exercices'**
  String get manageExercises;

  /// No description provided for @attendance.
  ///
  /// In fr, this message translates to:
  /// **'Presences'**
  String get attendance;

  /// No description provided for @scanArrivals.
  ///
  /// In fr, this message translates to:
  /// **'Scanner les arrivees'**
  String get scanArrivals;

  /// No description provided for @attendanceRateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Taux de\npresence'**
  String get attendanceRateLabel;

  /// No description provided for @annotationsPerSession.
  ///
  /// In fr, this message translates to:
  /// **'Annotations\npar seance'**
  String get annotationsPerSession;

  /// No description provided for @closedSessions.
  ///
  /// In fr, this message translates to:
  /// **'Seances\ncloturees'**
  String get closedSessions;

  /// No description provided for @activityLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau d\'activite'**
  String get activityLevel;

  /// No description provided for @expert.
  ///
  /// In fr, this message translates to:
  /// **'Expert'**
  String get expert;

  /// No description provided for @toNextLevel.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% vers le niveau suivant'**
  String toNextLevel(int percent);

  /// No description provided for @smsAndNotifications.
  ///
  /// In fr, this message translates to:
  /// **'SMS et notifications'**
  String get smsAndNotifications;

  /// No description provided for @sent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyes'**
  String get sent;

  /// No description provided for @thisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get thisMonth;

  /// No description provided for @failed.
  ///
  /// In fr, this message translates to:
  /// **'En echec'**
  String get failed;

  /// No description provided for @newMessage.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau message'**
  String get newMessage;

  /// No description provided for @writeAndSendSms.
  ///
  /// In fr, this message translates to:
  /// **'Rediger et envoyer un SMS'**
  String get writeAndSendSms;

  /// No description provided for @groupMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message groupe'**
  String get groupMessage;

  /// No description provided for @sendToFilteredGroup.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer a un groupe filtre'**
  String get sendToFilteredGroup;

  /// No description provided for @smsHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique SMS'**
  String get smsHistory;

  /// No description provided for @viewSentMessages.
  ///
  /// In fr, this message translates to:
  /// **'Consulter les messages envoyes'**
  String get viewSentMessages;

  /// No description provided for @lastMessages.
  ///
  /// In fr, this message translates to:
  /// **'Derniers messages'**
  String get lastMessages;

  /// No description provided for @noMessageSentYet.
  ///
  /// In fr, this message translates to:
  /// **'Aucun message envoye pour le moment.'**
  String get noMessageSentYet;

  /// No description provided for @destinataire.
  ///
  /// In fr, this message translates to:
  /// **'destinataire'**
  String get destinataire;

  /// No description provided for @destinataires.
  ///
  /// In fr, this message translates to:
  /// **'destinataires'**
  String get destinataires;

  /// No description provided for @newSms.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau SMS'**
  String get newSms;

  /// No description provided for @writeYourMessage.
  ///
  /// In fr, this message translates to:
  /// **'Redigez votre message'**
  String get writeYourMessage;

  /// No description provided for @smsWillBeSent.
  ///
  /// In fr, this message translates to:
  /// **'Le message sera envoye par SMS aux destinataires selectionnes.'**
  String get smsWillBeSent;

  /// No description provided for @typeMessageHere.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre message ici...'**
  String get typeMessageHere;

  /// No description provided for @characters.
  ///
  /// In fr, this message translates to:
  /// **'caractere'**
  String get characters;

  /// No description provided for @charactersPlural.
  ///
  /// In fr, this message translates to:
  /// **'caracteres'**
  String get charactersPlural;

  /// No description provided for @remaining.
  ///
  /// In fr, this message translates to:
  /// **'restants'**
  String get remaining;

  /// No description provided for @chooseRecipients.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les destinataires'**
  String get chooseRecipients;

  /// No description provided for @confirmation.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @summary.
  ///
  /// In fr, this message translates to:
  /// **'Recapitulatif'**
  String get summary;

  /// No description provided for @verifyBeforeSending.
  ///
  /// In fr, this message translates to:
  /// **'Verifiez les informations avant l\'envoi.'**
  String get verifyBeforeSending;

  /// No description provided for @smsPerPerson.
  ///
  /// In fr, this message translates to:
  /// **'SMS / personne'**
  String get smsPerPerson;

  /// No description provided for @totalSms.
  ///
  /// In fr, this message translates to:
  /// **'SMS total'**
  String get totalSms;

  /// No description provided for @message.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @confirmSending.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'envoi'**
  String get confirmSending;

  /// No description provided for @aboutToSend.
  ///
  /// In fr, this message translates to:
  /// **'Vous etes sur le point d\'envoyer ce message a {count} destinataire{plural}.\n\nCette action est irreversible.'**
  String aboutToSend(int count, String plural);

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @sendSms.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer les SMS'**
  String get sendSms;

  /// No description provided for @smsSent.
  ///
  /// In fr, this message translates to:
  /// **'SMS envoye !'**
  String get smsSent;

  /// No description provided for @messageSentSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Le message a ete envoye avec succes.'**
  String get messageSentSuccess;

  /// No description provided for @back.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get back;

  /// No description provided for @sendError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'envoi.'**
  String get sendError;

  /// No description provided for @noSmsSent.
  ///
  /// In fr, this message translates to:
  /// **'Aucun SMS envoye'**
  String get noSmsSent;

  /// No description provided for @sentMessagesWillAppear.
  ///
  /// In fr, this message translates to:
  /// **'Les messages envoyes apparaitront ici.'**
  String get sentMessagesWillAppear;

  /// No description provided for @deleteThisSms.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce SMS ?'**
  String get deleteThisSms;

  /// No description provided for @messageWillBeRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Ce message sera retire de l\'historique.'**
  String get messageWillBeRemoved;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @sessionsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} seance(s) - Historique et suivi'**
  String sessionsCount(int count);

  /// No description provided for @all.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get all;

  /// No description provided for @completed.
  ///
  /// In fr, this message translates to:
  /// **'Terminees'**
  String get completed;

  /// No description provided for @upcoming.
  ///
  /// In fr, this message translates to:
  /// **'A venir'**
  String get upcoming;

  /// No description provided for @tapToViewDetails.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour consulter le detail'**
  String get tapToViewDetails;

  /// No description provided for @noSession.
  ///
  /// In fr, this message translates to:
  /// **'Aucune seance'**
  String get noSession;

  /// No description provided for @sessionsFromCoaches.
  ///
  /// In fr, this message translates to:
  /// **'Les seances creees par les encadreurs\napparaitront ici.'**
  String get sessionsFromCoaches;

  /// No description provided for @noPositionAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun poste disponible'**
  String get noPositionAvailable;

  /// No description provided for @search.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher'**
  String get search;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get add;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @next.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In fr, this message translates to:
  /// **'Precedent'**
  String get previous;

  /// No description provided for @loading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In fr, this message translates to:
  /// **'Erreur'**
  String get error;

  /// No description provided for @success.
  ///
  /// In fr, this message translates to:
  /// **'Succes'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In fr, this message translates to:
  /// **'Attention'**
  String get warning;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
