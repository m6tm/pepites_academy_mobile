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

  /// No description provided for @registerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Rejoignez l\'elite de la formation sportive'**
  String get registerSubtitle;

  /// No description provided for @lastName.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get lastName;

  /// No description provided for @lastNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre nom'**
  String get lastNameHint;

  /// No description provided for @lastNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre nom'**
  String get lastNameRequired;

  /// No description provided for @firstName.
  ///
  /// In fr, this message translates to:
  /// **'Prenom'**
  String get firstName;

  /// No description provided for @firstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre prenom'**
  String get firstNameHint;

  /// No description provided for @firstNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre prenom'**
  String get firstNameRequired;

  /// No description provided for @createMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Creer mon compte'**
  String get createMyAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Deja un compte ?'**
  String get alreadyHaveAccount;

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get passwordStrengthMedium;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In fr, this message translates to:
  /// **'Fort'**
  String get passwordStrengthStrong;

  /// No description provided for @passwordStrengthExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get passwordStrengthExcellent;

  /// No description provided for @passwordMinChars.
  ///
  /// In fr, this message translates to:
  /// **'Au moins 8 caracteres'**
  String get passwordMinChars;

  /// No description provided for @passwordUppercase.
  ///
  /// In fr, this message translates to:
  /// **'Une majuscule'**
  String get passwordUppercase;

  /// No description provided for @passwordDigit.
  ///
  /// In fr, this message translates to:
  /// **'Un chiffre'**
  String get passwordDigit;

  /// No description provided for @passwordSpecialChar.
  ///
  /// In fr, this message translates to:
  /// **'Un caractere special'**
  String get passwordSpecialChar;

  /// No description provided for @confirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetPassword.
  ///
  /// In fr, this message translates to:
  /// **'Reinitialiser le mot de passe'**
  String get resetPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublie'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre email pour recevoir un code de verification a 6 chiffres.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendCode.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le code'**
  String get sendCode;

  /// No description provided for @backToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour a la connexion'**
  String get backToLogin;

  /// No description provided for @otpVerification.
  ///
  /// In fr, this message translates to:
  /// **'Verification OTP'**
  String get otpVerification;

  /// No description provided for @otpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Verification'**
  String get otpTitle;

  /// No description provided for @otpDescription.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez le code a 6 chiffres envoye a\n{email}'**
  String otpDescription(String email);

  /// No description provided for @verifyCode.
  ///
  /// In fr, this message translates to:
  /// **'Verifier le code'**
  String get verifyCode;

  /// No description provided for @noCodeReceived.
  ///
  /// In fr, this message translates to:
  /// **'Vous n\'avez pas recu de code ? '**
  String get noCodeReceived;

  /// No description provided for @resend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer'**
  String get resend;

  /// No description provided for @newPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Creez un nouveau mot de passe securise pour votre compte.'**
  String get newPasswordSubtitle;

  /// No description provided for @newPasswordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un mot de passe'**
  String get newPasswordRequired;

  /// No description provided for @passwordMustBeStronger.
  ///
  /// In fr, this message translates to:
  /// **'Le mot de passe doit etre plus fort'**
  String get passwordMustBeStronger;

  /// No description provided for @resetPasswordButton.
  ///
  /// In fr, this message translates to:
  /// **'Reinitialiser'**
  String get resetPasswordButton;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe reinitialise avec succes'**
  String get passwordResetSuccess;

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

  /// No description provided for @systemMode.
  ///
  /// In fr, this message translates to:
  /// **'Systeme'**
  String get systemMode;

  /// No description provided for @lightModeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Apparence claire en permanence'**
  String get lightModeDesc;

  /// No description provided for @darkModeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Apparence sombre en permanence'**
  String get darkModeDesc;

  /// No description provided for @systemModeDesc.
  ///
  /// In fr, this message translates to:
  /// **'Suit le reglage de l\'appareil'**
  String get systemModeDesc;

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

  /// No description provided for @footballPositionsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Gerez les postes attribues aux academiciens'**
  String get footballPositionsDesc;

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

  /// No description provided for @schoolLevelsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Gerez les niveaux scolaires des academiciens'**
  String get schoolLevelsDesc;

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

  /// No description provided for @splashTagline.
  ///
  /// In fr, this message translates to:
  /// **'L\'excellence du football'**
  String get splashTagline;

  /// No description provided for @defaultUser.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur'**
  String get defaultUser;

  /// No description provided for @onboardingSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In fr, this message translates to:
  /// **'Suivant'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get onboardingStart;

  /// No description provided for @onboardingTitle1.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue dans l\'Excellence'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In fr, this message translates to:
  /// **'Gerez votre academie de football avec des outils modernes, precis et concus pour la performance de haut niveau.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In fr, this message translates to:
  /// **'Presence par QR Code'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In fr, this message translates to:
  /// **'Scannez, validez et enregistrez les acces en quelques secondes grace a un systeme rapide et securise.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In fr, this message translates to:
  /// **'Maitrisez Chaque Seance'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez, configurez et cloturez vos entrainements tout en gardant un controle total sur chaque activite.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In fr, this message translates to:
  /// **'Suivi des Performances'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez des annotations structurees et suivez la progression de chaque academicien avec precision.'**
  String get onboardingDesc4;

  /// No description provided for @onboardingTitle5.
  ///
  /// In fr, this message translates to:
  /// **'Des Donnees au Service du Talent'**
  String get onboardingTitle5;

  /// No description provided for @onboardingDesc5.
  ///
  /// In fr, this message translates to:
  /// **'Generez des bulletins professionnels, visualisez l\'evolution et optimisez le developpement de vos joueurs.'**
  String get onboardingDesc5;

  /// No description provided for @greetingMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Bon apres-midi'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir'**
  String get greetingEvening;

  /// No description provided for @logoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Deconnexion'**
  String get logoutTitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Etes-vous sur de vouloir vous deconnecter ?'**
  String get logoutConfirmation;

  /// No description provided for @logoutButton.
  ///
  /// In fr, this message translates to:
  /// **'Deconnecter'**
  String get logoutButton;

  /// No description provided for @scanLabel.
  ///
  /// In fr, this message translates to:
  /// **'SCAN'**
  String get scanLabel;

  /// No description provided for @badgeNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau'**
  String get badgeNew;

  /// No description provided for @badgeGo.
  ///
  /// In fr, this message translates to:
  /// **'Go'**
  String get badgeGo;

  /// No description provided for @activitySessionOpened.
  ///
  /// In fr, this message translates to:
  /// **'Seance ouverte'**
  String get activitySessionOpened;

  /// No description provided for @activitySessionClosed.
  ///
  /// In fr, this message translates to:
  /// **'Seance cloturee'**
  String get activitySessionClosed;

  /// No description provided for @activitySessionClosedDesc.
  ///
  /// In fr, this message translates to:
  /// **'{title} - {count} presents'**
  String activitySessionClosedDesc(String title, int count);

  /// No description provided for @activitySessionScheduled.
  ///
  /// In fr, this message translates to:
  /// **'Seance programmee'**
  String get activitySessionScheduled;

  /// No description provided for @activityNewAcademician.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel academicien'**
  String get activityNewAcademician;

  /// No description provided for @activityAcademicianRegistered.
  ///
  /// In fr, this message translates to:
  /// **'{name} inscrit avec succes'**
  String activityAcademicianRegistered(String name);

  /// No description provided for @activityAcademicianRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Academicien supprime'**
  String get activityAcademicianRemoved;

  /// No description provided for @activityAcademicianRemovedDesc.
  ///
  /// In fr, this message translates to:
  /// **'{name} supprime du systeme'**
  String activityAcademicianRemovedDesc(String name);

  /// No description provided for @activityNewCoach.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel encadreur'**
  String get activityNewCoach;

  /// No description provided for @activityAttendanceRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Presence enregistree'**
  String get activityAttendanceRecorded;

  /// No description provided for @activityAttendanceDesc.
  ///
  /// In fr, this message translates to:
  /// **'{type} : {name}'**
  String activityAttendanceDesc(String type, String name);

  /// No description provided for @activitySmsSent.
  ///
  /// In fr, this message translates to:
  /// **'SMS envoye'**
  String get activitySmsSent;

  /// No description provided for @activitySmsSentDesc.
  ///
  /// In fr, this message translates to:
  /// **'{count} destinataires - {preview}'**
  String activitySmsSentDesc(int count, String preview);

  /// No description provided for @activitySmsFailed.
  ///
  /// In fr, this message translates to:
  /// **'SMS en echec'**
  String get activitySmsFailed;

  /// No description provided for @activitySmsFailedDesc.
  ///
  /// In fr, this message translates to:
  /// **'Echec de l\'envoi du message'**
  String get activitySmsFailedDesc;

  /// No description provided for @activityReportGenerated.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin genere'**
  String get activityReportGenerated;

  /// No description provided for @activityReferentialUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Referentiel mis a jour'**
  String get activityReferentialUpdated;

  /// No description provided for @activityNewPosition.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau poste : {name}'**
  String activityNewPosition(String name);

  /// No description provided for @activityPositionModified.
  ///
  /// In fr, this message translates to:
  /// **'Poste modifie : {name}'**
  String activityPositionModified(String name);

  /// No description provided for @activityPositionRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Poste supprime : {name}'**
  String activityPositionRemoved(String name);

  /// No description provided for @activityNewLevel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau niveau : {name}'**
  String activityNewLevel(String name);

  /// No description provided for @activityLevelModified.
  ///
  /// In fr, this message translates to:
  /// **'Niveau modifie : {name}'**
  String activityLevelModified(String name);

  /// No description provided for @activityLevelRemoved.
  ///
  /// In fr, this message translates to:
  /// **'Niveau supprime : {name}'**
  String activityLevelRemoved(String name);

  /// No description provided for @profileAcademician.
  ///
  /// In fr, this message translates to:
  /// **'Academicien'**
  String get profileAcademician;

  /// No description provided for @profileCoach.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur'**
  String get profileCoach;

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

  /// No description provided for @academicianRegistrationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription Académicien'**
  String get academicianRegistrationTitle;

  /// No description provided for @academicianPhotoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photo de l\'académicien'**
  String get academicianPhotoLabel;

  /// No description provided for @optionalLabel.
  ///
  /// In fr, this message translates to:
  /// **'(Optionnel)'**
  String get optionalLabel;

  /// No description provided for @identityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Identité'**
  String get identityLabel;

  /// No description provided for @academicianPersonalDetails.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles de l\'académicien'**
  String get academicianPersonalDetails;

  /// No description provided for @requiredFields.
  ///
  /// In fr, this message translates to:
  /// **'Champs requis'**
  String get requiredFields;

  /// No description provided for @requiredField.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get requiredField;

  /// No description provided for @requiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get requiredLabel;

  /// No description provided for @registrationSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Inscription réussie !'**
  String get registrationSuccessTitle;

  /// No description provided for @academicianQrBadgeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Le badge QR unique de l\'académicien a été généré avec succès. Vous pouvez le partager ou le télécharger.'**
  String get academicianQrBadgeSubtitle;

  /// No description provided for @selectPosteAndPiedError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un poste et un pied fort'**
  String get selectPosteAndPiedError;

  /// No description provided for @selectSchoolLevelError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un niveau scolaire'**
  String get selectSchoolLevelError;

  /// No description provided for @galleryOpenError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir la galerie'**
  String get galleryOpenError;

  /// No description provided for @academicianSaveError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'enregistrer l\'académicien : {error}'**
  String academicianSaveError(String error);

  /// No description provided for @enterLastName.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le nom'**
  String get enterLastName;

  /// No description provided for @enterFirstName.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le prénom'**
  String get enterFirstName;

  /// No description provided for @birthDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de naissance'**
  String get birthDateLabel;

  /// No description provided for @birthDateFormat.
  ///
  /// In fr, this message translates to:
  /// **'JJ/MM/AAAA'**
  String get birthDateFormat;

  /// No description provided for @parentPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone Parent'**
  String get parentPhoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In fr, this message translates to:
  /// **'+221 -- --- -- --'**
  String get phoneHint;

  /// No description provided for @footballLabel.
  ///
  /// In fr, this message translates to:
  /// **'Football'**
  String get footballLabel;

  /// No description provided for @sportsProfileSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil sportif sur le terrain'**
  String get sportsProfileSubtitle;

  /// No description provided for @preferredPositionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poste de prédilection'**
  String get preferredPositionLabel;

  /// No description provided for @strongFootLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pied fort'**
  String get strongFootLabel;

  /// No description provided for @rightFooted.
  ///
  /// In fr, this message translates to:
  /// **'Droitier'**
  String get rightFooted;

  /// No description provided for @leftFooted.
  ///
  /// In fr, this message translates to:
  /// **'Gaucher'**
  String get leftFooted;

  /// No description provided for @ambidextrous.
  ///
  /// In fr, this message translates to:
  /// **'Ambidextre'**
  String get ambidextrous;

  /// No description provided for @schoolingLabel.
  ///
  /// In fr, this message translates to:
  /// **'Scolarité'**
  String get schoolingLabel;

  /// No description provided for @currentAcademicLevelSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Niveau académique actuel'**
  String get currentAcademicLevelSubtitle;

  /// No description provided for @continue_label.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continue_label;

  /// No description provided for @confirm_label.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm_label;

  /// No description provided for @previousLabel.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get previousLabel;

  /// No description provided for @notSpecified.
  ///
  /// In fr, this message translates to:
  /// **'Non spécifié'**
  String get notSpecified;

  /// No description provided for @notProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get notProvided;

  /// No description provided for @academicianBadgeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Badge Académicien'**
  String get academicianBadgeTitle;

  /// No description provided for @recapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif'**
  String get recapTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get fullNameLabel;

  /// No description provided for @roleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Rôle'**
  String get roleLabel;

  /// No description provided for @posteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poste'**
  String get posteLabel;

  /// No description provided for @registrationDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'inscription'**
  String get registrationDateLabel;

  /// No description provided for @academicianBadgeType.
  ///
  /// In fr, this message translates to:
  /// **'ACADEMICIEN'**
  String get academicianBadgeType;

  /// No description provided for @coachBadgeType.
  ///
  /// In fr, this message translates to:
  /// **'ENCADREUR'**
  String get coachBadgeType;

  /// No description provided for @newCoachRegistrationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel Encadreur'**
  String get newCoachRegistrationTitle;

  /// No description provided for @coachPersonalDetails.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles de l\'encadreur'**
  String get coachPersonalDetails;

  /// No description provided for @enterCoachLastNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le nom de famille'**
  String get enterCoachLastNameHint;

  /// No description provided for @enterCoachFirstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le prénom'**
  String get enterCoachFirstNameHint;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de téléphone'**
  String get phoneNumberLabel;

  /// No description provided for @phoneRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone est requis'**
  String get phoneRequired;

  /// No description provided for @specialtyLabel.
  ///
  /// In fr, this message translates to:
  /// **'Spécialité'**
  String get specialtyLabel;

  /// No description provided for @sportExpertiseSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Domaine d\'expertise sportive'**
  String get sportExpertiseSubtitle;

  /// No description provided for @coachSpecialtyInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez la spécialité principale de l\'encadreur. Cela déterminera les types d\'ateliers qu\'il pourra diriger.'**
  String get coachSpecialtyInstructions;

  /// No description provided for @coachRegisteredSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur enregistré !'**
  String get coachRegisteredSuccess;

  /// No description provided for @specialtyRequiredError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner une spécialité'**
  String get specialtyRequiredError;

  /// No description provided for @coachSaveError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer l\'encadreur : {error}'**
  String coachSaveError(String error);

  /// No description provided for @qrBadgeGeneratedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Le badge QR a été généré avec succès.'**
  String get qrBadgeGeneratedSuccess;

  /// No description provided for @shareLabel.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get shareLabel;

  /// No description provided for @finishLabel.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get finishLabel;

  /// No description provided for @specialityTechnique.
  ///
  /// In fr, this message translates to:
  /// **'Technique'**
  String get specialityTechnique;

  /// No description provided for @specialityTechniqueDesc.
  ///
  /// In fr, this message translates to:
  /// **'Dribbles, passes, tirs'**
  String get specialityTechniqueDesc;

  /// No description provided for @specialityPhysique.
  ///
  /// In fr, this message translates to:
  /// **'Physique'**
  String get specialityPhysique;

  /// No description provided for @specialityPhysiqueDesc.
  ///
  /// In fr, this message translates to:
  /// **'Endurance, vitesse, force'**
  String get specialityPhysiqueDesc;

  /// No description provided for @specialityTactique.
  ///
  /// In fr, this message translates to:
  /// **'Tactique'**
  String get specialityTactique;

  /// No description provided for @specialityTactiqueDesc.
  ///
  /// In fr, this message translates to:
  /// **'Placement, stratégie, jeu'**
  String get specialityTactiqueDesc;

  /// No description provided for @specialityGardien.
  ///
  /// In fr, this message translates to:
  /// **'Gardien'**
  String get specialityGardien;

  /// No description provided for @specialityGardienDesc.
  ///
  /// In fr, this message translates to:
  /// **'Arrêts, relances, placement'**
  String get specialityGardienDesc;

  /// No description provided for @specialityFormationJeunes.
  ///
  /// In fr, this message translates to:
  /// **'Formation jeunes'**
  String get specialityFormationJeunes;

  /// No description provided for @specialityFormationJeunesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Pédagogie, initiation'**
  String get specialityFormationJeunesDesc;

  /// No description provided for @specialityPreparationMentale.
  ///
  /// In fr, this message translates to:
  /// **'Préparation mentale'**
  String get specialityPreparationMentale;

  /// No description provided for @specialityPreparationMentaleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Concentration, motivation'**
  String get specialityPreparationMentaleDesc;

  /// No description provided for @notificationsDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Desactivees'**
  String get notificationsDisabled;

  /// No description provided for @notifSeancesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Ouverture et fermeture de seances'**
  String get notifSeancesDesc;

  /// No description provided for @notifPresencesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Scans et pointages des academiciens'**
  String get notifPresencesDesc;

  /// No description provided for @notifAnnotationsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelles evaluations et observations'**
  String get notifAnnotationsDesc;

  /// No description provided for @notifMessagesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Communications et annonces'**
  String get notifMessagesDesc;

  /// No description provided for @notifRappels.
  ///
  /// In fr, this message translates to:
  /// **'Rappels'**
  String get notifRappels;

  /// No description provided for @notifRappelsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rappels de seances et echeances'**
  String get notifRappelsDesc;

  /// No description provided for @notifStorageInfo.
  ///
  /// In fr, this message translates to:
  /// **'Les preferences de notifications sont enregistrees localement sur cet appareil.'**
  String get notifStorageInfo;

  /// No description provided for @appPlatformDesc.
  ///
  /// In fr, this message translates to:
  /// **'Plateforme de gestion et de suivi\ndes academiciens de football'**
  String get appPlatformDesc;

  /// No description provided for @lastUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Derniere mise a jour'**
  String get lastUpdate;

  /// No description provided for @lastUpdateValue.
  ///
  /// In fr, this message translates to:
  /// **'Fevrier 2026'**
  String get lastUpdateValue;

  /// No description provided for @storage.
  ///
  /// In fr, this message translates to:
  /// **'Stockage'**
  String get storage;

  /// No description provided for @localStorage.
  ///
  /// In fr, this message translates to:
  /// **'Local (hors-ligne)'**
  String get localStorage;

  /// No description provided for @team.
  ///
  /// In fr, this message translates to:
  /// **'EQUIPE'**
  String get team;

  /// No description provided for @developedBy.
  ///
  /// In fr, this message translates to:
  /// **'Developpe par'**
  String get developedBy;

  /// No description provided for @designedFor.
  ///
  /// In fr, this message translates to:
  /// **'Concu pour'**
  String get designedFor;

  /// No description provided for @legalInformation.
  ///
  /// In fr, this message translates to:
  /// **'INFORMATIONS LEGALES'**
  String get legalInformation;

  /// No description provided for @copyright.
  ///
  /// In fr, this message translates to:
  /// **'{app} - Tous droits reserves.'**
  String copyright(String app);

  /// No description provided for @legalUsageDesc.
  ///
  /// In fr, this message translates to:
  /// **'Cette application est destinee a un usage interne pour la gestion des academiciens, des seances d\'entrainement, des ateliers et du suivi de performance au sein de l\'academie de football {app}.'**
  String legalUsageDesc(String app);

  /// No description provided for @legalDataDesc.
  ///
  /// In fr, this message translates to:
  /// **'Les donnees sont stockees localement sur l\'appareil. Aucune information personnelle n\'est transmise a des tiers.'**
  String get legalDataDesc;

  /// No description provided for @madeWithPassion.
  ///
  /// In fr, this message translates to:
  /// **'Fait avec passion pour le football'**
  String get madeWithPassion;

  /// No description provided for @referentialsDataDesc.
  ///
  /// In fr, this message translates to:
  /// **'Donnees de base de l\'application'**
  String get referentialsDataDesc;

  /// No description provided for @referentialsUsageInfo.
  ///
  /// In fr, this message translates to:
  /// **'Les referentiels alimentent les formulaires d\'inscription et les filtres de l\'application.'**
  String get referentialsUsageInfo;

  /// No description provided for @roleWithSpeciality.
  ///
  /// In fr, this message translates to:
  /// **'{role} - {speciality}'**
  String roleWithSpeciality(String role, String speciality);

  /// No description provided for @academiciansStat.
  ///
  /// In fr, this message translates to:
  /// **'Academiciens'**
  String get academiciansStat;

  /// No description provided for @annotationsStat.
  ///
  /// In fr, this message translates to:
  /// **'Annotations'**
  String get annotationsStat;

  /// No description provided for @workshopsStat.
  ///
  /// In fr, this message translates to:
  /// **'Ateliers'**
  String get workshopsStat;
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
