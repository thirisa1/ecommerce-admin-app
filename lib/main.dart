import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/colors.dart';
import 'theme/theme_provider.dart';
import 'view/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const MonComptoirApp());
}

class MonComptoirApp extends StatefulWidget {
  const MonComptoirApp({super.key});

  @override
  State<MonComptoirApp> createState() => _MonComptoirAppState();
}

class _MonComptoirAppState extends State<MonComptoirApp> {

  void _onThemeChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // La ValueKey force Flutter à reconstruire
    // complètement HomePage quand le thème change,
    // ce qui fait relire tous les AppColors.xxx getters.
    final themeKey = ValueKey(themeProvider.isDark);

    return MaterialApp(
      title: 'MTS Médico-Dentaire',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.mode,

      // ── Thème Light ──
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: LightColors.background,
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE8EEF8),
      ),

      // ── Thème Dark ──
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: DarkColors.background,
        cardColor: const Color(0xFF161B27),
        dividerColor: const Color(0xFF1E2535),
      ),

      // ValueKey force la reconstruction complète
      // de l'arbre quand le thème bascule
      home: HomePage(key: themeKey),
    );
  }
}