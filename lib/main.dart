import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/app_router.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_colors.dart';
import 'core/helpers/logger_helper.dart';

void main() async {
  // Ensure Flutter engine is initialized before Hive setup
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Hive Service (seeds dummy data if empty)
  await HiveService.instance.init();

  runApp(
    const ProviderScope(
      child: DatingAppApp(),
    ),
  );
}

class DatingAppApp extends StatelessWidget {
  const DatingAppApp({super.key});

  @override
  Widget build(BuildContext context) {
    Logger.info('Launching Premium DatingApp App...', 'Main');
    
    return MaterialApp.router(
      title: 'DatingApp Premium',
      debugShowCheckedModeBanner: false,
      
      // Setup GoRouter
      routerConfig: appRouter,
      
      // Global Theme Definition using the Semantic Color Palette
      themeMode: ThemeMode.dark, // Deep dark luxury mode
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.card,
        dividerColor: AppColors.divider,
        
        // Define Custom Color Scheme based on AppColors
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),

        // Navigation bar themes
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
        
        // Cupertino text selection theme matching iOS
        cupertinoOverrideTheme: const CupertinoThemeData(
          primaryColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
