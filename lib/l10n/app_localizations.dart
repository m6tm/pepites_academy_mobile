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
  /// **'Accedez a votre espace'**
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

  /// No description provided for @invalidOtpError.
  ///
  /// In fr, this message translates to:
  /// **'Code de verification invalide'**
  String get invalidOtpError;

  /// No description provided for @otpExpiredError.
  ///
  /// In fr, this message translates to:
  /// **'Code de verification expire'**
  String get otpExpiredError;

  /// No description provided for @userNotFoundError.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateur non trouve'**
  String get userNotFoundError;

  /// No description provided for @passwordResetError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de reinitialiser le mot de passe'**
  String get passwordResetError;

  /// No description provided for @unexpectedError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue est survenue'**
  String get unexpectedError;

  /// No description provided for @noInternetConnection.
  ///
  /// In fr, this message translates to:
  /// **'Aucune connexion internet'**
  String get noInternetConnection;

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

  /// No description provided for @serviceAtelierOnlyInOpenSeance.
  ///
  /// In fr, this message translates to:
  /// **'L\'application d\'un atelier ne peut se faire que sur une séance ouverte.'**
  String get serviceAtelierOnlyInOpenSeance;

  /// No description provided for @serviceExerciceOnlyInOpenSeance.
  ///
  /// In fr, this message translates to:
  /// **'L\'application d\'un exercice ne peut se faire que sur une séance ouverte.'**
  String get serviceExerciceOnlyInOpenSeance;

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

  /// No description provided for @parentPhotoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photo du parent/tuteur'**
  String get parentPhotoLabel;

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
  /// **'Obligatoire'**
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
  /// **'Veuillez sélectionner un poste'**
  String get selectPosteAndPiedError;

  /// No description provided for @selectSchoolLevelError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner un niveau scolaire'**
  String get selectSchoolLevelError;

  /// No description provided for @genderRequiredError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez sélectionner le genre'**
  String get genderRequiredError;

  /// No description provided for @photoRequiredError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez ajouter une photo de profil de l\'académicien'**
  String get photoRequiredError;

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

  /// No description provided for @coachPhotoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photo de l\'encadreur'**
  String get coachPhotoLabel;

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

  /// No description provided for @all_masculine.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get all_masculine;

  /// No description provided for @yearsOld.
  ///
  /// In fr, this message translates to:
  /// **'{age} ans'**
  String yearsOld(int age);

  /// No description provided for @deletePlayer.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le joueur'**
  String get deletePlayer;

  /// No description provided for @deletePlayerConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir supprimer {name} ? Cette action est irréversible.'**
  String deletePlayerConfirmation(String name);

  /// No description provided for @editProfile.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get editProfile;

  /// No description provided for @saveModifications.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer les modifications'**
  String get saveModifications;

  /// No description provided for @modificationsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Modifications enregistrées'**
  String get modificationsSaved;

  /// No description provided for @playerUpdatedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'{name} a été mis à jour avec succès.'**
  String playerUpdatedSuccess(String name);

  /// No description provided for @academiciansRegisteredSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Académiciens inscrits à l\'académie'**
  String get academiciansRegisteredSubtitle;

  /// No description provided for @searchPlayerHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un joueur...'**
  String get searchPlayerHint;

  /// No description provided for @totalLabel.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get totalLabel;

  /// No description provided for @gardiensLabel.
  ///
  /// In fr, this message translates to:
  /// **'Gardiens'**
  String get gardiensLabel;

  /// No description provided for @defLabel.
  ///
  /// In fr, this message translates to:
  /// **'Déf.'**
  String get defLabel;

  /// No description provided for @milLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mil.'**
  String get milLabel;

  /// No description provided for @attLabel.
  ///
  /// In fr, this message translates to:
  /// **'Att.'**
  String get attLabel;

  /// No description provided for @noPlayerFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun joueur'**
  String get noPlayerFound;

  /// No description provided for @noSearchResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour cette recherche.\nEssayez avec d\'autres critères.'**
  String get noSearchResult;

  /// No description provided for @startByRegistering.
  ///
  /// In fr, this message translates to:
  /// **'Commencez par inscrire votre\npremier académicien pour démarrer.'**
  String get startByRegistering;

  /// No description provided for @registerPlayerAction.
  ///
  /// In fr, this message translates to:
  /// **'Inscrire un joueur'**
  String get registerPlayerAction;

  /// No description provided for @personalInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInformation;

  /// No description provided for @evaluations.
  ///
  /// In fr, this message translates to:
  /// **'Évaluations'**
  String get evaluations;

  /// No description provided for @sportProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil sportif'**
  String get sportProfile;

  /// No description provided for @trainingReport.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin de formation'**
  String get trainingReport;

  /// No description provided for @trainingReportDesc.
  ///
  /// In fr, this message translates to:
  /// **'Consulter et générer le bulletin de formation périodique.'**
  String get trainingReportDesc;

  /// No description provided for @accessReport.
  ///
  /// In fr, this message translates to:
  /// **'Accéder au bulletin'**
  String get accessReport;

  /// No description provided for @tapToEnlargeBadge.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez sur le badge pour l\'agrandir'**
  String get tapToEnlargeBadge;

  /// No description provided for @downloadLabel.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get downloadLabel;

  /// No description provided for @downloadSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement réussi'**
  String get downloadSuccess;

  /// No description provided for @downloadSuccessDesc.
  ///
  /// In fr, this message translates to:
  /// **'Le badge a été enregistré dans vos documents.'**
  String get downloadSuccessDesc;

  /// No description provided for @badgeShareSubject.
  ///
  /// In fr, this message translates to:
  /// **'Badge QR - {name}'**
  String badgeShareSubject(String name);

  /// No description provided for @badgeShareText.
  ///
  /// In fr, this message translates to:
  /// **'Voici le badge QR de {name} de Pepites Academy.'**
  String badgeShareText(String name);

  /// No description provided for @updateError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de mettre à jour : {error}'**
  String updateError(String error);

  /// No description provided for @academicianBadgeReady.
  ///
  /// In fr, this message translates to:
  /// **'Le badge de {name} est prêt.'**
  String academicianBadgeReady(String name);

  /// No description provided for @officialBadge.
  ///
  /// In fr, this message translates to:
  /// **'BADGE OFFICIEL'**
  String get officialBadge;

  /// No description provided for @shareBadgeAction.
  ///
  /// In fr, this message translates to:
  /// **'PARTAGER LE BADGE'**
  String get shareBadgeAction;

  /// No description provided for @backToDashboard.
  ///
  /// In fr, this message translates to:
  /// **'RETOUR AU DASHBOARD'**
  String get backToDashboard;

  /// No description provided for @sharingInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Partage en cours...'**
  String get sharingInProgress;

  /// No description provided for @featureComingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Fonctionnalité bientôt disponible.'**
  String get featureComingSoon;

  /// No description provided for @sportProfileDesc.
  ///
  /// In fr, this message translates to:
  /// **'Définissez le rôle de l\'élève sur le terrain.'**
  String get sportProfileDesc;

  /// No description provided for @selectPositionHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un poste'**
  String get selectPositionHint;

  /// No description provided for @selectFootHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez le pied'**
  String get selectFootHint;

  /// No description provided for @confirmRegistration.
  ///
  /// In fr, this message translates to:
  /// **'CONFIRMER L\'INSCRIPTION'**
  String get confirmRegistration;

  /// No description provided for @selectDate.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner une date'**
  String get selectDate;

  /// No description provided for @recapSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez les informations avant la validation finale.'**
  String get recapSubtitle;

  /// No description provided for @futureAcademician.
  ///
  /// In fr, this message translates to:
  /// **'Futur Académicien'**
  String get futureAcademician;

  /// No description provided for @qrBadgeValidationWarning.
  ///
  /// In fr, this message translates to:
  /// **'La validation générera automatiquement un Badge QR unique pour cet élève.'**
  String get qrBadgeValidationWarning;

  /// No description provided for @academicLevelTitle.
  ///
  /// In fr, this message translates to:
  /// **'Niveau Académique'**
  String get academicLevelTitle;

  /// No description provided for @academicStepDesc.
  ///
  /// In fr, this message translates to:
  /// **'Suivi de la scolarité de l\'académicien.'**
  String get academicStepDesc;

  /// No description provided for @selectSchoolLevelHint.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez le niveau'**
  String get selectSchoolLevelHint;

  /// No description provided for @academicStepInfo.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations permettent de filtrer les communications SMS et d\'adapter les rapports.'**
  String get academicStepInfo;

  /// No description provided for @bulletinTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin de formation'**
  String get bulletinTitle;

  /// No description provided for @bulletinSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin de Formation Périodique'**
  String get bulletinSubtitle;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des bulletins'**
  String get historyTitle;

  /// No description provided for @observationsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Observations générales'**
  String get observationsLabel;

  /// No description provided for @observationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Rédigez vos observations pour cette période...'**
  String get observationsHint;

  /// No description provided for @encadreurLabel.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur'**
  String get encadreurLabel;

  /// No description provided for @sessionsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Séances'**
  String get sessionsLabel;

  /// No description provided for @presenceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Présence'**
  String get presenceLabel;

  /// No description provided for @annotationsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Annotations'**
  String get annotationsLabel;

  /// No description provided for @bornOn.
  ///
  /// In fr, this message translates to:
  /// **'Né(e) le {date}'**
  String bornOn(String date);

  /// No description provided for @generatedOn.
  ///
  /// In fr, this message translates to:
  /// **'Généré le {date}'**
  String generatedOn(String date);

  /// No description provided for @generateBulletin.
  ///
  /// In fr, this message translates to:
  /// **'Générer le bulletin'**
  String get generateBulletin;

  /// No description provided for @generatingInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Génération en cours...'**
  String get generatingInProgress;

  /// No description provided for @exportImage.
  ///
  /// In fr, this message translates to:
  /// **'Exporter image'**
  String get exportImage;

  /// No description provided for @exportPdf.
  ///
  /// In fr, this message translates to:
  /// **'Exporter PDF'**
  String get exportPdf;

  /// No description provided for @bulletinCaptured.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin capturé. Fonctionnalité de partage disponible prochainement.'**
  String get bulletinCaptured;

  /// No description provided for @bulletinExported.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin exporté en PDF'**
  String get bulletinExported;

  /// No description provided for @bulletinShareSubject.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin de {nom} {prenom}'**
  String bulletinShareSubject(String nom, String prenom);

  /// No description provided for @noAppreciation.
  ///
  /// In fr, this message translates to:
  /// **'Aucune appréciation disponible'**
  String get noAppreciation;

  /// No description provided for @appreciationGenerationNote.
  ///
  /// In fr, this message translates to:
  /// **'Les appréciations seront générées à partir des annotations.'**
  String get appreciationGenerationNote;

  /// No description provided for @noObservation.
  ///
  /// In fr, this message translates to:
  /// **'Aucune observation rédigée.'**
  String get noObservation;

  /// No description provided for @bulletinsGeneratedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun bulletin généré} =1{1 bulletin généré} other{{count} bulletins générés}}'**
  String bulletinsGeneratedCount(int count);

  /// No description provided for @notEnoughDataEvolution.
  ///
  /// In fr, this message translates to:
  /// **'Pas assez de données pour afficher l\'évolution.\nGénérez plusieurs bulletins pour voir les courbes.'**
  String get notEnoughDataEvolution;

  /// No description provided for @radarChartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Radar des compétences'**
  String get radarChartTitle;

  /// No description provided for @evolutionChartTitle.
  ///
  /// In fr, this message translates to:
  /// **'Évolution des compétences'**
  String get evolutionChartTitle;

  /// No description provided for @actualLabel.
  ///
  /// In fr, this message translates to:
  /// **'Actuel'**
  String get actualLabel;

  /// No description provided for @competenceTechnique.
  ///
  /// In fr, this message translates to:
  /// **'Technique'**
  String get competenceTechnique;

  /// No description provided for @competencePhysique.
  ///
  /// In fr, this message translates to:
  /// **'Physique'**
  String get competencePhysique;

  /// No description provided for @competenceTactique.
  ///
  /// In fr, this message translates to:
  /// **'Tactique'**
  String get competenceTactique;

  /// No description provided for @competenceMental.
  ///
  /// In fr, this message translates to:
  /// **'Mental'**
  String get competenceMental;

  /// No description provided for @competenceEspritEquipe.
  ///
  /// In fr, this message translates to:
  /// **'Esprit d\'équipe'**
  String get competenceEspritEquipe;

  /// No description provided for @periodTitle.
  ///
  /// In fr, this message translates to:
  /// **'Période du bulletin'**
  String get periodTitle;

  /// No description provided for @periodMonth.
  ///
  /// In fr, this message translates to:
  /// **'Mois'**
  String get periodMonth;

  /// No description provided for @periodQuarter.
  ///
  /// In fr, this message translates to:
  /// **'Trimestre'**
  String get periodQuarter;

  /// No description provided for @periodSeason.
  ///
  /// In fr, this message translates to:
  /// **'Saison'**
  String get periodSeason;

  /// No description provided for @quarterLabel.
  ///
  /// In fr, this message translates to:
  /// **'Trimestre {count} - {year}'**
  String quarterLabel(int count, int year);

  /// No description provided for @seasonLabel.
  ///
  /// In fr, this message translates to:
  /// **'Saison {start}-{end}'**
  String seasonLabel(int start, int end);

  /// No description provided for @exportError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'export : {error}'**
  String exportError(String error);

  /// No description provided for @annotationPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annotations'**
  String get annotationPageTitle;

  /// No description provided for @tapToAnnotate.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour annoter'**
  String get tapToAnnotate;

  /// No description provided for @noAcademicianPresent.
  ///
  /// In fr, this message translates to:
  /// **'Aucun academicien present'**
  String get noAcademicianPresent;

  /// No description provided for @noAcademicianPresentDesc.
  ///
  /// In fr, this message translates to:
  /// **'Les academiciens presents dans la seance\napparaitront ici pour etre annotes.'**
  String get noAcademicianPresentDesc;

  /// No description provided for @academiciansCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} academiciens'**
  String academiciansCount(int count);

  /// No description provided for @annotationsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} annotations'**
  String annotationsCount(int count);

  /// No description provided for @quickTags.
  ///
  /// In fr, this message translates to:
  /// **'Tags rapides'**
  String get quickTags;

  /// No description provided for @tagPositif.
  ///
  /// In fr, this message translates to:
  /// **'Positif'**
  String get tagPositif;

  /// No description provided for @tagExcellent.
  ///
  /// In fr, this message translates to:
  /// **'Excellent'**
  String get tagExcellent;

  /// No description provided for @tagEnProgres.
  ///
  /// In fr, this message translates to:
  /// **'En progres'**
  String get tagEnProgres;

  /// No description provided for @tagBonneAttitude.
  ///
  /// In fr, this message translates to:
  /// **'Bonne attitude'**
  String get tagBonneAttitude;

  /// No description provided for @tagCreatif.
  ///
  /// In fr, this message translates to:
  /// **'Creatif'**
  String get tagCreatif;

  /// No description provided for @tagATravailler.
  ///
  /// In fr, this message translates to:
  /// **'A travailler'**
  String get tagATravailler;

  /// No description provided for @tagInsuffisant.
  ///
  /// In fr, this message translates to:
  /// **'Insuffisant'**
  String get tagInsuffisant;

  /// No description provided for @tagManqueEffort.
  ///
  /// In fr, this message translates to:
  /// **'Manque d\'effort'**
  String get tagManqueEffort;

  /// No description provided for @tagDistrait.
  ///
  /// In fr, this message translates to:
  /// **'Distrait'**
  String get tagDistrait;

  /// No description provided for @tagTechnique.
  ///
  /// In fr, this message translates to:
  /// **'Technique'**
  String get tagTechnique;

  /// No description provided for @tagDribble.
  ///
  /// In fr, this message translates to:
  /// **'Dribble'**
  String get tagDribble;

  /// No description provided for @tagPasse.
  ///
  /// In fr, this message translates to:
  /// **'Passe'**
  String get tagPasse;

  /// No description provided for @tagTir.
  ///
  /// In fr, this message translates to:
  /// **'Tir'**
  String get tagTir;

  /// No description provided for @tagPlacement.
  ///
  /// In fr, this message translates to:
  /// **'Placement'**
  String get tagPlacement;

  /// No description provided for @tagEndurance.
  ///
  /// In fr, this message translates to:
  /// **'Endurance'**
  String get tagEndurance;

  /// No description provided for @detailedObservation.
  ///
  /// In fr, this message translates to:
  /// **'Observation detaillee'**
  String get detailedObservation;

  /// No description provided for @observationHintAnnotation.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Bonne lecture du jeu, manque d\'appui...'**
  String get observationHintAnnotation;

  /// No description provided for @noteOptional.
  ///
  /// In fr, this message translates to:
  /// **'Note (optionnel)'**
  String get noteOptional;

  /// No description provided for @noteFormat.
  ///
  /// In fr, this message translates to:
  /// **'{note}/10'**
  String noteFormat(String note);

  /// No description provided for @saving.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement...'**
  String get saving;

  /// No description provided for @saveAnnotation.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer l\'annotation'**
  String get saveAnnotation;

  /// No description provided for @historyCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Historique ({count})'**
  String historyCountLabel(int count);

  /// No description provided for @noPreviousAnnotation.
  ///
  /// In fr, this message translates to:
  /// **'Aucune annotation precedente'**
  String get noPreviousAnnotation;

  /// No description provided for @communicationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Communication'**
  String get communicationTitle;

  /// No description provided for @sentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Envoyes'**
  String get sentLabel;

  /// No description provided for @thisMonthLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois'**
  String get thisMonthLabel;

  /// No description provided for @failedLabel.
  ///
  /// In fr, this message translates to:
  /// **'En echec'**
  String get failedLabel;

  /// No description provided for @composeAndSendSms.
  ///
  /// In fr, this message translates to:
  /// **'Rediger et envoyer un SMS'**
  String get composeAndSendSms;

  /// No description provided for @historyActionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get historyActionLabel;

  /// No description provided for @recipientsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 destinataire} other{{count} destinataires}}'**
  String recipientsCount(int count);

  /// No description provided for @sessionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Seances'**
  String get sessionsTitle;

  /// No description provided for @sessionsCountSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count} seance(s) - Historique et suivi'**
  String sessionsCountSubtitle(int count);

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get filterAll;

  /// No description provided for @filterInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get filterInProgress;

  /// No description provided for @filterCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminees'**
  String get filterCompleted;

  /// No description provided for @filterUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'A venir'**
  String get filterUpcoming;

  /// No description provided for @sessionInProgressBanner.
  ///
  /// In fr, this message translates to:
  /// **'SEANCE EN COURS'**
  String get sessionInProgressBanner;

  /// No description provided for @tapToViewDetail.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour consulter le detail'**
  String get tapToViewDetail;

  /// No description provided for @sessionsCreatedByCoaches.
  ///
  /// In fr, this message translates to:
  /// **'Les seances creees par les encadreurs\napparaitront ici.'**
  String get sessionsCreatedByCoaches;

  /// No description provided for @mySessionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes seances'**
  String get mySessionsTitle;

  /// No description provided for @openSessionTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir une seance'**
  String get openSessionTooltip;

  /// No description provided for @openFirstSession.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez votre premiere seance\npour commencer l\'entrainement.'**
  String get openFirstSession;

  /// No description provided for @openSession.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir une seance'**
  String get openSession;

  /// No description provided for @closeThisSession.
  ///
  /// In fr, this message translates to:
  /// **'Fermer cette seance'**
  String get closeThisSession;

  /// No description provided for @fillInfoToStart.
  ///
  /// In fr, this message translates to:
  /// **'Remplissez les informations pour demarrer.'**
  String get fillInfoToStart;

  /// No description provided for @sessionTitleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Titre de la seance'**
  String get sessionTitleLabel;

  /// No description provided for @sessionTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Entrainement Technique'**
  String get sessionTitleHint;

  /// No description provided for @startLabel.
  ///
  /// In fr, this message translates to:
  /// **'Debut'**
  String get startLabel;

  /// No description provided for @endLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get endLabel;

  /// No description provided for @startSession.
  ///
  /// In fr, this message translates to:
  /// **'Demarrer la seance'**
  String get startSession;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un titre.'**
  String get pleaseEnterTitle;

  /// No description provided for @sessionInProgressDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Seance en cours'**
  String get sessionInProgressDialogTitle;

  /// No description provided for @understoodButton.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get understoodButton;

  /// No description provided for @closeSessionButton.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la seance'**
  String get closeSessionButton;

  /// No description provided for @closeSessionDialogTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la seance'**
  String get closeSessionDialogTitle;

  /// No description provided for @closeSessionConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous cloturer cette seance ?'**
  String get closeSessionConfirmation;

  /// No description provided for @dataFrozenNote.
  ///
  /// In fr, this message translates to:
  /// **'Les donnees seront figees et la seance passera en lecture seule.'**
  String get dataFrozenNote;

  /// No description provided for @cancelButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancelButton;

  /// No description provided for @confirmButton.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmButton;

  /// No description provided for @sessionClosed.
  ///
  /// In fr, this message translates to:
  /// **'Seance cloturee'**
  String get sessionClosed;

  /// No description provided for @presentsRecapLabel.
  ///
  /// In fr, this message translates to:
  /// **'Presents'**
  String get presentsRecapLabel;

  /// No description provided for @workshopsRecapLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ateliers'**
  String get workshopsRecapLabel;

  /// No description provided for @perfectButton.
  ///
  /// In fr, this message translates to:
  /// **'Parfait'**
  String get perfectButton;

  /// No description provided for @presentCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} present(s)'**
  String presentCount(int count);

  /// No description provided for @workshopCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} atelier(s)'**
  String workshopCount(int count);

  /// No description provided for @meLabel.
  ///
  /// In fr, this message translates to:
  /// **'Moi'**
  String get meLabel;

  /// No description provided for @annotationsScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annotations'**
  String get annotationsScreenTitle;

  /// No description provided for @myObservationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes observations et evaluations'**
  String get myObservationsSubtitle;

  /// No description provided for @positivesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Positives'**
  String get positivesLabel;

  /// No description provided for @toWorkOnLabel.
  ///
  /// In fr, this message translates to:
  /// **'A travailler'**
  String get toWorkOnLabel;

  /// No description provided for @allTagFilter.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get allTagFilter;

  /// No description provided for @inProgressTagFilter.
  ///
  /// In fr, this message translates to:
  /// **'En progres'**
  String get inProgressTagFilter;

  /// No description provided for @techniqueTagFilter.
  ///
  /// In fr, this message translates to:
  /// **'Technique'**
  String get techniqueTagFilter;

  /// No description provided for @encadreurSmsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez des SMS aux academiciens et parents'**
  String get encadreurSmsSubtitle;

  /// No description provided for @statusInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminee'**
  String get statusCompleted;

  /// No description provided for @statusUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'A venir'**
  String get statusUpcoming;

  /// No description provided for @presentsInfoLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count} presents'**
  String presentsInfoLabel(int count);

  /// No description provided for @workshopsInfoLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count} ateliers'**
  String workshopsInfoLabel(int count);

  /// No description provided for @workshopCompositionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ateliers'**
  String get workshopCompositionTitle;

  /// No description provided for @workshopProgrammed.
  ///
  /// In fr, this message translates to:
  /// **'{count} atelier{count, plural, =1{} other{s}} {count, plural, =1{programme} other{programmes}}'**
  String workshopProgrammed(int count);

  /// No description provided for @noWorkshopProgrammed.
  ///
  /// In fr, this message translates to:
  /// **'Aucun atelier programme'**
  String get noWorkshopProgrammed;

  /// No description provided for @workshopCompositionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Composez votre seance en ajoutant des ateliers.\nChaque atelier represente un bloc d\'activite.'**
  String get workshopCompositionSubtitle;

  /// No description provided for @addWorkshopTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un atelier'**
  String get addWorkshopTitle;

  /// No description provided for @editWorkshopTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'atelier'**
  String get editWorkshopTitle;

  /// No description provided for @deleteWorkshopTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'atelier ?'**
  String get deleteWorkshopTitle;

  /// No description provided for @deleteWorkshopConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'L\'atelier \"{name}\" sera definitivement supprime.'**
  String deleteWorkshopConfirmation(String name);

  /// No description provided for @selectExerciseType.
  ///
  /// In fr, this message translates to:
  /// **'Selectionnez un type d\'exercice'**
  String get selectExerciseType;

  /// No description provided for @workshopNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'atelier'**
  String get workshopNameLabel;

  /// No description provided for @workshopNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Dribble en slalom'**
  String get workshopNameHint;

  /// No description provided for @workshopNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est requis'**
  String get workshopNameRequired;

  /// No description provided for @descriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Travail des appuis et conduite de balle'**
  String get descriptionHint;

  /// No description provided for @saveWorkshop.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter cet atelier'**
  String get saveWorkshop;

  /// No description provided for @annotateAction.
  ///
  /// In fr, this message translates to:
  /// **'Annoter'**
  String get annotateAction;

  /// No description provided for @workshopTypeDribble.
  ///
  /// In fr, this message translates to:
  /// **'Dribble'**
  String get workshopTypeDribble;

  /// No description provided for @workshopTypePasses.
  ///
  /// In fr, this message translates to:
  /// **'Passes'**
  String get workshopTypePasses;

  /// No description provided for @workshopTypeFinition.
  ///
  /// In fr, this message translates to:
  /// **'Finition'**
  String get workshopTypeFinition;

  /// No description provided for @workshopTypePhysique.
  ///
  /// In fr, this message translates to:
  /// **'Condition physique'**
  String get workshopTypePhysique;

  /// No description provided for @workshopTypeJeuEnSituation.
  ///
  /// In fr, this message translates to:
  /// **'Jeu en situation'**
  String get workshopTypeJeuEnSituation;

  /// No description provided for @workshopTypeTactique.
  ///
  /// In fr, this message translates to:
  /// **'Tactique'**
  String get workshopTypeTactique;

  /// No description provided for @workshopTypeGardien.
  ///
  /// In fr, this message translates to:
  /// **'Gardien'**
  String get workshopTypeGardien;

  /// No description provided for @workshopTypeEchauffement.
  ///
  /// In fr, this message translates to:
  /// **'Echauffement'**
  String get workshopTypeEchauffement;

  /// No description provided for @workshopTypePersonnalise.
  ///
  /// In fr, this message translates to:
  /// **'Personnalise'**
  String get workshopTypePersonnalise;

  /// No description provided for @sessionAddAtLeastOneWorkshop.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez au moins un atelier pour pouvoir annoter.'**
  String get sessionAddAtLeastOneWorkshop;

  /// No description provided for @presentCoaches.
  ///
  /// In fr, this message translates to:
  /// **'Encadreurs presents'**
  String get presentCoaches;

  /// No description provided for @responsibleLabel.
  ///
  /// In fr, this message translates to:
  /// **'Responsable'**
  String get responsibleLabel;

  /// No description provided for @horaireLabel.
  ///
  /// In fr, this message translates to:
  /// **'Horaire'**
  String get horaireLabel;

  /// No description provided for @manageAction.
  ///
  /// In fr, this message translates to:
  /// **'Gerer'**
  String get manageAction;

  /// No description provided for @noCoachRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Aucun encadreur enregistre'**
  String get noCoachRegistered;

  /// No description provided for @noAcademicianRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Aucun academicien enregistre'**
  String get noAcademicianRegistered;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un academicien, encadreur, seance...'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In fr, this message translates to:
  /// **'Recherches recentes'**
  String get recentSearches;

  /// No description provided for @clearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout effacer'**
  String get clearAll;

  /// No description provided for @universalSearch.
  ///
  /// In fr, this message translates to:
  /// **'Recherche universelle'**
  String get universalSearch;

  /// No description provided for @universalSearchDesc.
  ///
  /// In fr, this message translates to:
  /// **'Trouvez rapidement un academicien, un encadreur ou une seance.'**
  String get universalSearchDesc;

  /// No description provided for @noResultsFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun resultat'**
  String get noResultsFound;

  /// No description provided for @noResultsDesc.
  ///
  /// In fr, this message translates to:
  /// **'Essayez avec d\'autres termes de recherche.'**
  String get noResultsDesc;

  /// No description provided for @playerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Joueur'**
  String get playerLabel;

  /// No description provided for @academicianFile.
  ///
  /// In fr, this message translates to:
  /// **'Fiche Academicien'**
  String get academicianFile;

  /// No description provided for @infosTab.
  ///
  /// In fr, this message translates to:
  /// **'Infos'**
  String get infosTab;

  /// No description provided for @presencesTab.
  ///
  /// In fr, this message translates to:
  /// **'Presences'**
  String get presencesTab;

  /// No description provided for @notesTab.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notesTab;

  /// No description provided for @bulletinsTab.
  ///
  /// In fr, this message translates to:
  /// **'Bulletins'**
  String get bulletinsTab;

  /// No description provided for @personalInfos.
  ///
  /// In fr, this message translates to:
  /// **'Informations personnelles'**
  String get personalInfos;

  /// No description provided for @sportInfos.
  ///
  /// In fr, this message translates to:
  /// **'Informations sportives'**
  String get sportInfos;

  /// No description provided for @ageLabel.
  ///
  /// In fr, this message translates to:
  /// **'Age'**
  String get ageLabel;

  /// No description provided for @noPresenceRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucune presence enregistree'**
  String get noPresenceRecorded;

  /// No description provided for @noAnnotationRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucune annotation enregistree'**
  String get noAnnotationRecorded;

  /// No description provided for @noBulletinGenerated.
  ///
  /// In fr, this message translates to:
  /// **'Aucun bulletin genere'**
  String get noBulletinGenerated;

  /// No description provided for @coachFile.
  ///
  /// In fr, this message translates to:
  /// **'Fiche Encadreur'**
  String get coachFile;

  /// No description provided for @statsTab.
  ///
  /// In fr, this message translates to:
  /// **'Stats'**
  String get statsTab;

  /// No description provided for @activityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Activite'**
  String get activityLabel;

  /// No description provided for @conductedSessions.
  ///
  /// In fr, this message translates to:
  /// **'Seances dirigees'**
  String get conductedSessions;

  /// No description provided for @conductedAnnotations.
  ///
  /// In fr, this message translates to:
  /// **'Annotations realisees'**
  String get conductedAnnotations;

  /// No description provided for @recordedPresences.
  ///
  /// In fr, this message translates to:
  /// **'Presences enregistrees'**
  String get recordedPresences;

  /// No description provided for @noConductedSession.
  ///
  /// In fr, this message translates to:
  /// **'Aucune seance dirigee'**
  String get noConductedSession;

  /// No description provided for @closedSessionsStat.
  ///
  /// In fr, this message translates to:
  /// **'Seances cloturees'**
  String get closedSessionsStat;

  /// No description provided for @avgPresents.
  ///
  /// In fr, this message translates to:
  /// **'Moy. presents'**
  String get avgPresents;

  /// No description provided for @totalWorkshops.
  ///
  /// In fr, this message translates to:
  /// **'Total ateliers'**
  String get totalWorkshops;

  /// No description provided for @closureRate.
  ///
  /// In fr, this message translates to:
  /// **'Taux de cloture'**
  String get closureRate;

  /// No description provided for @keyFigures.
  ///
  /// In fr, this message translates to:
  /// **'Chiffres cles'**
  String get keyFigures;

  /// No description provided for @scannedPresences.
  ///
  /// In fr, this message translates to:
  /// **'Presences scannees'**
  String get scannedPresences;

  /// No description provided for @teamTab.
  ///
  /// In fr, this message translates to:
  /// **'Equipe'**
  String get teamTab;

  /// No description provided for @recapTab.
  ///
  /// In fr, this message translates to:
  /// **'Recap'**
  String get recapTab;

  /// No description provided for @sessionDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Detail Seance'**
  String get sessionDetailTitle;

  /// No description provided for @cancelAction.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancelAction;

  /// No description provided for @deleteAction.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get deleteAction;

  /// No description provided for @saveAction.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get saveAction;

  /// No description provided for @addAction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addAction;

  /// No description provided for @editAction.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get editAction;

  /// No description provided for @sessionStatusOpen.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get sessionStatusOpen;

  /// No description provided for @sessionStatusClosed.
  ///
  /// In fr, this message translates to:
  /// **'Fermee'**
  String get sessionStatusClosed;

  /// No description provided for @sessionStatusUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'A venir'**
  String get sessionStatusUpcoming;

  /// No description provided for @lastUpdateWithDate.
  ///
  /// In fr, this message translates to:
  /// **'Mis a jour le {date}'**
  String lastUpdateWithDate(String date);

  /// No description provided for @dateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @positionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poste'**
  String get positionLabel;

  /// No description provided for @schoolLevelLabel.
  ///
  /// In fr, this message translates to:
  /// **'Niveau scolaire'**
  String get schoolLevelLabel;

  /// No description provided for @qrCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code QR'**
  String get qrCodeLabel;

  /// No description provided for @noteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Note : {note}/10'**
  String noteLabel(String note);

  /// No description provided for @phoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Telephone'**
  String get phoneLabel;

  /// No description provided for @registeredOnLabel.
  ///
  /// In fr, this message translates to:
  /// **'Inscrit le'**
  String get registeredOnLabel;

  /// No description provided for @sessionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Seance'**
  String get sessionLabel;

  /// No description provided for @coachLabel.
  ///
  /// In fr, this message translates to:
  /// **'Coach'**
  String get coachLabel;

  /// No description provided for @presentCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count} present(s)'**
  String presentCountLabel(String count);

  /// No description provided for @workshopCountLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count} atelier(s)'**
  String workshopCountLabel(String count);

  /// No description provided for @coachWithNumber.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur {number}'**
  String coachWithNumber(int number);

  /// No description provided for @academicianWithNumber.
  ///
  /// In fr, this message translates to:
  /// **'Academicien {number}'**
  String academicianWithNumber(int number);

  /// No description provided for @academicianProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche Academicien'**
  String get academicianProfileTitle;

  /// No description provided for @academicianBadgeTypeMention.
  ///
  /// In fr, this message translates to:
  /// **'ACADEMICIEN'**
  String get academicianBadgeTypeMention;

  /// No description provided for @coachProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche Encadreur'**
  String get coachProfileTitle;

  /// No description provided for @coachBadgeTypeMention.
  ///
  /// In fr, this message translates to:
  /// **'ENCADREUR'**
  String get coachBadgeTypeMention;

  /// No description provided for @recapLabel.
  ///
  /// In fr, this message translates to:
  /// **'Recapitulatif'**
  String get recapLabel;

  /// No description provided for @statsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statsLabel;

  /// No description provided for @sessionsTab.
  ///
  /// In fr, this message translates to:
  /// **'Séances'**
  String get sessionsTab;

  /// No description provided for @presentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Présent'**
  String get presentLabel;

  /// No description provided for @sessionWithIdLabel.
  ///
  /// In fr, this message translates to:
  /// **'Seance {id}...'**
  String sessionWithIdLabel(String id);

  /// No description provided for @statusLabel.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get statusLabel;

  /// No description provided for @generalInformation.
  ///
  /// In fr, this message translates to:
  /// **'Informations générales'**
  String get generalInformation;

  /// No description provided for @presentAcademicians.
  ///
  /// In fr, this message translates to:
  /// **'Académiciens présents'**
  String get presentAcademicians;

  /// No description provided for @completedWorkshops.
  ///
  /// In fr, this message translates to:
  /// **'Ateliers réalisés'**
  String get completedWorkshops;

  /// No description provided for @noCoachRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucun encadreur enregistré'**
  String get noCoachRecorded;

  /// No description provided for @noAcademicianRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucun académicien enregistré'**
  String get noAcademicianRecorded;

  /// No description provided for @noWorkshopRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Aucun atelier enregistré'**
  String get noWorkshopRecorded;

  /// No description provided for @at.
  ///
  /// In fr, this message translates to:
  /// **' à '**
  String get at;

  /// No description provided for @notesInfoLabel.
  ///
  /// In fr, this message translates to:
  /// **'{count} notes'**
  String notesInfoLabel(int count);

  /// No description provided for @smsComposeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau SMS'**
  String get smsComposeTitle;

  /// No description provided for @smsComposeHeader.
  ///
  /// In fr, this message translates to:
  /// **'Rédigez votre message'**
  String get smsComposeHeader;

  /// No description provided for @smsComposeSubHeader.
  ///
  /// In fr, this message translates to:
  /// **'Le message sera envoyé par SMS aux destinataires sélectionnés.'**
  String get smsComposeSubHeader;

  /// No description provided for @smsComposeHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre message ici...'**
  String get smsComposeHint;

  /// No description provided for @smsComposeCharCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{{count} caractère} other{{count} caractères}}'**
  String smsComposeCharCount(int count);

  /// No description provided for @smsComposeSmsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} SMS'**
  String smsComposeSmsCount(int count);

  /// No description provided for @smsComposeRemainingChars.
  ///
  /// In fr, this message translates to:
  /// **'{count} restants'**
  String smsComposeRemainingChars(int count);

  /// No description provided for @smsComposeChooseRecipients.
  ///
  /// In fr, this message translates to:
  /// **'Choisir les destinataires'**
  String get smsComposeChooseRecipients;

  /// No description provided for @smsConfirmationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation'**
  String get smsConfirmationTitle;

  /// No description provided for @smsConfirmationSummary.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif'**
  String get smsConfirmationSummary;

  /// No description provided for @smsConfirmationCheckInfo.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez les informations avant l\'envoi.'**
  String get smsConfirmationCheckInfo;

  /// No description provided for @smsConfirmationRecipient.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Destinataire} other{Destinataires}}'**
  String smsConfirmationRecipient(int count);

  /// No description provided for @smsConfirmationSmsPerPerson.
  ///
  /// In fr, this message translates to:
  /// **'SMS / personne'**
  String get smsConfirmationSmsPerPerson;

  /// No description provided for @smsConfirmationTotalSms.
  ///
  /// In fr, this message translates to:
  /// **'SMS total'**
  String get smsConfirmationTotalSms;

  /// No description provided for @smsConfirmationMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get smsConfirmationMessage;

  /// No description provided for @smsConfirmationMessageInfo.
  ///
  /// In fr, this message translates to:
  /// **'{length} caractères - {count} SMS'**
  String smsConfirmationMessageInfo(int length, int count);

  /// No description provided for @smsConfirmationRecipientsCount.
  ///
  /// In fr, this message translates to:
  /// **'Destinataires ({count})'**
  String smsConfirmationRecipientsCount(int count);

  /// No description provided for @smsConfirmationSendSms.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer les SMS'**
  String get smsConfirmationSendSms;

  /// No description provided for @smsConfirmationConfirmSend.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer l\'envoi'**
  String get smsConfirmationConfirmSend;

  /// No description provided for @smsConfirmationDialogBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes sur le point d\'envoyer ce message à {count} {count, plural, =1{destinataire} other{destinataires}}.\n\nCette action est irréversible.'**
  String smsConfirmationDialogBody(int count);

  /// No description provided for @smsConfirmationCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get smsConfirmationCancel;

  /// No description provided for @smsConfirmationConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get smsConfirmationConfirm;

  /// No description provided for @smsConfirmationSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'SMS envoyé !'**
  String get smsConfirmationSuccessTitle;

  /// No description provided for @smsConfirmationSuccessBody.
  ///
  /// In fr, this message translates to:
  /// **'Le message a été envoyé avec succès.'**
  String get smsConfirmationSuccessBody;

  /// No description provided for @smsConfirmationBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get smsConfirmationBack;

  /// No description provided for @smsConfirmationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'envoi.'**
  String get smsConfirmationError;

  /// No description provided for @smsHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique SMS'**
  String get smsHistoryTitle;

  /// No description provided for @smsHistoryNoSms.
  ///
  /// In fr, this message translates to:
  /// **'Aucun SMS envoyé'**
  String get smsHistoryNoSms;

  /// No description provided for @smsHistoryNoSmsDescription.
  ///
  /// In fr, this message translates to:
  /// **'Les messages envoyés apparaîtront ici.'**
  String get smsHistoryNoSmsDescription;

  /// No description provided for @smsStatusSent.
  ///
  /// In fr, this message translates to:
  /// **'Envoyé'**
  String get smsStatusSent;

  /// No description provided for @smsStatusFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec'**
  String get smsStatusFailed;

  /// No description provided for @smsStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get smsStatusPending;

  /// No description provided for @dateTimeJustNow.
  ///
  /// In fr, this message translates to:
  /// **'À l\'instant'**
  String get dateTimeJustNow;

  /// No description provided for @dateTimeMinutesAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {minutes} min'**
  String dateTimeMinutesAgo(int minutes);

  /// No description provided for @dateTimeHoursAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {hours}h'**
  String dateTimeHoursAgo(int hours);

  /// No description provided for @dateTimeYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get dateTimeYesterday;

  /// No description provided for @dateTimeDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'Il y a {days} jours'**
  String dateTimeDaysAgo(int days);

  /// No description provided for @smsHistoryMoreRecipients.
  ///
  /// In fr, this message translates to:
  /// **'+{count}'**
  String smsHistoryMoreRecipients(int count);

  /// No description provided for @smsHistoryMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get smsHistoryMessage;

  /// No description provided for @smsHistoryRecipients.
  ///
  /// In fr, this message translates to:
  /// **'Destinataires ({count})'**
  String smsHistoryRecipients(int count);

  /// No description provided for @smsHistoryDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce SMS ?'**
  String get smsHistoryDeleteTitle;

  /// No description provided for @smsHistoryDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'Ce message sera retiré de l\'historique.'**
  String get smsHistoryDeleteBody;

  /// No description provided for @smsHistoryDeleteCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get smsHistoryDeleteCancel;

  /// No description provided for @smsHistoryDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get smsHistoryDeleteConfirm;

  /// No description provided for @smsRecipientsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Destinataires'**
  String get smsRecipientsTitle;

  /// No description provided for @smsRecipientsTabIndividual.
  ///
  /// In fr, this message translates to:
  /// **'Individuel'**
  String get smsRecipientsTabIndividual;

  /// No description provided for @smsRecipientsTabFilters.
  ///
  /// In fr, this message translates to:
  /// **'Filtres'**
  String get smsRecipientsTabFilters;

  /// No description provided for @smsRecipientsTabSelection.
  ///
  /// In fr, this message translates to:
  /// **'Sélection'**
  String get smsRecipientsTabSelection;

  /// No description provided for @smsRecipientsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher par nom...'**
  String get smsRecipientsSearchHint;

  /// No description provided for @smsRecipientsAcademiciens.
  ///
  /// In fr, this message translates to:
  /// **'Académiciens'**
  String get smsRecipientsAcademiciens;

  /// No description provided for @smsRecipientsNoAcademiciens.
  ///
  /// In fr, this message translates to:
  /// **'Aucun académicien trouvé'**
  String get smsRecipientsNoAcademiciens;

  /// No description provided for @smsRecipientsEncadreurs.
  ///
  /// In fr, this message translates to:
  /// **'Encadreurs'**
  String get smsRecipientsEncadreurs;

  /// No description provided for @smsRecipientsNoEncadreurs.
  ///
  /// In fr, this message translates to:
  /// **'Aucun encadreur trouvé'**
  String get smsRecipientsNoEncadreurs;

  /// No description provided for @smsRecipientsQuickSelection.
  ///
  /// In fr, this message translates to:
  /// **'Sélection rapide'**
  String get smsRecipientsQuickSelection;

  /// No description provided for @smsRecipientsAllAcademiciens.
  ///
  /// In fr, this message translates to:
  /// **'Tous les académiciens'**
  String get smsRecipientsAllAcademiciens;

  /// No description provided for @smsRecipientsAllEncadreurs.
  ///
  /// In fr, this message translates to:
  /// **'Tous les encadreurs'**
  String get smsRecipientsAllEncadreurs;

  /// No description provided for @smsRecipientsByFootballPoste.
  ///
  /// In fr, this message translates to:
  /// **'Par poste de football'**
  String get smsRecipientsByFootballPoste;

  /// No description provided for @smsRecipientsNoPosteAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun poste disponible'**
  String get smsRecipientsNoPosteAvailable;

  /// No description provided for @smsRecipientsBySchoolLevel.
  ///
  /// In fr, this message translates to:
  /// **'Par niveau scolaire'**
  String get smsRecipientsBySchoolLevel;

  /// No description provided for @smsRecipientsNoLevelAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun niveau disponible'**
  String get smsRecipientsNoLevelAvailable;

  /// No description provided for @smsRecipientsNoRecipientSelected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun destinataire sélectionné'**
  String get smsRecipientsNoRecipientSelected;

  /// No description provided for @smsRecipientsNoRecipientSelectedDesc.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez les onglets Individuel ou Filtres\npour ajouter des destinataires.'**
  String get smsRecipientsNoRecipientSelectedDesc;

  /// No description provided for @smsRecipientsSelectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{{count} sélectionné} other{{count} sélectionnés}}'**
  String smsRecipientsSelectedCount(int count);

  /// No description provided for @smsRecipientsRemoveAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout retirer'**
  String get smsRecipientsRemoveAll;

  /// No description provided for @smsRecipientsPreview.
  ///
  /// In fr, this message translates to:
  /// **'Prévisualiser'**
  String get smsRecipientsPreview;

  /// No description provided for @workshops.
  ///
  /// In fr, this message translates to:
  /// **'Ateliers'**
  String get workshops;

  /// No description provided for @academician.
  ///
  /// In fr, this message translates to:
  /// **'Académicien'**
  String get academician;

  /// No description provided for @loadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get loadingError;

  /// No description provided for @deleteLevel.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le niveau'**
  String get deleteLevel;

  /// No description provided for @deleteLevelConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer le niveau \"{name}\" ?'**
  String deleteLevelConfirmation(String name);

  /// No description provided for @editLevel.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le niveau'**
  String get editLevel;

  /// No description provided for @newLevel.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau niveau'**
  String get newLevel;

  /// No description provided for @levelName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du niveau'**
  String get levelName;

  /// No description provided for @nameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Le nom est obligatoire'**
  String get nameRequired;

  /// No description provided for @displayOrder.
  ///
  /// In fr, this message translates to:
  /// **'Ordre d\'affichage'**
  String get displayOrder;

  /// No description provided for @orderRequired.
  ///
  /// In fr, this message translates to:
  /// **'L\'ordre est obligatoire'**
  String get orderRequired;

  /// No description provided for @enterNumberError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un nombre'**
  String get enterNumberError;

  /// No description provided for @levelsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun niveau} =1{1 niveau} other{{count} niveaux}}'**
  String levelsCount(int count);

  /// No description provided for @manageAcademicLevels.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des niveaux académiques'**
  String get manageAcademicLevels;

  /// No description provided for @noLevel.
  ///
  /// In fr, this message translates to:
  /// **'Aucun niveau'**
  String get noLevel;

  /// No description provided for @addFirstLevel.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre premier niveau scolaire\npour commencer.'**
  String get addFirstLevel;

  /// No description provided for @deletePosition.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le poste'**
  String get deletePosition;

  /// No description provided for @deletePositionConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer le poste \"{name}\" ?'**
  String deletePositionConfirmation(String name);

  /// No description provided for @editPosition.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le poste'**
  String get editPosition;

  /// No description provided for @newPosition.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau poste'**
  String get newPosition;

  /// No description provided for @positionName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du poste'**
  String get positionName;

  /// No description provided for @descriptionOptional.
  ///
  /// In fr, this message translates to:
  /// **'Description (optionnelle)'**
  String get descriptionOptional;

  /// No description provided for @positionsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun poste} =1{1 poste} other{{count} postes}}'**
  String positionsCount(int count);

  /// No description provided for @managePositions.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des postes de jeu'**
  String get managePositions;

  /// No description provided for @noPosition.
  ///
  /// In fr, this message translates to:
  /// **'Aucun poste'**
  String get noPosition;

  /// No description provided for @addFirstPosition.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre premier poste de football\npour commencer.'**
  String get addFirstPosition;

  /// No description provided for @unreadCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune non lue} =1{1 non lue} other{{count} non lues}}'**
  String unreadCount(int count);

  /// No description provided for @markAllAsRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout marquer comme lu'**
  String get markAllAsRead;

  /// No description provided for @deleteRead.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les lues'**
  String get deleteRead;

  /// No description provided for @registrations.
  ///
  /// In fr, this message translates to:
  /// **'Inscriptions'**
  String get registrations;

  /// No description provided for @smsLabel.
  ///
  /// In fr, this message translates to:
  /// **'SMS'**
  String get smsLabel;

  /// No description provided for @reminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels'**
  String get reminders;

  /// No description provided for @system.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get system;

  /// No description provided for @unreadOnly.
  ///
  /// In fr, this message translates to:
  /// **'Non lues uniquement'**
  String get unreadOnly;

  /// No description provided for @noNotification.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification'**
  String get noNotification;

  /// No description provided for @notificationsUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes à jour ! Les nouvelles notifications apparaîtront ici.'**
  String get notificationsUpToDate;

  /// No description provided for @deleteThisNotification.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette notification'**
  String get deleteThisNotification;

  /// No description provided for @deleteReadConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous supprimer toutes les notifications déjà lues ?'**
  String get deleteReadConfirmation;

  /// No description provided for @placeQrInViewfinder.
  ///
  /// In fr, this message translates to:
  /// **'Placez le code QR dans le viseur'**
  String get placeQrInViewfinder;

  /// No description provided for @rapidEntry.
  ///
  /// In fr, this message translates to:
  /// **'Entrée Rapide'**
  String get rapidEntry;

  /// No description provided for @rapidEntryDesc.
  ///
  /// In fr, this message translates to:
  /// **'Enchaîner les scans automatiquement'**
  String get rapidEntryDesc;

  /// No description provided for @unknownError.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inconnue est survenue'**
  String get unknownError;

  /// No description provided for @attendanceRecordedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Présence enregistrée'**
  String get attendanceRecordedSuccess;

  /// No description provided for @alreadyRegisteredForSession.
  ///
  /// In fr, this message translates to:
  /// **'Déjà enregistré pour cette séance'**
  String get alreadyRegisteredForSession;

  /// No description provided for @nextScan.
  ///
  /// In fr, this message translates to:
  /// **'Scanner suivant'**
  String get nextScan;

  /// No description provided for @presences.
  ///
  /// In fr, this message translates to:
  /// **'Présences'**
  String get presences;

  /// No description provided for @bulletin.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin'**
  String get bulletin;

  /// No description provided for @low.
  ///
  /// In fr, this message translates to:
  /// **'BASSE'**
  String get low;

  /// No description provided for @normal.
  ///
  /// In fr, this message translates to:
  /// **'NORMALE'**
  String get normal;

  /// No description provided for @high.
  ///
  /// In fr, this message translates to:
  /// **'HAUTE'**
  String get high;

  /// No description provided for @urgent.
  ///
  /// In fr, this message translates to:
  /// **'URGENTE'**
  String get urgent;

  /// No description provided for @monday.
  ///
  /// In fr, this message translates to:
  /// **'Lundi'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In fr, this message translates to:
  /// **'Mardi'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In fr, this message translates to:
  /// **'Mercredi'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In fr, this message translates to:
  /// **'Jeudi'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In fr, this message translates to:
  /// **'Vendredi'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In fr, this message translates to:
  /// **'Samedi'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In fr, this message translates to:
  /// **'Dimanche'**
  String get sunday;

  /// No description provided for @january.
  ///
  /// In fr, this message translates to:
  /// **'Janvier'**
  String get january;

  /// No description provided for @february.
  ///
  /// In fr, this message translates to:
  /// **'Février'**
  String get february;

  /// No description provided for @march.
  ///
  /// In fr, this message translates to:
  /// **'Mars'**
  String get march;

  /// No description provided for @april.
  ///
  /// In fr, this message translates to:
  /// **'Avril'**
  String get april;

  /// No description provided for @may.
  ///
  /// In fr, this message translates to:
  /// **'Mai'**
  String get may;

  /// No description provided for @june.
  ///
  /// In fr, this message translates to:
  /// **'Juin'**
  String get june;

  /// No description provided for @july.
  ///
  /// In fr, this message translates to:
  /// **'Juillet'**
  String get july;

  /// No description provided for @august.
  ///
  /// In fr, this message translates to:
  /// **'Août'**
  String get august;

  /// No description provided for @september.
  ///
  /// In fr, this message translates to:
  /// **'Septembre'**
  String get september;

  /// No description provided for @october.
  ///
  /// In fr, this message translates to:
  /// **'Octobre'**
  String get october;

  /// No description provided for @november.
  ///
  /// In fr, this message translates to:
  /// **'Novembre'**
  String get november;

  /// No description provided for @december.
  ///
  /// In fr, this message translates to:
  /// **'Décembre'**
  String get december;

  /// No description provided for @qrScanner.
  ///
  /// In fr, this message translates to:
  /// **'Scanner QR'**
  String get qrScanner;

  /// No description provided for @encadreursPageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Encadreurs'**
  String get encadreursPageTitle;

  /// No description provided for @coachTeamManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion de l\'equipe d\'encadrement'**
  String get coachTeamManagement;

  /// No description provided for @searchCoachHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un encadreur...'**
  String get searchCoachHint;

  /// No description provided for @statActifs.
  ///
  /// In fr, this message translates to:
  /// **'Actifs'**
  String get statActifs;

  /// No description provided for @noCoachFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun encadreur'**
  String get noCoachFound;

  /// No description provided for @addCoachAction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un encadreur'**
  String get addCoachAction;

  /// No description provided for @startByRegisteringCoach.
  ///
  /// In fr, this message translates to:
  /// **'Commencez par enregistrer votre\npremier encadreur pour demarrer.'**
  String get startByRegisteringCoach;

  /// No description provided for @deleteCoachTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l\'encadreur'**
  String get deleteCoachTitle;

  /// No description provided for @deleteCoachConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Etes-vous sur de vouloir supprimer {name} ? Cette action est irreversible.'**
  String deleteCoachConfirmation(String name);

  /// No description provided for @tabBadgeQr.
  ///
  /// In fr, this message translates to:
  /// **'Badge QR'**
  String get tabBadgeQr;

  /// No description provided for @identifiantsSection.
  ///
  /// In fr, this message translates to:
  /// **'Identifiants'**
  String get identifiantsSection;

  /// No description provided for @noSessionConductedHist.
  ///
  /// In fr, this message translates to:
  /// **'Aucune seance dirigee'**
  String get noSessionConductedHist;

  /// No description provided for @sessionHistoryWillAppear.
  ///
  /// In fr, this message translates to:
  /// **'L\'historique des seances apparaitra ici\nune fois que l\'encadreur aura dirige des seances.'**
  String get sessionHistoryWillAppear;

  /// No description provided for @sessionNumber.
  ///
  /// In fr, this message translates to:
  /// **'Seance #{num}'**
  String sessionNumber(int num);

  /// No description provided for @sessionTrainingType.
  ///
  /// In fr, this message translates to:
  /// **'Entrainement {specialty}'**
  String sessionTrainingType(String specialty);

  /// No description provided for @viewQrBadgeOption.
  ///
  /// In fr, this message translates to:
  /// **'Voir le badge QR'**
  String get viewQrBadgeOption;

  /// No description provided for @shareProfileOption.
  ///
  /// In fr, this message translates to:
  /// **'Partager le profil'**
  String get shareProfileOption;

  /// No description provided for @badgeEncadreurLabel.
  ///
  /// In fr, this message translates to:
  /// **'BADGE ENCADREUR'**
  String get badgeEncadreurLabel;

  /// No description provided for @statusConnected.
  ///
  /// In fr, this message translates to:
  /// **'Connecte'**
  String get statusConnected;

  /// No description provided for @statusOffline.
  ///
  /// In fr, this message translates to:
  /// **'Hors-ligne'**
  String get statusOffline;

  /// No description provided for @statusSyncing.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation...'**
  String get statusSyncing;

  /// No description provided for @syncStatusTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statut de synchronisation'**
  String get syncStatusTitle;

  /// No description provided for @connectionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get connectionLabel;

  /// No description provided for @pendingOperationsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Operations en attente'**
  String get pendingOperationsLabel;

  /// No description provided for @lastSyncLabel.
  ///
  /// In fr, this message translates to:
  /// **'Derniere synchronisation'**
  String get lastSyncLabel;

  /// No description provided for @syncSuccessResult.
  ///
  /// In fr, this message translates to:
  /// **'{success} reussie(s), {failures} echec(s)'**
  String syncSuccessResult(int success, int failures);

  /// No description provided for @syncNowLabel.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser maintenant'**
  String get syncNowLabel;

  /// No description provided for @syncInProgressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours...'**
  String get syncInProgressLabel;

  /// No description provided for @offlineModeActive.
  ///
  /// In fr, this message translates to:
  /// **'Mode hors-ligne actif'**
  String get offlineModeActive;

  /// No description provided for @pendingOperationsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} operation(s) en attente'**
  String pendingOperationsCount(int count);

  /// No description provided for @syncOnReconnect.
  ///
  /// In fr, this message translates to:
  /// **'Les donnees seront synchronisees au retour du reseau'**
  String get syncOnReconnect;

  /// No description provided for @exceptionNetworkDefault.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet'**
  String get exceptionNetworkDefault;

  /// No description provided for @exceptionNetworkCheck.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet. Verifiez votre reseau.'**
  String get exceptionNetworkCheck;

  /// No description provided for @exceptionTimeoutDefault.
  ///
  /// In fr, this message translates to:
  /// **'Le delai d\'attente a expire'**
  String get exceptionTimeoutDefault;

  /// No description provided for @exceptionTimeoutServer.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur met trop de temps a repondre.'**
  String get exceptionTimeoutServer;

  /// No description provided for @exceptionServerDefault.
  ///
  /// In fr, this message translates to:
  /// **'Erreur interne du serveur'**
  String get exceptionServerDefault;

  /// No description provided for @exceptionServerHttp.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de protocole HTTP.'**
  String get exceptionServerHttp;

  /// No description provided for @exceptionRequestBad.
  ///
  /// In fr, this message translates to:
  /// **'Format de donnees invalide.'**
  String get exceptionRequestBad;

  /// No description provided for @exceptionRequestBadDetails.
  ///
  /// In fr, this message translates to:
  /// **'JSON malforme ou type incorrect.'**
  String get exceptionRequestBadDetails;

  /// No description provided for @exceptionNotFoundDefault.
  ///
  /// In fr, this message translates to:
  /// **'Ressource introuvable'**
  String get exceptionNotFoundDefault;

  /// No description provided for @exceptionAuthDefault.
  ///
  /// In fr, this message translates to:
  /// **'Non authentifie'**
  String get exceptionAuthDefault;

  /// No description provided for @exceptionPermissionDefault.
  ///
  /// In fr, this message translates to:
  /// **'Acces refuse'**
  String get exceptionPermissionDefault;

  /// No description provided for @exceptionCacheDefault.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement des donnees locales'**
  String get exceptionCacheDefault;

  /// No description provided for @exceptionUnknownDefault.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue est survenue'**
  String get exceptionUnknownDefault;

  /// No description provided for @exceptionUnknownTechnical.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur inattendue est survenue (technique).'**
  String get exceptionUnknownTechnical;

  /// No description provided for @exceptionCacheReadKey.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la lecture de la cle \'\'{key}\'\' : {error}'**
  String exceptionCacheReadKey(String key, String error);

  /// No description provided for @exceptionCacheWriteKey.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'\'ecriture de la cle \'\'{key}\'\' : {error}'**
  String exceptionCacheWriteKey(String key, String error);

  /// No description provided for @exceptionCacheReadString.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la lecture de la chaine \'\'{key}\'\' : {error}'**
  String exceptionCacheReadString(String key, String error);

  /// No description provided for @exceptionCacheWriteString.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'\'ecriture de la chaine \'\'{key}\'\' : {error}'**
  String exceptionCacheWriteString(String key, String error);

  /// No description provided for @exceptionCacheDeleteKey.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression de la cle \'\'{key}\'\' : {error}'**
  String exceptionCacheDeleteKey(String key, String error);

  /// No description provided for @exceptionCacheResetPrefs.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la reinitialisation des preferences : {error}'**
  String exceptionCacheResetPrefs(String error);

  /// No description provided for @serviceSeanceNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Seance introuvable.'**
  String get serviceSeanceNotFound;

  /// No description provided for @serviceSeanceAlreadyClosed.
  ///
  /// In fr, this message translates to:
  /// **'Cette seance est deja cloturee.'**
  String get serviceSeanceAlreadyClosed;

  /// No description provided for @serviceSeanceCannotOpen.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'\'ouvrir une nouvelle seance. La seance \"{title}\" est encore ouverte. Veuillez la cloturer avant d\'\'en ouvrir une nouvelle.'**
  String serviceSeanceCannotOpen(String title);

  /// No description provided for @serviceSeanceOpenedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Seance \"{title}\" ouverte avec succes.'**
  String serviceSeanceOpenedSuccess(String title);

  /// No description provided for @serviceSeanceClosedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Seance \"{title}\" cloturee avec succes.'**
  String serviceSeanceClosedSuccess(String title);

  /// No description provided for @serviceRefPosteExists.
  ///
  /// In fr, this message translates to:
  /// **'Un poste avec ce nom existe deja.'**
  String get serviceRefPosteExists;

  /// No description provided for @serviceRefPosteOtherExists.
  ///
  /// In fr, this message translates to:
  /// **'Un autre poste avec ce nom existe deja.'**
  String get serviceRefPosteOtherExists;

  /// No description provided for @serviceRefPosteCreated.
  ///
  /// In fr, this message translates to:
  /// **'Poste \"{name}\" cree avec succes.'**
  String serviceRefPosteCreated(String name);

  /// No description provided for @serviceRefPosteUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Poste \"{name}\" modifie avec succes.'**
  String serviceRefPosteUpdated(String name);

  /// No description provided for @serviceRefPosteDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Poste supprime avec succes.'**
  String get serviceRefPosteDeleted;

  /// No description provided for @serviceRefPosteCannotDelete.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer ce poste : {count} academicien(s) rattache(s).'**
  String serviceRefPosteCannotDelete(int count);

  /// No description provided for @serviceRefNiveauExists.
  ///
  /// In fr, this message translates to:
  /// **'Un niveau avec ce nom existe deja.'**
  String get serviceRefNiveauExists;

  /// No description provided for @serviceRefNiveauOtherExists.
  ///
  /// In fr, this message translates to:
  /// **'Un autre niveau avec ce nom existe deja.'**
  String get serviceRefNiveauOtherExists;

  /// No description provided for @serviceRefNiveauCreated.
  ///
  /// In fr, this message translates to:
  /// **'Niveau \"{name}\" cree avec succes.'**
  String serviceRefNiveauCreated(String name);

  /// No description provided for @serviceRefNiveauUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Niveau \"{name}\" modifie avec succes.'**
  String serviceRefNiveauUpdated(String name);

  /// No description provided for @serviceRefNiveauDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Niveau supprime avec succes.'**
  String get serviceRefNiveauDeleted;

  /// No description provided for @serviceRefNiveauCannotDelete.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer ce niveau : {count} academicien(s) rattache(s).'**
  String serviceRefNiveauCannotDelete(int count);

  /// No description provided for @serviceScanPresenceAlreadyRecorded.
  ///
  /// In fr, this message translates to:
  /// **'Presence deja enregistree'**
  String get serviceScanPresenceAlreadyRecorded;

  /// No description provided for @serviceScanAcademicianIdentified.
  ///
  /// In fr, this message translates to:
  /// **'Academicien identifie'**
  String get serviceScanAcademicianIdentified;

  /// No description provided for @serviceScanCoachIdentified.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur identifie'**
  String get serviceScanCoachIdentified;

  /// No description provided for @serviceScanQrNotRecognized.
  ///
  /// In fr, this message translates to:
  /// **'Code QR non reconnu'**
  String get serviceScanQrNotRecognized;

  /// No description provided for @serviceScanTypeAcademician.
  ///
  /// In fr, this message translates to:
  /// **'Academicien'**
  String get serviceScanTypeAcademician;

  /// No description provided for @serviceScanTypeCoach.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur'**
  String get serviceScanTypeCoach;

  /// No description provided for @serviceAtelierSeanceNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Seance introuvable : {id}'**
  String serviceAtelierSeanceNotFound(String id);

  /// No description provided for @serviceAtelierNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Atelier introuvable : {id}'**
  String serviceAtelierNotFound(String id);

  /// No description provided for @serviceExerciceAtelierNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Atelier introuvable : {id}'**
  String serviceExerciceAtelierNotFound(String id);

  /// No description provided for @serviceExerciceNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Exercice introuvable : {id}'**
  String serviceExerciceNotFound(String id);

  /// No description provided for @serviceBulletinNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Bulletin introuvable : {id}'**
  String serviceBulletinNotFound(String id);

  /// No description provided for @serviceSyncMaxRetries.
  ///
  /// In fr, this message translates to:
  /// **'Nombre maximum de tentatives atteint'**
  String get serviceSyncMaxRetries;

  /// No description provided for @serviceSearchAcademicianSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Academicien'**
  String get serviceSearchAcademicianSubtitle;

  /// No description provided for @serviceSearchCoachSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur - {specialty}'**
  String serviceSearchCoachSubtitle(String specialty);

  /// No description provided for @infraSeanceNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Seance non trouvee : {id}'**
  String infraSeanceNotFound(String id);

  /// No description provided for @infraSmsNotFound.
  ///
  /// In fr, this message translates to:
  /// **'SMS introuvable : {id}'**
  String infraSmsNotFound(String id);

  /// No description provided for @domaineTechnique.
  ///
  /// In fr, this message translates to:
  /// **'Technique'**
  String get domaineTechnique;

  /// No description provided for @domainePhysique.
  ///
  /// In fr, this message translates to:
  /// **'Physique'**
  String get domainePhysique;

  /// No description provided for @domaineTactique.
  ///
  /// In fr, this message translates to:
  /// **'Tactique'**
  String get domaineTactique;

  /// No description provided for @domaineMental.
  ///
  /// In fr, this message translates to:
  /// **'Mental'**
  String get domaineMental;

  /// No description provided for @domaineEspritEquipe.
  ///
  /// In fr, this message translates to:
  /// **'Esprit d\'\'equipe'**
  String get domaineEspritEquipe;

  /// No description provided for @domaineGeneral.
  ///
  /// In fr, this message translates to:
  /// **'General'**
  String get domaineGeneral;

  /// No description provided for @bulletinObservationsResume.
  ///
  /// In fr, this message translates to:
  /// **'{count} observations. Derniere : {content}'**
  String bulletinObservationsResume(int count, String content);

  /// No description provided for @security.
  ///
  /// In fr, this message translates to:
  /// **'Securite'**
  String get security;

  /// No description provided for @securityTitle.
  ///
  /// In fr, this message translates to:
  /// **'Protection de votre compte'**
  String get securityTitle;

  /// No description provided for @securitySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Gerer vos options de securite et confidentialite'**
  String get securitySubtitle;

  /// No description provided for @authentication.
  ///
  /// In fr, this message translates to:
  /// **'Authentification'**
  String get authentication;

  /// No description provided for @passwordManagement.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordManagement;

  /// No description provided for @activeSessions.
  ///
  /// In fr, this message translates to:
  /// **'Sessions actives'**
  String get activeSessions;

  /// No description provided for @biometricAuth.
  ///
  /// In fr, this message translates to:
  /// **'Authentification biometrique'**
  String get biometricAuth;

  /// No description provided for @biometricAuthDesc.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser l\'empreinte ou le visage pour se connecter'**
  String get biometricAuthDesc;

  /// No description provided for @autoLock.
  ///
  /// In fr, this message translates to:
  /// **'Verrouillage automatique'**
  String get autoLock;

  /// No description provided for @autoLockDesc.
  ///
  /// In fr, this message translates to:
  /// **'Verrouiller l\'application apres inactivite'**
  String get autoLockDesc;

  /// No description provided for @immediately.
  ///
  /// In fr, this message translates to:
  /// **'Immediatement'**
  String get immediately;

  /// No description provided for @after1Minute.
  ///
  /// In fr, this message translates to:
  /// **'Apres 1 minute'**
  String get after1Minute;

  /// No description provided for @after5Minutes.
  ///
  /// In fr, this message translates to:
  /// **'Apres 5 minutes'**
  String get after5Minutes;

  /// No description provided for @after15Minutes.
  ///
  /// In fr, this message translates to:
  /// **'Apres 15 minutes'**
  String get after15Minutes;

  /// No description provided for @changePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get changePassword;

  /// No description provided for @changePasswordDesc.
  ///
  /// In fr, this message translates to:
  /// **'Mettre a jour votre mot de passe'**
  String get changePasswordDesc;

  /// No description provided for @currentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get currentPassword;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifie avec succes'**
  String get passwordChangedSuccess;

  /// No description provided for @passwordHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique du mot de passe'**
  String get passwordHistory;

  /// No description provided for @passwordHistoryDesc.
  ///
  /// In fr, this message translates to:
  /// **'Voir les modifications recentes'**
  String get passwordHistoryDesc;

  /// No description provided for @passwordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifie'**
  String get passwordChanged;

  /// No description provided for @passwordCreated.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe cree'**
  String get passwordCreated;

  /// No description provided for @thisDevice.
  ///
  /// In fr, this message translates to:
  /// **'Cet appareil'**
  String get thisDevice;

  /// No description provided for @currentSessionActive.
  ///
  /// In fr, this message translates to:
  /// **'Session active actuellement'**
  String get currentSessionActive;

  /// No description provided for @connectedDevices.
  ///
  /// In fr, this message translates to:
  /// **'Appareils connectes'**
  String get connectedDevices;

  /// No description provided for @connectedDevicesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Gerer les appareils autorises'**
  String get connectedDevicesDesc;

  /// No description provided for @signOutAllDevices.
  ///
  /// In fr, this message translates to:
  /// **'Deconnecter tous les appareils'**
  String get signOutAllDevices;

  /// No description provided for @signOutAllDevicesDesc.
  ///
  /// In fr, this message translates to:
  /// **'Terminer toutes les autres sessions'**
  String get signOutAllDevicesDesc;

  /// No description provided for @signOutAllConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous deconnecter tous les autres appareils ? Vous devrez vous reconnecter sur chaque appareil.'**
  String get signOutAllConfirmation;

  /// No description provided for @allDevicesSignedOut.
  ///
  /// In fr, this message translates to:
  /// **'Tous les appareils ont ete deconnectes'**
  String get allDevicesSignedOut;

  /// No description provided for @securityTips.
  ///
  /// In fr, this message translates to:
  /// **'Conseils de securite'**
  String get securityTips;

  /// No description provided for @securityTip1.
  ///
  /// In fr, this message translates to:
  /// **'Utilisez un mot de passe unique d\'au moins 8 caracteres'**
  String get securityTip1;

  /// No description provided for @securityTip2.
  ///
  /// In fr, this message translates to:
  /// **'Activez l\'authentification biometrique pour plus de securite'**
  String get securityTip2;

  /// No description provided for @securityTip3.
  ///
  /// In fr, this message translates to:
  /// **'Verifiez regulierement vos appareils connectes'**
  String get securityTip3;

  /// No description provided for @birthPlaceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Lieu de naissance'**
  String get birthPlaceLabel;

  /// No description provided for @birthPlaceHint.
  ///
  /// In fr, this message translates to:
  /// **'Ville, Pays'**
  String get birthPlaceHint;

  /// No description provided for @nationalityLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nationalite'**
  String get nationalityLabel;

  /// No description provided for @nationalityHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Senegalaise'**
  String get nationalityHint;

  /// No description provided for @genderLabel.
  ///
  /// In fr, this message translates to:
  /// **'Sexe'**
  String get genderLabel;

  /// No description provided for @male.
  ///
  /// In fr, this message translates to:
  /// **'Masculin'**
  String get male;

  /// No description provided for @female.
  ///
  /// In fr, this message translates to:
  /// **'Feminin'**
  String get female;

  /// No description provided for @contactLabel.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get contactLabel;

  /// No description provided for @contactSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations de contact'**
  String get contactSubtitle;

  /// No description provided for @studentPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Telephone eleve'**
  String get studentPhoneLabel;

  /// No description provided for @heightLabel.
  ///
  /// In fr, this message translates to:
  /// **'Taille'**
  String get heightLabel;

  /// No description provided for @heightHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 175'**
  String get heightHint;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @facebookHint.
  ///
  /// In fr, this message translates to:
  /// **'URL du profil Facebook'**
  String get facebookHint;

  /// No description provided for @parentInfoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Parent / Tuteur'**
  String get parentInfoLabel;

  /// No description provided for @parentInfoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations du parent et du tuteur'**
  String get parentInfoSubtitle;

  /// No description provided for @parentSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Parent'**
  String get parentSectionTitle;

  /// No description provided for @tuteurSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tuteur (optionnel)'**
  String get tuteurSectionTitle;

  /// No description provided for @parentLastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du parent'**
  String get parentLastNameLabel;

  /// No description provided for @parentLastNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom du parent'**
  String get parentLastNameHint;

  /// No description provided for @parentFirstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prenom du parent'**
  String get parentFirstNameLabel;

  /// No description provided for @parentFirstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Prenom du parent'**
  String get parentFirstNameHint;

  /// No description provided for @tuteurLastNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du tuteur'**
  String get tuteurLastNameLabel;

  /// No description provided for @tuteurLastNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom du tuteur'**
  String get tuteurLastNameHint;

  /// No description provided for @tuteurFirstNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Prenom du tuteur'**
  String get tuteurFirstNameLabel;

  /// No description provided for @tuteurFirstNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Prenom du tuteur'**
  String get tuteurFirstNameHint;

  /// No description provided for @tuteurFunctionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fonction du tuteur'**
  String get tuteurFunctionLabel;

  /// No description provided for @tuteurFunctionHint.
  ///
  /// In fr, this message translates to:
  /// **'Profession ou occupation'**
  String get tuteurFunctionHint;

  /// No description provided for @tuteurPhoneLabel.
  ///
  /// In fr, this message translates to:
  /// **'Telephone du tuteur'**
  String get tuteurPhoneLabel;

  /// No description provided for @tuteurPhotoLabel.
  ///
  /// In fr, this message translates to:
  /// **'Photo du tuteur'**
  String get tuteurPhotoLabel;

  /// No description provided for @parentNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du parent'**
  String get parentNameLabel;

  /// No description provided for @parentNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet du parent'**
  String get parentNameHint;

  /// No description provided for @parentFunctionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fonction du parent'**
  String get parentFunctionLabel;

  /// No description provided for @parentFunctionHint.
  ///
  /// In fr, this message translates to:
  /// **'Profession ou occupation'**
  String get parentFunctionHint;

  /// No description provided for @parentEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email du parent'**
  String get parentEmailLabel;

  /// No description provided for @parentAddressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse'**
  String get parentAddressLabel;

  /// No description provided for @parentAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'Adresse complete'**
  String get parentAddressHint;

  /// No description provided for @guarantorSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Garant designe'**
  String get guarantorSectionTitle;

  /// No description provided for @guarantorSectionSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Personne designee comme garant de l\'academicien'**
  String get guarantorSectionSubtitle;

  /// No description provided for @guarantorTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Qui est le garant ?'**
  String get guarantorTypeLabel;

  /// No description provided for @guarantorParentOption.
  ///
  /// In fr, this message translates to:
  /// **'Parent'**
  String get guarantorParentOption;

  /// No description provided for @guarantorTuteurOption.
  ///
  /// In fr, this message translates to:
  /// **'Tuteur'**
  String get guarantorTuteurOption;

  /// No description provided for @guarantorEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Email du garant'**
  String get guarantorEmailLabel;

  /// No description provided for @guarantorAddressLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de residence du garant'**
  String get guarantorAddressLabel;

  /// No description provided for @guarantorAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'Adresse complete'**
  String get guarantorAddressHint;

  /// No description provided for @guarantorRequiredError.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez designer un garant'**
  String get guarantorRequiredError;

  /// No description provided for @strengthsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Atouts'**
  String get strengthsLabel;

  /// No description provided for @strengthsHint.
  ///
  /// In fr, this message translates to:
  /// **'Points forts du joueur'**
  String get strengthsHint;

  /// No description provided for @weaknessesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Faiblesses'**
  String get weaknessesLabel;

  /// No description provided for @weaknessesHint.
  ///
  /// In fr, this message translates to:
  /// **'Axes d\'amelioration'**
  String get weaknessesHint;

  /// No description provided for @performanceDescriptionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Description des performances'**
  String get performanceDescriptionLabel;

  /// No description provided for @performanceDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Observations sur les performances'**
  String get performanceDescriptionHint;

  /// No description provided for @sportsHistoryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Historique sportif'**
  String get sportsHistoryLabel;

  /// No description provided for @sportsHistorySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Parcours dans les centres de formation'**
  String get sportsHistorySubtitle;

  /// No description provided for @addHistoryEntry.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une entree'**
  String get addHistoryEntry;

  /// No description provided for @historyEntry.
  ///
  /// In fr, this message translates to:
  /// **'Entree'**
  String get historyEntry;

  /// No description provided for @centerLabel.
  ///
  /// In fr, this message translates to:
  /// **'Centre'**
  String get centerLabel;

  /// No description provided for @centerHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom du centre'**
  String get centerHint;

  /// No description provided for @categoryLabel.
  ///
  /// In fr, this message translates to:
  /// **'Categorie'**
  String get categoryLabel;

  /// No description provided for @categoryHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: U15, U17'**
  String get categoryHint;

  /// No description provided for @observationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Observation'**
  String get observationLabel;

  /// No description provided for @observationHint.
  ///
  /// In fr, this message translates to:
  /// **'Remarques sur cette periode'**
  String get observationHint;

  /// No description provided for @pressAgainToExit.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez encore pour quitter'**
  String get pressAgainToExit;

  /// No description provided for @usersRolesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des rôles'**
  String get usersRolesTitle;

  /// No description provided for @usersRolesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Attribuez et modifiez les rôles des utilisateurs'**
  String get usersRolesSubtitle;

  /// No description provided for @searchUserHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un utilisateur...'**
  String get searchUserHint;

  /// No description provided for @administrators.
  ///
  /// In fr, this message translates to:
  /// **'Administrateurs'**
  String get administrators;

  /// No description provided for @inactive.
  ///
  /// In fr, this message translates to:
  /// **'Inactif'**
  String get inactive;

  /// No description provided for @noUsersFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur trouvé'**
  String get noUsersFound;

  /// No description provided for @noUsersRegistered.
  ///
  /// In fr, this message translates to:
  /// **'Aucun utilisateur enregistré dans le système.'**
  String get noUsersRegistered;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @changeUserRoleTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le rôle'**
  String get changeUserRoleTitle;

  /// No description provided for @selectNewRole.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionner le nouveau rôle'**
  String get selectNewRole;

  /// No description provided for @roleChangeWarning.
  ///
  /// In fr, this message translates to:
  /// **'Le changement de rôle modifie les permissions de l\'utilisateur.'**
  String get roleChangeWarning;

  /// No description provided for @confirmChange.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le changement'**
  String get confirmChange;

  /// No description provided for @permissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Permission refusée'**
  String get permissionDenied;

  /// No description provided for @updatingRole.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour du rôle...'**
  String get updatingRole;

  /// No description provided for @roleChangeError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du changement de rôle'**
  String get roleChangeError;

  /// No description provided for @roleChangeSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Rôle modifié avec succès'**
  String get roleChangeSuccess;

  /// No description provided for @roleSupAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Super Admin'**
  String get roleSupAdmin;

  /// No description provided for @roleAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Administrateur'**
  String get roleAdmin;

  /// No description provided for @roleEncadreurChef.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur Chef'**
  String get roleEncadreurChef;

  /// No description provided for @roleMedecinChef.
  ///
  /// In fr, this message translates to:
  /// **'Médecin Chef'**
  String get roleMedecinChef;

  /// No description provided for @roleEncadreur.
  ///
  /// In fr, this message translates to:
  /// **'Encadreur'**
  String get roleEncadreur;

  /// No description provided for @roleSurveillantGeneral.
  ///
  /// In fr, this message translates to:
  /// **'Surveillant Général'**
  String get roleSurveillantGeneral;

  /// No description provided for @roleVisiteur.
  ///
  /// In fr, this message translates to:
  /// **'Visiteur'**
  String get roleVisiteur;

  /// No description provided for @globalOverview.
  ///
  /// In fr, this message translates to:
  /// **'Vue globale'**
  String get globalOverview;

  /// No description provided for @sessionsToday.
  ///
  /// In fr, this message translates to:
  /// **'Séances aujourd\'hui'**
  String get sessionsToday;

  /// No description provided for @attendancesToday.
  ///
  /// In fr, this message translates to:
  /// **'Présences aujourd\'hui'**
  String get attendancesToday;

  /// No description provided for @seasonManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion de la saison'**
  String get seasonManagement;

  /// No description provided for @seasonOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get seasonOpen;

  /// No description provided for @seasonClose.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get seasonClose;

  /// No description provided for @seasonStatusOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouverte'**
  String get seasonStatusOpen;

  /// No description provided for @seasonStatusClosed.
  ///
  /// In fr, this message translates to:
  /// **'Fermée'**
  String get seasonStatusClosed;

  /// No description provided for @seasonStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get seasonStatusPending;

  /// No description provided for @seasonStatusNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune'**
  String get seasonStatusNone;

  /// No description provided for @noActiveSeason.
  ///
  /// In fr, this message translates to:
  /// **'Aucune saison active'**
  String get noActiveSeason;

  /// No description provided for @openNewSeason.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir une nouvelle saison'**
  String get openNewSeason;

  /// No description provided for @seasonName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la saison'**
  String get seasonName;

  /// No description provided for @seasonNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Saison 2024-2025'**
  String get seasonNameHint;

  /// No description provided for @seasonStartDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de début'**
  String get seasonStartDate;

  /// No description provided for @closeSeasonTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fermer la saison'**
  String get closeSeasonTitle;

  /// No description provided for @closeSeasonConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment fermer la saison \"{name}\" ?'**
  String closeSeasonConfirmation(String name);

  /// No description provided for @closeSeasonWarning.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get closeSeasonWarning;

  /// No description provided for @seasonOpenedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Saison ouverte avec succès'**
  String get seasonOpenedSuccess;

  /// No description provided for @seasonClosedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Saison fermée avec succès'**
  String get seasonClosedSuccess;

  /// No description provided for @seasonOpenError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'ouverture de la saison'**
  String get seasonOpenError;

  /// No description provided for @seasonCloseError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la fermeture de la saison'**
  String get seasonCloseError;

  /// No description provided for @seasonNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez entrer un nom pour la saison'**
  String get seasonNameRequired;

  /// No description provided for @roleChangeHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des changements'**
  String get roleChangeHistoryTitle;

  /// No description provided for @noRoleChangeHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun changement de rôle enregistré'**
  String get noRoleChangeHistory;

  /// No description provided for @modulesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modules'**
  String get modulesTitle;

  /// No description provided for @modulesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accès rapide à tous les modules'**
  String get modulesSubtitle;

  /// No description provided for @pendingSyncCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} en attente'**
  String pendingSyncCount(int count);

  /// No description provided for @sessionsManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des séances'**
  String get sessionsManagement;

  /// No description provided for @workshopsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ateliers'**
  String get workshopsLabel;

  /// No description provided for @workshopsManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des ateliers'**
  String get workshopsManagement;

  /// No description provided for @bulletinsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Bulletins'**
  String get bulletinsLabel;

  /// No description provided for @bulletinsManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des bulletins'**
  String get bulletinsManagement;

  /// No description provided for @smsManagement.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des SMS'**
  String get smsManagement;

  /// No description provided for @superAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Super Admin'**
  String get superAdmin;

  /// No description provided for @globalStatistics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques globales'**
  String get globalStatistics;

  /// No description provided for @totalSessions.
  ///
  /// In fr, this message translates to:
  /// **'Séances totales'**
  String get totalSessions;

  /// No description provided for @totalAttendances.
  ///
  /// In fr, this message translates to:
  /// **'Présences totales'**
  String get totalAttendances;

  /// No description provided for @totalAnnotations.
  ///
  /// In fr, this message translates to:
  /// **'Annotations totales'**
  String get totalAnnotations;

  /// No description provided for @selectSessionFirst.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez d\'abord une séance'**
  String get selectSessionFirst;

  /// No description provided for @selectPlayerFirst.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez d\'abord un joueur'**
  String get selectPlayerFirst;

  /// No description provided for @tabNotAccessible.
  ///
  /// In fr, this message translates to:
  /// **'Onglet non accessible'**
  String get tabNotAccessible;

  /// No description provided for @signaturesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Signatures'**
  String get signaturesLabel;

  /// No description provided for @signaturesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Signatures de l\'académicien et du parent/tuteur'**
  String get signaturesSubtitle;

  /// No description provided for @academicienSignatureLabel.
  ///
  /// In fr, this message translates to:
  /// **'Signature de l\'académicien'**
  String get academicienSignatureLabel;

  /// No description provided for @academicienSignatureDesc.
  ///
  /// In fr, this message translates to:
  /// **'Signature obligatoire de l\'académicien'**
  String get academicienSignatureDesc;

  /// No description provided for @parentSignatureLabel.
  ///
  /// In fr, this message translates to:
  /// **'Signature du parent/tuteur'**
  String get parentSignatureLabel;

  /// No description provided for @parentSignatureDesc.
  ///
  /// In fr, this message translates to:
  /// **'Signature optionnelle du parent ou tuteur légal'**
  String get parentSignatureDesc;

  /// No description provided for @signaturesInfo.
  ///
  /// In fr, this message translates to:
  /// **'Les signatures seront incluses dans la fiche d\'inscription finale.'**
  String get signaturesInfo;

  /// No description provided for @uploadSignatureHint.
  ///
  /// In fr, this message translates to:
  /// **'Appuyez pour ajouter une signature'**
  String get uploadSignatureHint;

  /// No description provided for @signatureRequiredError.
  ///
  /// In fr, this message translates to:
  /// **'La signature de l\'académicien est obligatoire'**
  String get signatureRequiredError;

  /// No description provided for @parentSignatureRequiredError.
  ///
  /// In fr, this message translates to:
  /// **'La signature du parent/tuteur est obligatoire pour générer la fiche'**
  String get parentSignatureRequiredError;

  /// No description provided for @serviceAtelierOnlyValidatedCanApply.
  ///
  /// In fr, this message translates to:
  /// **'Seul un atelier validé peut être appliqué.'**
  String get serviceAtelierOnlyValidatedCanApply;

  /// No description provided for @serviceExerciceOnlyValidatedCanApply.
  ///
  /// In fr, this message translates to:
  /// **'Seul un exercice validé peut être appliqué.'**
  String get serviceExerciceOnlyValidatedCanApply;

  /// No description provided for @serviceExerciceOnlyAppliedCanClose.
  ///
  /// In fr, this message translates to:
  /// **'Seul un exercice appliqué peut être fermé.'**
  String get serviceExerciceOnlyAppliedCanClose;

  /// No description provided for @serviceAtelierAppliedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Atelier appliqué avec succès en séance.'**
  String get serviceAtelierAppliedSuccess;

  /// No description provided for @serviceExerciceAppliedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Exercice appliqué avec succès en séance.'**
  String get serviceExerciceAppliedSuccess;

  /// No description provided for @applyAction.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer'**
  String get applyAction;

  /// No description provided for @applyWorkshopTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer l\'atelier'**
  String get applyWorkshopTitle;

  /// No description provided for @applyWorkshopConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous marquer \"{name}\" comme \"En cours\" ?'**
  String applyWorkshopConfirmation(String name);

  /// No description provided for @applyExerciseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Appliquer l\'exercice'**
  String get applyExerciseTitle;

  /// No description provided for @applyExerciseConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous marquer \"{name}\" comme \"En cours\" ?'**
  String applyExerciseConfirmation(String name);

  /// No description provided for @closeExerciseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fermer l\'exercice'**
  String get closeExerciseTitle;

  /// No description provided for @closeExerciseConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous fermer l\'exercice \"{name}\" ? Cette action est irreversible.'**
  String closeExerciseConfirmation(String name);

  /// No description provided for @serviceExerciceClosedSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Exercice \"{name}\" ferme avec succes.'**
  String serviceExerciceClosedSuccess(String name);

  /// No description provided for @serviceAtelierClosedAuto.
  ///
  /// In fr, this message translates to:
  /// **'L\'atelier a ete ferme automatiquement car tous ses exercices sont fermes.'**
  String get serviceAtelierClosedAuto;

  /// No description provided for @biometricActivated.
  ///
  /// In fr, this message translates to:
  /// **'Authentification biométrique activée'**
  String get biometricActivated;

  /// No description provided for @biometricDeactivated.
  ///
  /// In fr, this message translates to:
  /// **'Authentification biométrique désactivée'**
  String get biometricDeactivated;

  /// No description provided for @biometricActivationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de l\'activation'**
  String get biometricActivationError;

  /// No description provided for @biometricDeactivationError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la désactivation'**
  String get biometricDeactivationError;

  /// No description provided for @biometricUnavailableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Biométrie non disponible'**
  String get biometricUnavailableTitle;

  /// No description provided for @biometricUnavailableDesc.
  ///
  /// In fr, this message translates to:
  /// **'Votre appareil ne supporte pas l\'authentification biométrique ou aucune biométrie n\'est configurée. Veuillez vérifier les paramètres de votre appareil.'**
  String get biometricUnavailableDesc;

  /// No description provided for @activeStatus.
  ///
  /// In fr, this message translates to:
  /// **'ACTIF'**
  String get activeStatus;

  /// No description provided for @disconnectDeviceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter l\'appareil'**
  String get disconnectDeviceTitle;

  /// No description provided for @disconnectDeviceConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous déconnecter \"{deviceName}\" ?'**
  String disconnectDeviceConfirmation(String deviceName);

  /// No description provided for @deviceDisconnected.
  ///
  /// In fr, this message translates to:
  /// **'{deviceName} déconnecté'**
  String deviceDisconnected(String deviceName);

  /// No description provided for @logoutError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la déconnexion'**
  String get logoutError;

  /// No description provided for @devicesDisconnectedCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} appareil(s) déconnecté(s)'**
  String devicesDisconnectedCount(int count);

  /// No description provided for @biometricReasonResume.
  ///
  /// In fr, this message translates to:
  /// **'Authentifiez-vous pour reprendre votre session'**
  String get biometricReasonResume;

  /// No description provided for @biometricReasonAccess.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouillez pour accéder à l\'application'**
  String get biometricReasonAccess;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @medicalDashboard.
  ///
  /// In fr, this message translates to:
  /// **'Tableau de bord Médical'**
  String get medicalDashboard;

  /// No description provided for @medicalFiles.
  ///
  /// In fr, this message translates to:
  /// **'Dossiers Médicaux'**
  String get medicalFiles;

  /// No description provided for @consultations.
  ///
  /// In fr, this message translates to:
  /// **'Consultations'**
  String get consultations;

  /// No description provided for @healthOverview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu Sanitaire'**
  String get healthOverview;

  /// No description provided for @activeAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes Actives'**
  String get activeAlerts;

  /// No description provided for @unfitPlayers.
  ///
  /// In fr, this message translates to:
  /// **'Joueurs Inaptes'**
  String get unfitPlayers;

  /// No description provided for @recentAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes Récentes'**
  String get recentAlerts;

  /// No description provided for @medicalHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique Médical'**
  String get medicalHistory;

  /// No description provided for @medicalFollowUp.
  ///
  /// In fr, this message translates to:
  /// **'Suivi Médical'**
  String get medicalFollowUp;

  /// No description provided for @chiefMedicalOfficer.
  ///
  /// In fr, this message translates to:
  /// **'Médecin Chef'**
  String get chiefMedicalOfficer;

  /// No description provided for @healthStatus.
  ///
  /// In fr, this message translates to:
  /// **'État de Santé'**
  String get healthStatus;

  /// No description provided for @optimalHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé Globale: Optimale'**
  String get optimalHealth;

  /// No description provided for @fitToTrain.
  ///
  /// In fr, this message translates to:
  /// **'{percent}% des académiciens sont aptes à l\'entraînement'**
  String fitToTrain(int percent);

  /// No description provided for @searchMedicalFile.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un dossier médical...'**
  String get searchMedicalFile;

  /// No description provided for @loadingMedicalFiles.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des dossiers médicaux...'**
  String get loadingMedicalFiles;

  /// No description provided for @noConsultationInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Aucune consultation en cours'**
  String get noConsultationInProgress;

  /// No description provided for @selectAcademicianToStart.
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un académicien pour commencer.'**
  String get selectAcademicianToStart;

  /// No description provided for @allergies.
  ///
  /// In fr, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @skinProblems.
  ///
  /// In fr, this message translates to:
  /// **'Problèmes de peau'**
  String get skinProblems;

  /// No description provided for @weightLabel.
  ///
  /// In fr, this message translates to:
  /// **'Poids'**
  String get weightLabel;

  /// No description provided for @medicalVisit.
  ///
  /// In fr, this message translates to:
  /// **'Visite Médicale'**
  String get medicalVisit;

  /// No description provided for @medicalAlertAnkle.
  ///
  /// In fr, this message translates to:
  /// **'Blessure Cheville'**
  String get medicalAlertAnkle;

  /// No description provided for @medicalAlertVaccine.
  ///
  /// In fr, this message translates to:
  /// **'Suivi Vaccinal'**
  String get medicalAlertVaccine;
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
