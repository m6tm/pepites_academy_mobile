// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pepites Academy';

  @override
  String get login => 'Login';

  @override
  String get loginSubtitle => 'Access your coach or administrator space';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get password => 'Password';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign in';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create account';

  @override
  String get welcomeBack => 'Welcome!';

  @override
  String connectedAs(String role) {
    return 'Connected as $role';
  }

  @override
  String get loginFailed => 'Login failed';

  @override
  String get loginFailedDescription =>
      'Incorrect credentials. Use the test accounts.';

  @override
  String get logout => 'Log out';

  @override
  String get register => 'Register';

  @override
  String get registerSubtitle => 'Join the elite of sports training';

  @override
  String get lastName => 'Last name';

  @override
  String get lastNameHint => 'Your last name';

  @override
  String get lastNameRequired => 'Please enter your last name';

  @override
  String get firstName => 'First name';

  @override
  String get firstNameHint => 'Your first name';

  @override
  String get firstNameRequired => 'Please enter your first name';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get passwordStrengthWeak => 'Weak';

  @override
  String get passwordStrengthMedium => 'Medium';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get passwordStrengthExcellent => 'Excellent';

  @override
  String get passwordMinChars => 'At least 8 characters';

  @override
  String get passwordUppercase => 'One uppercase letter';

  @override
  String get passwordDigit => 'One digit';

  @override
  String get passwordSpecialChar => 'One special character';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get forgotPasswordTitle => 'Forgot password';

  @override
  String get forgotPasswordDescription =>
      'Enter your email to receive a 6-digit verification code.';

  @override
  String get sendCode => 'Send code';

  @override
  String get backToLogin => 'Back to login';

  @override
  String get otpVerification => 'OTP Verification';

  @override
  String get otpTitle => 'Verification';

  @override
  String otpDescription(String email) {
    return 'Enter the 6-digit code sent to\n$email';
  }

  @override
  String get verifyCode => 'Verify code';

  @override
  String get noCodeReceived => 'Didn\'t receive a code? ';

  @override
  String get resend => 'Resend';

  @override
  String get newPasswordTitle => 'New password';

  @override
  String get newPasswordSubtitle =>
      'Create a new secure password for your account.';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get newPasswordRequired => 'Please enter a password';

  @override
  String get passwordMustBeStronger => 'Password must be stronger';

  @override
  String get resetPasswordButton => 'Reset';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get settings => 'Settings';

  @override
  String get settingsSubtitle => 'Application configuration';

  @override
  String get general => 'General';

  @override
  String get administration => 'Administration';

  @override
  String get language => 'Language';

  @override
  String get languageActive => 'Active language';

  @override
  String get languageInfo =>
      'The language is applied immediately and saved for future sessions.';

  @override
  String get french => 'Francais';

  @override
  String get english => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get systemMode => 'System';

  @override
  String get lightModeDesc => 'Always light appearance';

  @override
  String get darkModeDesc => 'Always dark appearance';

  @override
  String get systemModeDesc => 'Follows device settings';

  @override
  String themeActiveLabel(String label) {
    return 'Active theme: $label';
  }

  @override
  String get themeInfo =>
      'The theme is applied immediately and saved for future sessions.';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get lightMode => 'Light mode';

  @override
  String get appearance => 'APPEARANCE';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Enabled';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get referentials => 'Referentials';

  @override
  String get referentialsSubtitle => 'Positions, Levels';

  @override
  String get categories => 'CATEGORIES';

  @override
  String get footballPositions => 'Football positions';

  @override
  String get footballPositionsSubtitle =>
      'Goalkeeper, Defender, Midfielder, Forward...';

  @override
  String get footballPositionsDesc =>
      'Manage positions assigned to academicians';

  @override
  String get schoolLevels => 'School levels';

  @override
  String get schoolLevelsSubtitle => 'Primary, Secondary, High School...';

  @override
  String get schoolLevelsDesc => 'Manage school levels of academicians';

  @override
  String get home => 'Home';

  @override
  String get academy => 'Academy';

  @override
  String get sessions => 'Sessions';

  @override
  String get communication => 'Communication';

  @override
  String get profile => 'Profile';

  @override
  String get myProfile => 'My profile';

  @override
  String get administrator => 'Administrator';

  @override
  String get coach => 'Coach';

  @override
  String get overview => 'Overview';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get sessionOfTheDay => 'Session of the day';

  @override
  String get history => 'History';

  @override
  String get globalPerformance => 'Global performance';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get viewAll => 'View all';

  @override
  String get academicians => 'Academicians';

  @override
  String get coaches => 'Coaches';

  @override
  String get sessionsMonth => 'Sessions (month)';

  @override
  String get attendanceRate => 'Attendance rate';

  @override
  String get register_action => 'Register';

  @override
  String get newAcademician => 'New academician';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get accessControl => 'Access control';

  @override
  String get players => 'Players';

  @override
  String get academiciansList => 'Academicians list';

  @override
  String get coachManagement => 'Coach management';

  @override
  String get manageAcademy =>
      'Manage your entire academy from this centralized space.';

  @override
  String get averageAttendance => 'Average\nattendance';

  @override
  String get goalsAchieved => 'Goals\nachieved';

  @override
  String get coachSatisfaction => 'Coach\nsatisfaction';

  @override
  String get positiveTrend =>
      'Positive trend: +8% attendance in February compared to January.';

  @override
  String get noRecentActivity => 'No recent activity.';

  @override
  String get noSessionRecorded => 'No session recorded.';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get noSessionInProgress => 'No session in progress';

  @override
  String get openSessionBeforeScan => 'Please open a session before scanning.';

  @override
  String get openSessionBeforeWorkshops =>
      'Please open a session before managing workshops.';

  @override
  String get readyForField => 'Ready for the field';

  @override
  String get manageSessionsDescription =>
      'Manage your sessions, evaluate your players and track their progress.';

  @override
  String get sessionInProgress => 'SESSION IN PROGRESS';

  @override
  String get inProgress => 'In progress';

  @override
  String get present => 'Present';

  @override
  String get annotations => 'Annotations';

  @override
  String get addWorkshop => 'Add workshop';

  @override
  String get closeSession => 'Close session';

  @override
  String get noCurrentSession => 'No current session';

  @override
  String get openSessionToStart => 'Open a session to start.';

  @override
  String get myActivity => 'My activity';

  @override
  String get fieldActions => 'Field actions';

  @override
  String get myAcademicians => 'My academicians';

  @override
  String get myIndicators => 'My indicators';

  @override
  String get myRecentAnnotations => 'My recent annotations';

  @override
  String get sessionsConducted => 'Sessions conducted';

  @override
  String get workshopsCreated => 'Workshops created';

  @override
  String get averageAttendanceShort => 'Avg. attendance';

  @override
  String get myAnnotations => 'My annotations';

  @override
  String get evaluateAcademician => 'Evaluate an academician';

  @override
  String get myWorkshops => 'My workshops';

  @override
  String get manageExercises => 'Manage exercises';

  @override
  String get attendance => 'Attendance';

  @override
  String get scanArrivals => 'Scan arrivals';

  @override
  String get attendanceRateLabel => 'Attendance\nrate';

  @override
  String get annotationsPerSession => 'Annotations\nper session';

  @override
  String get closedSessions => 'Closed\nsessions';

  @override
  String get activityLevel => 'Activity level';

  @override
  String get expert => 'Expert';

  @override
  String toNextLevel(int percent) {
    return '$percent% to next level';
  }

  @override
  String get smsAndNotifications => 'SMS and notifications';

  @override
  String get sent => 'Sent';

  @override
  String get thisMonth => 'This month';

  @override
  String get failed => 'Failed';

  @override
  String get newMessage => 'New message';

  @override
  String get writeAndSendSms => 'Write and send an SMS';

  @override
  String get groupMessage => 'Group message';

  @override
  String get sendToFilteredGroup => 'Send to a filtered group';

  @override
  String get smsHistory => 'SMS history';

  @override
  String get viewSentMessages => 'View sent messages';

  @override
  String get lastMessages => 'Last messages';

  @override
  String get noMessageSentYet => 'No message sent yet.';

  @override
  String get destinataire => 'recipient';

  @override
  String get destinataires => 'recipients';

  @override
  String get newSms => 'New SMS';

  @override
  String get writeYourMessage => 'Write your message';

  @override
  String get smsWillBeSent =>
      'The message will be sent by SMS to selected recipients.';

  @override
  String get typeMessageHere => 'Type your message here...';

  @override
  String get characters => 'character';

  @override
  String get charactersPlural => 'characters';

  @override
  String get remaining => 'remaining';

  @override
  String get chooseRecipients => 'Choose recipients';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get summary => 'Summary';

  @override
  String get verifyBeforeSending => 'Verify information before sending.';

  @override
  String get smsPerPerson => 'SMS / person';

  @override
  String get totalSms => 'Total SMS';

  @override
  String get message => 'Message';

  @override
  String get confirmSending => 'Confirm sending';

  @override
  String aboutToSend(int count, String plural) {
    return 'You are about to send this message to $count recipient$plural.\n\nThis action is irreversible.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get sendSms => 'Send SMS';

  @override
  String get smsSent => 'SMS sent!';

  @override
  String get messageSentSuccess => 'The message was sent successfully.';

  @override
  String get back => 'Back';

  @override
  String get sendError => 'Error while sending.';

  @override
  String get noSmsSent => 'No SMS sent';

  @override
  String get sentMessagesWillAppear => 'Sent messages will appear here.';

  @override
  String get deleteThisSms => 'Delete this SMS?';

  @override
  String get messageWillBeRemoved =>
      'This message will be removed from history.';

  @override
  String get delete => 'Delete';

  @override
  String sessionsCount(int count) {
    return '$count session(s) - History and tracking';
  }

  @override
  String get all => 'All';

  @override
  String get completed => 'Completed';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get tapToViewDetails => 'Tap to view details';

  @override
  String get noSession => 'No session';

  @override
  String get sessionsFromCoaches =>
      'Sessions created by coaches\nwill appear here.';

  @override
  String get noPositionAvailable => 'No position available';

  @override
  String get splashTagline => 'The excellence of football';

  @override
  String get defaultUser => 'User';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get onboardingTitle1 => 'Welcome to Excellence';

  @override
  String get onboardingDesc1 =>
      'Manage your football academy with modern, precise tools designed for high-level performance.';

  @override
  String get onboardingTitle2 => 'QR Code Attendance';

  @override
  String get onboardingDesc2 =>
      'Scan, validate and record access in seconds with a fast and secure system.';

  @override
  String get onboardingTitle3 => 'Master Every Session';

  @override
  String get onboardingDesc3 =>
      'Open, configure and close your training sessions while maintaining full control over every activity.';

  @override
  String get onboardingTitle4 => 'Performance Tracking';

  @override
  String get onboardingDesc4 =>
      'Add structured annotations and track each academician\'s progress with precision.';

  @override
  String get onboardingTitle5 => 'Data at the Service of Talent';

  @override
  String get onboardingDesc5 =>
      'Generate professional reports, visualize progress and optimize your players\' development.';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get logoutButton => 'Log out';

  @override
  String get scanLabel => 'SCAN';

  @override
  String get badgeNew => 'New';

  @override
  String get badgeGo => 'Go';

  @override
  String get activitySessionOpened => 'Session opened';

  @override
  String get activitySessionClosed => 'Session closed';

  @override
  String activitySessionClosedDesc(String title, int count) {
    return '$title - $count present';
  }

  @override
  String get activitySessionScheduled => 'Session scheduled';

  @override
  String get activityNewAcademician => 'New academician';

  @override
  String activityAcademicianRegistered(String name) {
    return '$name registered successfully';
  }

  @override
  String get activityAcademicianRemoved => 'Academician removed';

  @override
  String activityAcademicianRemovedDesc(String name) {
    return '$name removed from system';
  }

  @override
  String get activityNewCoach => 'New coach';

  @override
  String get activityAttendanceRecorded => 'Attendance recorded';

  @override
  String activityAttendanceDesc(String type, String name) {
    return '$type: $name';
  }

  @override
  String get activitySmsSent => 'SMS sent';

  @override
  String activitySmsSentDesc(int count, String preview) {
    return '$count recipients - $preview';
  }

  @override
  String get activitySmsFailed => 'SMS failed';

  @override
  String get activitySmsFailedDesc => 'Failed to send message';

  @override
  String get activityReportGenerated => 'Report generated';

  @override
  String get activityReferentialUpdated => 'Referential updated';

  @override
  String activityNewPosition(String name) {
    return 'New position: $name';
  }

  @override
  String activityPositionModified(String name) {
    return 'Position modified: $name';
  }

  @override
  String activityPositionRemoved(String name) {
    return 'Position removed: $name';
  }

  @override
  String activityNewLevel(String name) {
    return 'New level: $name';
  }

  @override
  String activityLevelModified(String name) {
    return 'Level modified: $name';
  }

  @override
  String activityLevelRemoved(String name) {
    return 'Level removed: $name';
  }

  @override
  String get profileAcademician => 'Academician';

  @override
  String get profileCoach => 'Coach';

  @override
  String get search => 'Search';

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get close => 'Close';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get academicianRegistrationTitle => 'Academician Registration';

  @override
  String get academicianPhotoLabel => 'Academician photo';

  @override
  String get optionalLabel => '(Optional)';

  @override
  String get identityLabel => 'Identity';

  @override
  String get academicianPersonalDetails => 'Academician personal details';

  @override
  String get requiredFields => 'Required fields';

  @override
  String get requiredField => 'Required field';

  @override
  String get requiredLabel => 'Required';

  @override
  String get registrationSuccessTitle => 'Registration Successful!';

  @override
  String get academicianQrBadgeSubtitle =>
      'The unique QR badge of the academician has been successfully generated. You can share or download it.';

  @override
  String get selectPosteAndPiedError =>
      'Please select a position and a strong foot';

  @override
  String get selectSchoolLevelError => 'Please select a school level';

  @override
  String get galleryOpenError => 'Could not open gallery';

  @override
  String academicianSaveError(String error) {
    return 'Could not save academician: $error';
  }

  @override
  String get enterLastName => 'Enter last name';

  @override
  String get enterFirstName => 'Enter first name';

  @override
  String get birthDateLabel => 'Date of birth';

  @override
  String get birthDateFormat => 'DD/MM/YYYY';

  @override
  String get parentPhoneLabel => 'Parent Phone';

  @override
  String get phoneHint => '+221 -- --- -- --';

  @override
  String get footballLabel => 'Football';

  @override
  String get sportsProfileSubtitle => 'Sports profile on the field';

  @override
  String get preferredPositionLabel => 'Preferred position';

  @override
  String get strongFootLabel => 'Strong foot';

  @override
  String get rightFooted => 'Right-footed';

  @override
  String get leftFooted => 'Left-footed';

  @override
  String get ambidextrous => 'Ambidextrous';

  @override
  String get schoolingLabel => 'Schooling';

  @override
  String get currentAcademicLevelSubtitle => 'Current academic level';

  @override
  String get continue_label => 'Continue';

  @override
  String get confirm_label => 'Confirm';

  @override
  String get previousLabel => 'Previous';

  @override
  String get notSpecified => 'Not specified';

  @override
  String get notProvided => 'Not provided';

  @override
  String get academicianBadgeTitle => 'Academician Badge';

  @override
  String get recapTitle => 'Summary';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get roleLabel => 'Role';

  @override
  String get posteLabel => 'Position';

  @override
  String get registrationDateLabel => 'Registration Date';

  @override
  String get academicianBadgeType => 'ACADEMICIAN';

  @override
  String get coachBadgeType => 'COACH';

  @override
  String get newCoachRegistrationTitle => 'New Coach';

  @override
  String get coachPersonalDetails => 'Coach personal details';

  @override
  String get enterCoachLastNameHint => 'Enter last name';

  @override
  String get enterCoachFirstNameHint => 'Enter first name';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get specialtyLabel => 'Specialty';

  @override
  String get sportExpertiseSubtitle => 'Sport expertise domain';

  @override
  String get coachSpecialtyInstructions =>
      'Select the coach\'\'s main specialty. This will determine the types of workshops they can lead.';

  @override
  String get coachRegisteredSuccess => 'Coach registered!';

  @override
  String get specialtyRequiredError => 'Please select a specialty';

  @override
  String coachSaveError(String error) {
    return 'Could not create coach: $error';
  }

  @override
  String get qrBadgeGeneratedSuccess => 'QR badge generated successfully.';

  @override
  String get shareLabel => 'Share';

  @override
  String get finishLabel => 'Finish';

  @override
  String get specialityTechnique => 'Technical';

  @override
  String get specialityTechniqueDesc => 'Dribbling, passing, shooting';

  @override
  String get specialityPhysique => 'Physical';

  @override
  String get specialityPhysiqueDesc => 'Endurance, speed, strength';

  @override
  String get specialityTactique => 'Tactical';

  @override
  String get specialityTactiqueDesc => 'Positioning, strategy, game';

  @override
  String get specialityGardien => 'Goalkeeper';

  @override
  String get specialityGardienDesc => 'Saves, restarts, positioning';

  @override
  String get specialityFormationJeunes => 'Youth training';

  @override
  String get specialityFormationJeunesDesc => 'Pedagogy, initiation';

  @override
  String get specialityPreparationMentale => 'Mental preparation';

  @override
  String get specialityPreparationMentaleDesc => 'Concentration, motivation';

  @override
  String get notificationsDisabled => 'Disabled';

  @override
  String get notifSeancesDesc => 'Opening and closing of sessions';

  @override
  String get notifPresencesDesc => 'Academician scans and clock-ins';

  @override
  String get notifAnnotationsDesc => 'New evaluations and observations';

  @override
  String get notifMessagesDesc => 'Communications and announcements';

  @override
  String get notifRappels => 'Reminders';

  @override
  String get notifRappelsDesc => 'Session reminders and deadlines';

  @override
  String get notifStorageInfo =>
      'Notification preferences are saved locally on this device.';

  @override
  String get appPlatformDesc =>
      'Management and monitoring platform\nfor football academicians';

  @override
  String get lastUpdate => 'Last update';

  @override
  String get lastUpdateValue => 'February 2026';

  @override
  String get storage => 'Storage';

  @override
  String get localStorage => 'Local (offline)';

  @override
  String get team => 'TEAM';

  @override
  String get developedBy => 'Developed by';

  @override
  String get designedFor => 'Designed for';

  @override
  String get legalInformation => 'LEGAL INFORMATION';

  @override
  String copyright(String app) {
    return '$app - All rights reserved.';
  }

  @override
  String legalUsageDesc(String app) {
    return 'This application is intended for internal use for the management of academicians, training sessions, workshops and performance monitoring within the $app football academy.';
  }

  @override
  String get legalDataDesc =>
      'Data is stored locally on the device. No personal information is transmitted to third parties.';

  @override
  String get madeWithPassion => 'Made with passion for football';

  @override
  String get referentialsDataDesc => 'Base application data';

  @override
  String get referentialsUsageInfo =>
      'Referentials fuel registration forms and application filters.';

  @override
  String roleWithSpeciality(String role, String speciality) {
    return '$role - $speciality';
  }

  @override
  String get academiciansStat => 'Academicians';

  @override
  String get annotationsStat => 'Annotations';

  @override
  String get workshopsStat => 'Workshops';

  @override
  String get all_masculine => 'All';

  @override
  String yearsOld(int age) {
    return '$age years';
  }

  @override
  String get deletePlayer => 'Delete player';

  @override
  String deletePlayerConfirmation(String name) {
    return 'Are you sure you want to delete $name? This action is irreversible.';
  }

  @override
  String get editProfile => 'Edit profile';

  @override
  String get saveModifications => 'Save modifications';

  @override
  String get modificationsSaved => 'Modifications saved';

  @override
  String playerUpdatedSuccess(String name) {
    return '$name has been updated successfully.';
  }

  @override
  String get academiciansRegisteredSubtitle =>
      'Academicians registered in the academy';

  @override
  String get searchPlayerHint => 'Search for a player...';

  @override
  String get totalLabel => 'Total';

  @override
  String get gardiensLabel => 'GKs';

  @override
  String get defLabel => 'Def.';

  @override
  String get milLabel => 'Mid.';

  @override
  String get attLabel => 'Fwd.';

  @override
  String get noPlayerFound => 'No player found';

  @override
  String get noSearchResult =>
      'No results found for this search.\nTry with other criteria.';

  @override
  String get startByRegistering =>
      'Start by registering your\nfirst academician to begin.';

  @override
  String get registerPlayerAction => 'Register a player';

  @override
  String get personalInformation => 'Personal information';

  @override
  String get evaluations => 'Evaluations';

  @override
  String get sportProfile => 'Sports profile';

  @override
  String get trainingReport => 'Training report';

  @override
  String get trainingReportDesc =>
      'View and generate the periodic training report.';

  @override
  String get accessReport => 'Access report';

  @override
  String get tapToEnlargeBadge => 'Tap on badge to enlarge';

  @override
  String get downloadLabel => 'Download';

  @override
  String updateError(String error) {
    return 'Could not update: $error';
  }

  @override
  String academicianBadgeReady(String name) {
    return '$name\'\'s badge is ready.';
  }

  @override
  String get officialBadge => 'OFFICIAL BADGE';

  @override
  String get shareBadgeAction => 'SHARE BADGE';

  @override
  String get backToDashboard => 'BACK TO DASHBOARD';

  @override
  String get sharingInProgress => 'Sharing in progress...';

  @override
  String get featureComingSoon => 'Feature coming soon.';

  @override
  String get sportProfileDesc => 'Define the student\'s role on the field.';

  @override
  String get selectPositionHint => 'Select a position';

  @override
  String get selectFootHint => 'Select the foot';

  @override
  String get confirmRegistration => 'CONFIRM REGISTRATION';

  @override
  String get selectDate => 'Select a date';

  @override
  String get recapSubtitle => 'Verify information before final validation.';

  @override
  String get futureAcademician => 'Future Academician';

  @override
  String get qrBadgeValidationWarning =>
      'Validation will automatically generate a unique QR Badge for this student.';

  @override
  String get academicLevelTitle => 'Academic Level';

  @override
  String get academicStepDesc => 'Follow-up of the academician\'\'s schooling.';

  @override
  String get selectSchoolLevelHint => 'Select the level';

  @override
  String get academicStepInfo =>
      'This information allows filtering SMS communications and adapting reports.';

  @override
  String get bulletinTitle => 'Training Bulletin';

  @override
  String get bulletinSubtitle => 'Periodic Training Bulletin';

  @override
  String get historyTitle => 'Bulletin History';

  @override
  String get observationsLabel => 'General Remarks';

  @override
  String get observationsHint => 'Write your remarks for this period...';

  @override
  String get encadreurLabel => 'Coach';

  @override
  String get sessionsLabel => 'Sessions';

  @override
  String get presenceLabel => 'Attendance';

  @override
  String get annotationsLabel => 'Annotations';

  @override
  String bornOn(String date) {
    return 'Born on $date';
  }

  @override
  String generatedOn(String date) {
    return 'Generated on $date';
  }

  @override
  String get generateBulletin => 'Generate Bulletin';

  @override
  String get generatingInProgress => 'Generating...';

  @override
  String get exportImage => 'Export image';

  @override
  String get noAppreciation => 'No assessment available';

  @override
  String get appreciationGenerationNote =>
      'Assessments will be generated from annotations.';

  @override
  String get noObservation => 'No remarks written.';

  @override
  String bulletinsGeneratedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bulletins generated',
      one: '1 bulletin generated',
      zero: 'No bulletin generated',
    );
    return '$_temp0';
  }

  @override
  String get notEnoughDataEvolution =>
      'Not enough data to display evolution.\nGenerate several bulletins to see the curves.';

  @override
  String get radarChartTitle => 'Competencies Radar';

  @override
  String get evolutionChartTitle => 'Competencies Evolution';

  @override
  String get actualLabel => 'Current';

  @override
  String get competenceTechnique => 'Technical';

  @override
  String get competencePhysique => 'Physical';

  @override
  String get competenceTactique => 'Tactical';

  @override
  String get competenceMental => 'Mental';

  @override
  String get competenceEspritEquipe => 'Team Spirit';

  @override
  String get periodTitle => 'Bulletin Period';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodQuarter => 'Quarter';

  @override
  String get periodSeason => 'Season';

  @override
  String quarterLabel(int count, int year) {
    return 'Quarter $count - $year';
  }

  @override
  String seasonLabel(int start, int end) {
    return 'Season $start-$end';
  }

  @override
  String get bulletinCaptured =>
      'Bulletin captured. Sharing feature available soon.';

  @override
  String exportError(String error) {
    return 'Export error: $error';
  }

  @override
  String get annotationPageTitle => 'Annotations';

  @override
  String get tapToAnnotate => 'Tap to annotate';

  @override
  String get noAcademicianPresent => 'No academician present';

  @override
  String get noAcademicianPresentDesc =>
      'Academicians present in the session\nwill appear here for annotation.';

  @override
  String academiciansCount(int count) {
    return '$count academicians';
  }

  @override
  String annotationsCount(int count) {
    return '$count annotations';
  }

  @override
  String get quickTags => 'Quick tags';

  @override
  String get tagPositif => 'Positive';

  @override
  String get tagExcellent => 'Excellent';

  @override
  String get tagEnProgres => 'In progress';

  @override
  String get tagBonneAttitude => 'Good attitude';

  @override
  String get tagCreatif => 'Creative';

  @override
  String get tagATravailler => 'Needs work';

  @override
  String get tagInsuffisant => 'Insufficient';

  @override
  String get tagManqueEffort => 'Lack of effort';

  @override
  String get tagDistrait => 'Distracted';

  @override
  String get tagTechnique => 'Technical';

  @override
  String get tagDribble => 'Dribble';

  @override
  String get tagPasse => 'Pass';

  @override
  String get tagTir => 'Shot';

  @override
  String get tagPlacement => 'Positioning';

  @override
  String get tagEndurance => 'Endurance';

  @override
  String get detailedObservation => 'Detailed observation';

  @override
  String get observationHintAnnotation =>
      'E.g.: Good game reading, lack of support...';

  @override
  String get noteOptional => 'Rating (optional)';

  @override
  String noteFormat(String note) {
    return '$note/10';
  }

  @override
  String get saving => 'Saving...';

  @override
  String get saveAnnotation => 'Save annotation';

  @override
  String historyCountLabel(int count) {
    return 'History ($count)';
  }

  @override
  String get noPreviousAnnotation => 'No previous annotation';

  @override
  String get communicationTitle => 'Communication';

  @override
  String get sentLabel => 'Sent';

  @override
  String get thisMonthLabel => 'This month';

  @override
  String get failedLabel => 'Failed';

  @override
  String get composeAndSendSms => 'Compose and send an SMS';

  @override
  String get historyActionLabel => 'History';

  @override
  String recipientsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipients',
      one: '1 recipient',
    );
    return '$_temp0';
  }

  @override
  String get sessionsTitle => 'Sessions';

  @override
  String sessionsCountSubtitle(int count) {
    return '$count session(s) - History and tracking';
  }

  @override
  String get filterAll => 'All';

  @override
  String get filterInProgress => 'In progress';

  @override
  String get filterCompleted => 'Completed';

  @override
  String get filterUpcoming => 'Upcoming';

  @override
  String get sessionInProgressBanner => 'SESSION IN PROGRESS';

  @override
  String get tapToViewDetail => 'Tap to view details';

  @override
  String get sessionsCreatedByCoaches =>
      'Sessions created by coaches\nwill appear here.';

  @override
  String get mySessionsTitle => 'My sessions';

  @override
  String get openSessionTooltip => 'Open a session';

  @override
  String get openFirstSession => 'Open your first session\nto start training.';

  @override
  String get openSession => 'Open a session';

  @override
  String get closeThisSession => 'Close this session';

  @override
  String get fillInfoToStart => 'Fill in the information to start.';

  @override
  String get sessionTitleLabel => 'Session title';

  @override
  String get sessionTitleHint => 'E.g.: Technical Training';

  @override
  String get startLabel => 'Start';

  @override
  String get endLabel => 'End';

  @override
  String get startSession => 'Start session';

  @override
  String get pleaseEnterTitle => 'Please enter a title.';

  @override
  String get sessionInProgressDialogTitle => 'Session in progress';

  @override
  String get understoodButton => 'Got it';

  @override
  String get closeSessionButton => 'Close session';

  @override
  String get closeSessionDialogTitle => 'Close session';

  @override
  String get closeSessionConfirmation => 'Do you want to close this session?';

  @override
  String get dataFrozenNote =>
      'Data will be frozen and the session will become read-only.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get confirmButton => 'Confirm';

  @override
  String get sessionClosed => 'Session closed';

  @override
  String get presentsRecapLabel => 'Present';

  @override
  String get workshopsRecapLabel => 'Workshops';

  @override
  String get perfectButton => 'Perfect';

  @override
  String presentCount(int count) {
    return '$count present';
  }

  @override
  String workshopCount(int count) {
    return '$count workshop(s)';
  }

  @override
  String get meLabel => 'Me';

  @override
  String get annotationsScreenTitle => 'Annotations';

  @override
  String get myObservationsSubtitle => 'My observations and evaluations';

  @override
  String get positivesLabel => 'Positive';

  @override
  String get toWorkOnLabel => 'Needs work';

  @override
  String get allTagFilter => 'All';

  @override
  String get inProgressTagFilter => 'In progress';

  @override
  String get techniqueTagFilter => 'Technical';

  @override
  String get encadreurSmsSubtitle => 'Send SMS to academicians and parents';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String presentsInfoLabel(int count) {
    return '$count present';
  }

  @override
  String workshopsInfoLabel(int count) {
    return '$count workshops';
  }

  @override
  String get workshopCompositionTitle => 'Workshops';

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
      other: 'programmed',
      one: 'programmed',
    );
    return '$count workshop$_temp0 $_temp1';
  }

  @override
  String get noWorkshopProgrammed => 'No workshops programmed';

  @override
  String get workshopCompositionSubtitle =>
      'Compose your session by adding workshops.\nEach workshop represents an activity block.';

  @override
  String get addWorkshopTitle => 'Add a workshop';

  @override
  String get editWorkshopTitle => 'Edit workshop';

  @override
  String get deleteWorkshopTitle => 'Delete workshop?';

  @override
  String deleteWorkshopConfirmation(String name) {
    return 'The workshop \"$name\" will be permanently deleted.';
  }

  @override
  String get selectExerciseType => 'Select an exercise type';

  @override
  String get workshopNameLabel => 'Workshop name';

  @override
  String get workshopNameHint => 'Ex: Slalom dribbling';

  @override
  String get workshopNameRequired => 'Name is required';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionHint => 'Ex: Footwork and ball control';

  @override
  String get saveWorkshop => 'Add this workshop';

  @override
  String get annotateAction => 'Annotate';

  @override
  String get workshopTypeDribble => 'Dribble';

  @override
  String get workshopTypePasses => 'Passes';

  @override
  String get workshopTypeFinition => 'Finishing';

  @override
  String get workshopTypePhysique => 'Physical condition';

  @override
  String get workshopTypeJeuEnSituation => 'Game situation';

  @override
  String get workshopTypeTactique => 'Tactics';

  @override
  String get workshopTypeGardien => 'Goalkeeper';

  @override
  String get workshopTypeEchauffement => 'Warm-up';

  @override
  String get workshopTypePersonnalise => 'Custom';

  @override
  String get sessionAddAtLeastOneWorkshop =>
      'Add at least one workshop to be able to annotate.';

  @override
  String get presentCoaches => 'Present coaches';

  @override
  String get responsibleLabel => 'Responsible';

  @override
  String get horaireLabel => 'Schedule';

  @override
  String get manageAction => 'Manage';

  @override
  String get noCoachRegistered => 'No coach registered';

  @override
  String get noAcademicianRegistered => 'No academician registered';

  @override
  String get searchHint => 'Search for an academician, coach, session...';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get clearAll => 'Clear all';

  @override
  String get universalSearch => 'Universal Search';

  @override
  String get universalSearchDesc =>
      'Quickly find an academician, a coach or a session.';

  @override
  String get noResultsFound => 'No results';

  @override
  String get noResultsDesc => 'Try with other search terms.';

  @override
  String get playerLabel => 'Player';

  @override
  String get academicianFile => 'Academician File';

  @override
  String get infosTab => 'Infos';

  @override
  String get presencesTab => 'Presences';

  @override
  String get notesTab => 'Notes';

  @override
  String get bulletinsTab => 'Reports';

  @override
  String get personalInfos => 'Personal information';

  @override
  String get sportInfos => 'Sport information';

  @override
  String get ageLabel => 'Age';

  @override
  String get noPresenceRecorded => 'No presence recorded';

  @override
  String get noAnnotationRecorded => 'No annotation recorded';

  @override
  String get noBulletinGenerated => 'No report generated';

  @override
  String get coachFile => 'Coach File';

  @override
  String get statsTab => 'Stats';

  @override
  String get activityLabel => 'Activity';

  @override
  String get conductedSessions => 'Conducted sessions';

  @override
  String get conductedAnnotations => 'Conducted annotations';

  @override
  String get recordedPresences => 'Recorded presences';

  @override
  String get noConductedSession => 'No conducted session';

  @override
  String get closedSessionsStat => 'Closed sessions';

  @override
  String get avgPresents => 'Avg. presents';

  @override
  String get totalWorkshops => 'Total workshops';

  @override
  String get closureRate => 'Closure rate';

  @override
  String get keyFigures => 'Key figures';

  @override
  String get scannedPresences => 'Scanned presences';

  @override
  String get teamTab => 'Team';

  @override
  String get recapTab => 'Recap';

  @override
  String get sessionDetailTitle => 'Session Detail';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get saveAction => 'Save';

  @override
  String get addAction => 'Add';

  @override
  String get editAction => 'Edit';

  @override
  String get sessionStatusOpen => 'In progress';

  @override
  String get sessionStatusClosed => 'Closed';

  @override
  String get sessionStatusUpcoming => 'Upcoming';

  @override
  String lastUpdateWithDate(String date) {
    return 'Last updated on $date';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get positionLabel => 'Position';

  @override
  String get schoolLevelLabel => 'School level';

  @override
  String get qrCodeLabel => 'QR Code';

  @override
  String noteLabel(String note) {
    return 'Note: $note/10';
  }

  @override
  String get phoneLabel => 'Phone';

  @override
  String get registeredOnLabel => 'Registered on';

  @override
  String get sessionLabel => 'Session';

  @override
  String get coachLabel => 'Coach';

  @override
  String presentCountLabel(String count) {
    return '$count present(s)';
  }

  @override
  String workshopCountLabel(String count) {
    return '$count workshop(s)';
  }

  @override
  String coachWithNumber(int number) {
    return 'Coach $number';
  }

  @override
  String academicianWithNumber(int number) {
    return 'Academician $number';
  }

  @override
  String get academicianProfileTitle => 'Academician Record';

  @override
  String get academicianBadgeTypeMention => 'ACADEMICIAN';

  @override
  String get coachProfileTitle => 'Coach Record';

  @override
  String get coachBadgeTypeMention => 'COACH';

  @override
  String get recapLabel => 'Summary';

  @override
  String get statsLabel => 'Statistics';

  @override
  String get sessionsTab => 'Sessions';

  @override
  String get presentLabel => 'Present';

  @override
  String sessionWithIdLabel(String id) {
    return 'Session $id...';
  }

  @override
  String get statusLabel => 'Status';

  @override
  String get generalInformation => 'General Information';

  @override
  String get presentAcademicians => 'Present Academicians';

  @override
  String get completedWorkshops => 'Completed Workshops';

  @override
  String get noCoachRecorded => 'No coach recorded';

  @override
  String get noAcademicianRecorded => 'No academician recorded';

  @override
  String get noWorkshopRecorded => 'No workshop recorded';

  @override
  String get at => ' at ';

  @override
  String notesInfoLabel(int count) {
    return '$count notes';
  }

  @override
  String get smsComposeTitle => 'New SMS';

  @override
  String get smsComposeHeader => 'Write your message';

  @override
  String get smsComposeSubHeader =>
      'The message will be sent by SMS to the selected recipients.';

  @override
  String get smsComposeHint => 'Enter your message here...';

  @override
  String smsComposeCharCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count characters',
      one: '$count character',
    );
    return '$_temp0';
  }

  @override
  String smsComposeSmsCount(int count) {
    return '$count SMS';
  }

  @override
  String smsComposeRemainingChars(int count) {
    return '$count remaining';
  }

  @override
  String get smsComposeChooseRecipients => 'Choose recipients';

  @override
  String get smsConfirmationTitle => 'Confirmation';

  @override
  String get smsConfirmationSummary => 'Summary';

  @override
  String get smsConfirmationCheckInfo =>
      'Check the information before sending.';

  @override
  String smsConfirmationRecipient(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Recipients',
      one: 'Recipient',
    );
    return '$_temp0';
  }

  @override
  String get smsConfirmationSmsPerPerson => 'SMS / person';

  @override
  String get smsConfirmationTotalSms => 'Total SMS';

  @override
  String get smsConfirmationMessage => 'Message';

  @override
  String smsConfirmationMessageInfo(int length, int count) {
    return '$length characters - $count SMS';
  }

  @override
  String smsConfirmationRecipientsCount(int count) {
    return 'Recipients ($count)';
  }

  @override
  String get smsConfirmationSendSms => 'Send SMS';

  @override
  String get smsConfirmationConfirmSend => 'Confirm sending';

  @override
  String smsConfirmationDialogBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recipients',
      one: 'recipient',
    );
    return 'You are about to send this message to $count $_temp0.\n\nThis action is irreversible.';
  }

  @override
  String get smsConfirmationCancel => 'Cancel';

  @override
  String get smsConfirmationConfirm => 'Confirm';

  @override
  String get smsConfirmationSuccessTitle => 'SMS sent!';

  @override
  String get smsConfirmationSuccessBody => 'The message was sent successfully.';

  @override
  String get smsConfirmationBack => 'Back';

  @override
  String get smsConfirmationError => 'Error while sending.';

  @override
  String get smsHistoryTitle => 'SMS History';

  @override
  String get smsHistoryNoSms => 'No SMS sent';

  @override
  String get smsHistoryNoSmsDescription => 'Sent messages will appear here.';

  @override
  String get smsStatusSent => 'Sent';

  @override
  String get smsStatusFailed => 'Failed';

  @override
  String get smsStatusPending => 'Pending';

  @override
  String get dateTimeJustNow => 'Just now';

  @override
  String dateTimeMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String dateTimeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String get dateTimeYesterday => 'Yesterday';

  @override
  String dateTimeDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String smsHistoryMoreRecipients(int count) {
    return '+$count';
  }

  @override
  String get smsHistoryMessage => 'Message';

  @override
  String smsHistoryRecipients(int count) {
    return 'Recipients ($count)';
  }

  @override
  String get smsHistoryDeleteTitle => 'Delete this SMS?';

  @override
  String get smsHistoryDeleteBody =>
      'This message will be removed from the history.';

  @override
  String get smsHistoryDeleteCancel => 'Cancel';

  @override
  String get smsHistoryDeleteConfirm => 'Delete';

  @override
  String get smsRecipientsTitle => 'Recipients';

  @override
  String get smsRecipientsTabIndividual => 'Individual';

  @override
  String get smsRecipientsTabFilters => 'Filters';

  @override
  String get smsRecipientsTabSelection => 'Selection';

  @override
  String get smsRecipientsSearchHint => 'Search by name...';

  @override
  String get smsRecipientsAcademiciens => 'Academicians';

  @override
  String get smsRecipientsNoAcademiciens => 'No academician found';

  @override
  String get smsRecipientsEncadreurs => 'Coaches';

  @override
  String get smsRecipientsNoEncadreurs => 'No coach found';

  @override
  String get smsRecipientsQuickSelection => 'Quick selection';

  @override
  String get smsRecipientsAllAcademiciens => 'All academicians';

  @override
  String get smsRecipientsAllEncadreurs => 'All coaches';

  @override
  String get smsRecipientsByFootballPoste => 'By football position';

  @override
  String get smsRecipientsNoPosteAvailable => 'No position available';

  @override
  String get smsRecipientsBySchoolLevel => 'By school level';

  @override
  String get smsRecipientsNoLevelAvailable => 'No level available';

  @override
  String get smsRecipientsNoRecipientSelected => 'No recipient selected';

  @override
  String get smsRecipientsNoRecipientSelectedDesc =>
      'Use the Individual or Filters tabs\nto add recipients.';

  @override
  String smsRecipientsSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '$count selected',
    );
    return '$_temp0';
  }

  @override
  String get smsRecipientsRemoveAll => 'Remove all';

  @override
  String get smsRecipientsPreview => 'Preview';

  @override
  String get workshops => 'Workshops';

  @override
  String get academician => 'Academician';

  @override
  String get loadingError => 'Loading error';

  @override
  String get deleteLevel => 'Delete level';

  @override
  String deleteLevelConfirmation(String name) {
    return 'Are you sure you want to delete the level \"$name\"?';
  }

  @override
  String get editLevel => 'Edit level';

  @override
  String get newLevel => 'New level';

  @override
  String get levelName => 'Level name';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get displayOrder => 'Display order';

  @override
  String get orderRequired => 'Order is required';

  @override
  String get enterNumberError => 'Please enter a number';

  @override
  String levelsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count levels',
      one: '1 level',
      zero: 'No level',
    );
    return '$_temp0';
  }

  @override
  String get manageAcademicLevels => 'Management of academic levels';

  @override
  String get noLevel => 'No level';

  @override
  String get addFirstLevel => 'Add your first school level\nto start.';

  @override
  String get deletePosition => 'Delete position';

  @override
  String deletePositionConfirmation(String name) {
    return 'Are you sure you want to delete the position \"$name\"?';
  }

  @override
  String get editPosition => 'Edit position';

  @override
  String get newPosition => 'New position';

  @override
  String get positionName => 'Position name';

  @override
  String get descriptionOptional => 'Description (optional)';

  @override
  String positionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count positions',
      one: '1 position',
      zero: 'No position',
    );
    return '$_temp0';
  }

  @override
  String get managePositions => 'Management of game positions';

  @override
  String get noPosition => 'No position';

  @override
  String get addFirstPosition => 'Add your first football position\nto start.';

  @override
  String unreadCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unread',
      one: '1 unread',
      zero: 'No unread',
    );
    return '$_temp0';
  }

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get deleteRead => 'Delete read';

  @override
  String get registrations => 'Registrations';

  @override
  String get smsLabel => 'SMS';

  @override
  String get reminders => 'Reminders';

  @override
  String get system => 'System';

  @override
  String get unreadOnly => 'Unread only';

  @override
  String get noNotification => 'No notification';

  @override
  String get notificationsUpToDate =>
      'You\'re up to date! New notifications will appear here.';

  @override
  String get deleteThisNotification => 'Delete this notification';

  @override
  String get deleteReadConfirmation =>
      'Do you want to delete all already read notifications?';

  @override
  String get placeQrInViewfinder => 'Place the QR code in the viewfinder';

  @override
  String get rapidEntry => 'Rapid Entry';

  @override
  String get rapidEntryDesc => 'Chain scans automatically';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get attendanceRecordedSuccess => 'Attendance recorded';

  @override
  String get alreadyRegisteredForSession =>
      'Already registered for this session';

  @override
  String get nextScan => 'Next scan';

  @override
  String get presences => 'Attendance';

  @override
  String get bulletin => 'Bulletin';

  @override
  String get low => 'LOW';

  @override
  String get normal => 'NORMAL';

  @override
  String get high => 'HIGH';

  @override
  String get urgent => 'URGENT';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get qrScanner => 'QR Scanner';

  @override
  String get encadreursPageTitle => 'Coaches';

  @override
  String get coachTeamManagement => 'Coach team management';

  @override
  String get searchCoachHint => 'Search for a coach...';

  @override
  String get statActifs => 'Active';

  @override
  String get noCoachFound => 'No coach';

  @override
  String get addCoachAction => 'Add a coach';

  @override
  String get startByRegisteringCoach =>
      'Start by registering your\nfirst coach to begin.';

  @override
  String get deleteCoachTitle => 'Delete coach';

  @override
  String deleteCoachConfirmation(String name) {
    return 'Are you sure you want to delete $name? This action is irreversible.';
  }

  @override
  String get tabBadgeQr => 'QR Badge';

  @override
  String get identifiantsSection => 'Identifiers';

  @override
  String get noSessionConductedHist => 'No session conducted';

  @override
  String get sessionHistoryWillAppear =>
      'Session history will appear here\nonce the coach has led sessions.';

  @override
  String sessionNumber(int num) {
    return 'Session #$num';
  }

  @override
  String sessionTrainingType(String specialty) {
    return '$specialty training';
  }

  @override
  String get viewQrBadgeOption => 'View QR badge';

  @override
  String get shareProfileOption => 'Share profile';

  @override
  String get badgeEncadreurLabel => 'COACH BADGE';

  @override
  String get statusConnected => 'Connected';

  @override
  String get statusOffline => 'Offline';

  @override
  String get statusSyncing => 'Syncing...';

  @override
  String get syncStatusTitle => 'Sync status';

  @override
  String get connectionLabel => 'Connection';

  @override
  String get pendingOperationsLabel => 'Pending operations';

  @override
  String get lastSyncLabel => 'Last sync';

  @override
  String syncSuccessResult(int success, int failures) {
    return '$success succeeded, $failures failed';
  }

  @override
  String get syncNowLabel => 'Sync now';

  @override
  String get syncInProgressLabel => 'Syncing...';

  @override
  String get offlineModeActive => 'Offline mode active';

  @override
  String pendingOperationsCount(int count) {
    return '$count pending operation(s)';
  }

  @override
  String get syncOnReconnect =>
      'Data will be synced when connection is restored';

  @override
  String get exceptionNetworkDefault => 'No internet connection';

  @override
  String get exceptionNetworkCheck =>
      'No internet connection. Check your network.';

  @override
  String get exceptionTimeoutDefault => 'Request timed out';

  @override
  String get exceptionTimeoutServer =>
      'The server is taking too long to respond.';

  @override
  String get exceptionServerDefault => 'Internal server error';

  @override
  String get exceptionServerHttp => 'HTTP protocol error.';

  @override
  String get exceptionRequestBad => 'Invalid data format.';

  @override
  String get exceptionRequestBadDetails => 'Malformed JSON or incorrect type.';

  @override
  String get exceptionNotFoundDefault => 'Resource not found';

  @override
  String get exceptionAuthDefault => 'Not authenticated';

  @override
  String get exceptionPermissionDefault => 'Access denied';

  @override
  String get exceptionCacheDefault => 'Error loading local data';

  @override
  String get exceptionUnknownDefault => 'An unexpected error occurred';

  @override
  String get exceptionUnknownTechnical =>
      'An unexpected error occurred (technical).';

  @override
  String exceptionCacheReadKey(String key, String error) {
    return 'Error reading key \'\'$key\'\': $error';
  }

  @override
  String exceptionCacheWriteKey(String key, String error) {
    return 'Error writing key \'\'$key\'\': $error';
  }

  @override
  String exceptionCacheReadString(String key, String error) {
    return 'Error reading string \'\'$key\'\': $error';
  }

  @override
  String exceptionCacheWriteString(String key, String error) {
    return 'Error writing string \'\'$key\'\': $error';
  }

  @override
  String exceptionCacheDeleteKey(String key, String error) {
    return 'Error deleting key \'\'$key\'\': $error';
  }

  @override
  String exceptionCacheResetPrefs(String error) {
    return 'Error resetting preferences: $error';
  }

  @override
  String get serviceSeanceNotFound => 'Session not found.';

  @override
  String get serviceSeanceAlreadyClosed => 'This session is already closed.';

  @override
  String serviceSeanceCannotOpen(String title) {
    return 'Cannot open a new session. The session \"$title\" is still open. Please close it before opening a new one.';
  }

  @override
  String serviceSeanceOpenedSuccess(String title) {
    return 'Session \"$title\" opened successfully.';
  }

  @override
  String serviceSeanceClosedSuccess(String title) {
    return 'Session \"$title\" closed successfully.';
  }

  @override
  String get serviceRefPosteExists =>
      'A position with this name already exists.';

  @override
  String get serviceRefPosteOtherExists =>
      'Another position with this name already exists.';

  @override
  String serviceRefPosteCreated(String name) {
    return 'Position \"$name\" created successfully.';
  }

  @override
  String serviceRefPosteUpdated(String name) {
    return 'Position \"$name\" updated successfully.';
  }

  @override
  String get serviceRefPosteDeleted => 'Position deleted successfully.';

  @override
  String serviceRefPosteCannotDelete(int count) {
    return 'Cannot delete this position: $count academician(s) linked.';
  }

  @override
  String get serviceRefNiveauExists => 'A level with this name already exists.';

  @override
  String get serviceRefNiveauOtherExists =>
      'Another level with this name already exists.';

  @override
  String serviceRefNiveauCreated(String name) {
    return 'Level \"$name\" created successfully.';
  }

  @override
  String serviceRefNiveauUpdated(String name) {
    return 'Level \"$name\" updated successfully.';
  }

  @override
  String get serviceRefNiveauDeleted => 'Level deleted successfully.';

  @override
  String serviceRefNiveauCannotDelete(int count) {
    return 'Cannot delete this level: $count academician(s) linked.';
  }

  @override
  String get serviceScanPresenceAlreadyRecorded =>
      'Attendance already recorded';

  @override
  String get serviceScanAcademicianIdentified => 'Academician identified';

  @override
  String get serviceScanCoachIdentified => 'Coach identified';

  @override
  String get serviceScanQrNotRecognized => 'QR code not recognized';

  @override
  String get serviceScanTypeAcademician => 'Academician';

  @override
  String get serviceScanTypeCoach => 'Coach';

  @override
  String serviceAtelierSeanceNotFound(String id) {
    return 'Session not found: $id';
  }

  @override
  String serviceAtelierNotFound(String id) {
    return 'Workshop not found: $id';
  }

  @override
  String serviceBulletinNotFound(String id) {
    return 'Bulletin not found: $id';
  }

  @override
  String get serviceSyncMaxRetries => 'Maximum number of retries reached';

  @override
  String get serviceSearchAcademicianSubtitle => 'Academician';

  @override
  String serviceSearchCoachSubtitle(String specialty) {
    return 'Coach - $specialty';
  }

  @override
  String infraSeanceNotFound(String id) {
    return 'Session not found: $id';
  }

  @override
  String infraSmsNotFound(String id) {
    return 'SMS not found: $id';
  }

  @override
  String get domaineTechnique => 'Technical';

  @override
  String get domainePhysique => 'Physical';

  @override
  String get domaineTactique => 'Tactical';

  @override
  String get domaineMental => 'Mental';

  @override
  String get domaineEspritEquipe => 'Team spirit';

  @override
  String get domaineGeneral => 'General';

  @override
  String bulletinObservationsResume(int count, String content) {
    return '$count observations. Last: $content';
  }
}
