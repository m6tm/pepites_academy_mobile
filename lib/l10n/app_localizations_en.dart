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
  String get resetPassword => 'Reset password';

  @override
  String get otpVerification => 'OTP Verification';

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
  String get themeSystem => 'System';

  @override
  String get themeLightDescription => 'Always light appearance';

  @override
  String get themeDarkDescription => 'Always dark appearance';

  @override
  String get themeSystemDescription => 'Follows device settings';

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
  String get footballPositionsDescription =>
      'Manage positions assigned to academicians';

  @override
  String get schoolLevels => 'School levels';

  @override
  String get schoolLevelsSubtitle => 'Grade 1, Grade 2, Grade 6...';

  @override
  String get schoolLevelsDescription => 'Manage school levels of academicians';

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
}
