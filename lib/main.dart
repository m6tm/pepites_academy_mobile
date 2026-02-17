import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'src/presentation/pages/splash/splash_page.dart';
import 'src/presentation/theme/app_theme.dart';
import 'src/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Verrouillage de l'orientation en mode portrait uniquement
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialisation des dépendances
  await DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    DependencyInjection.themeState.addListener(_onStateChanged);
    DependencyInjection.languageState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DependencyInjection.themeState.removeListener(_onStateChanged);
    DependencyInjection.languageState.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pépites Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: DependencyInjection.themeState.themeMode,
      locale: DependencyInjection.languageState.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const SplashPage(),
    );
  }
}
