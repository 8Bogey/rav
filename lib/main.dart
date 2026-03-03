import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/features/auth/login_screen.dart';
import 'package:mawlid_al_dhaki/features/subscribers/subscribers_screen.dart';
import 'package:mawlid_al_dhaki/shared/widgets/layout/app_shell.dart';
import 'package:mawlid_al_dhaki/features/dashboard/dashboard_screen.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final screen = await screenRetriever.getPrimaryDisplay();
  const w = 1200; // AppDimens.windowMinWidth from PRD
  const h = 720; // AppDimens.windowMinHeight from PRD
  final offsetX = (screen!.size.width - w) / 2;
  final offsetY = (screen!.size.height - h) / 2;

  await windowManager.waitUntilReadyToShow(
    WindowOptions(
      size: Size(w.toDouble(), h.toDouble()),
      minimumSize: Size(w.toDouble(), h.toDouble()),
      center: false,
      title: 'المولد الذكي',
      titleBarStyle: TitleBarStyle.hidden,
      backgroundColor: Colors.transparent,
    ),
    () async {
      await windowManager.setPosition(Offset(offsetX, offsetY));
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(const ProviderScope(child: AppRoot()));
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'المولد الذكي',
      theme: ThemeData(
        primarySwatch: Colors.green,
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
      home: const LoginScreen(),
      routes: {
        '/dashboard': (context) => const AppShell(
              title: 'لوحة التحكم',
              child: DashboardScreen(),
            ),
        '/subscribers': (context) => const AppShell(
              title: 'المشتركون',
              child: SubscribersScreen(),
            ),
      },
    );
  }
}
