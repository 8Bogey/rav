import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/subscribers/subscribers_screen.dart';
import '../../features/cabinets/cabinets_screen.dart';
import '../../features/collection/collection_screen.dart';
import '../../features/workers/workers_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/whatsapp/whatsapp_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/audit/audit_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/layout/app_shell.dart';

/// Provider for GoRouter configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.login,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == AppRoutes.login;

      // If not authenticated and not on login page, redirect to login
      if (!isAuthenticated && !isLoginRoute) {
        return AppRoutes.login;
      }

      // If authenticated and on login page, redirect to dashboard
      if (isAuthenticated && isLoginRoute) {
        return AppRoutes.dashboard;
      }

      return null; // No redirect needed
    },
    routes: [
      // Login route (no shell)
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell route for authenticated screens
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: AppRoutes.dashboardName,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.subscribers,
            name: AppRoutes.subscribersName,
            builder: (context, state) => const SubscribersScreen(),
          ),
          GoRoute(
            path: AppRoutes.cabinets,
            name: AppRoutes.cabinetsName,
            builder: (context, state) => const CabinetsScreen(),
          ),
          GoRoute(
            path: AppRoutes.collection,
            name: AppRoutes.collectionName,
            builder: (context, state) => const CollectionScreen(),
          ),
          GoRoute(
            path: AppRoutes.workers,
            name: AppRoutes.workersName,
            builder: (context, state) => const WorkersScreen(),
          ),
          GoRoute(
            path: AppRoutes.reports,
            name: AppRoutes.reportsName,
            builder: (context, state) => const ReportsScreen(),
          ),
          GoRoute(
            path: AppRoutes.whatsapp,
            name: AppRoutes.whatsappName,
            builder: (context, state) => const WhatsappScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            name: AppRoutes.settingsName,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.audit,
            name: AppRoutes.auditName,
            builder: (context, state) => const AuditScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'الصفحة غير موجودة',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'حدث خطأ غير متوقع',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('العودة للرئيسية'),
            ),
          ],
        ),
      ),
    ),
  );
});
