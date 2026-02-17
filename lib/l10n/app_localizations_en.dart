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
  String get workshops => 'Workshops';

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
  String bulletinsGeneratedCount(num count) {
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
}
