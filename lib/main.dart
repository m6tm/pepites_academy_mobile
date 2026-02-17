import 'package:flutter/material.dart';
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
    DependencyInjection.themeState.addListener(_onThemeChanged);
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DependencyInjection.themeState.removeListener(_onThemeChanged);
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
      home: const SplashPage(),
    );
  }
}
