import 'package:flutter/material.dart';
import 'src/presentation/pages/splash/splash_page.dart';
import 'src/presentation/theme/app_theme.dart';
import 'src/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des dépendances
  await DependencyInjection.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pépites Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashPage(),
    );
  }
}
