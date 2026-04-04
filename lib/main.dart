import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/router/app_router.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/core/convex/convex_config.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/auth/auth_gate.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize desktop-specific features only on desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();

    final screen = await screenRetriever.getPrimaryDisplay();
    const w = 1200; // AppDimens.windowMinWidth from PRD
    const h = 720; // AppDimens.windowMinHeight from PRD
    final offsetX = (screen.size.width - w) / 2;
    final offsetY = (screen.size.height - h) / 2;

    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: Size(w.toDouble(), h.toDouble()),
        minimumSize: Size(w.toDouble(), h.toDouble()),
        center: false,
        title: 'Smart_gen',
        titleBarStyle: TitleBarStyle.hidden,
        backgroundColor: Colors.transparent,
      ),
      () async {
        await windowManager.setPosition(Offset(offsetX, offsetY));
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  // Initialize Convex client with deployment URL
  // Using the correct deployment URL from .env configuration
  const convexUrl = 'https://hearty-meadowlark-390.convex.cloud';

  try {
    await AppConvexConfig.initialize(convexUrl);
    debugPrint('Convex initialized with: $convexUrl');
  } catch (e) {
    debugPrint('Failed to initialize Convex: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Override database provider — sync is started by AuthGate when auth is ready
        databaseProvider.overrideWith((ref) {
          final database = AppDatabase();

          ref.onDispose(() {
            database.close();
          });

          return database;
        }),
      ],
      child: const AuthGate(child: AppRoot()),
    ),
  );
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Smart_gen',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ThemeData(
        primarySwatch: Colors.green,
        // Use default page transitions (removed glitch dependency)
        // Apply the color scheme from PRD
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        // Apply text theme from PRD
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 15),
          bodyMedium: TextStyle(fontSize: 13),
          bodySmall: TextStyle(fontSize: 12),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        // Apply dark color scheme from PRD
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.darkBgSidebar,
          brightness: Brightness.dark,
          primary: AppColors.primary,
        ),
        scaffoldBackgroundColor: AppColors.darkBgPage,
        cardColor: AppColors.darkBgSurface,
        // Apply text theme for dark mode
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextHead),
          headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkTextHead),
          headlineSmall: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextHead),
          titleMedium: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextHead),
          bodyLarge: TextStyle(fontSize: 15, color: AppColors.darkTextBody),
          bodyMedium: TextStyle(fontSize: 13, color: AppColors.darkTextBody),
          bodySmall: TextStyle(fontSize: 12, color: AppColors.darkTextMuted),
          labelLarge: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextBody),
          labelMedium: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextMuted),
        ),
      ),
      routerConfig: router,
    );
  }
}
