import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/scan_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/result_screen.dart';
import 'screens/pdf_preview_screen.dart';
import 'screens/settings_screen.dart';

class DocScanApp extends StatelessWidget {
  const DocScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScanProvider>();

    return MaterialApp(
      title: 'DocScan AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/preview': (context) => const PreviewScreen(),
        '/processing': (context) => const ProcessingScreen(),
        '/result': (context) => const ResultScreen(),
        '/pdfPreview': (context) => const PdfPreviewScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
