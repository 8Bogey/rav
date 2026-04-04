import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/database_provider.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/services/audit_log_service.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/core/auth/auth_provider.dart';
import 'package:mawlid_al_dhaki/shared/widgets/common/screen_header.dart';
import 'package:mawlid_al_dhaki/shared/widgets/common/error_state_widget.dart';

// Provider for AuditLogService
final auditLogServiceProvider = Provider((ref) {
  final database = ref.read(databaseProvider);
  final ownerId = ref.read(currentUserIdProvider) ?? '';
  return AuditLogService(database, ownerId: ownerId);
});

class AuditScreen extends ConsumerStatefulWidget {
  const AuditScreen({super.key});

  @override
  ConsumerState<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends ConsumerState<AuditScreen> {
  late Future<List<AuditLogEntry>> _auditFuture;

  @override
  void initState() {
    super.initState();
    _auditFuture = _loadAuditLogs();
  }

  Future<List<AuditLogEntry>> _loadAuditLogs() async {
    final auditLogService = ref.read(auditLogServiceProvider);
    return auditLogService.getAllAuditLogEntries();
  }

  void _retry() {
    setState(() {
      _auditFuture = _loadAuditLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return FutureBuilder<List<AuditLogEntry>>(
      future: _auditFuture,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: 'سجل التدقيق',
                  trailing: [
                    // Date filter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkBgSurface
                            : AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'فلتر بالتاريخ ▼',
                            style: AppTypography.labelLg.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextBody
                                  : AppColors.textBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Action filter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkBgSurface
                            : AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_alt,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'فلتر بالإجراء ▼',
                            style: AppTypography.labelLg.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextBody
                                  : AppColors.textBody,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Search bar
                    Container(
                      width: 200,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? AppColors.darkBgSurface
                            : AppColors.bgSurface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDarkMode
                              ? AppColors.darkBorder
                              : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'بحث...',
                            style: AppTypography.labelLg.copyWith(
                              color: isDarkMode
                                  ? AppColors.darkTextMuted
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 24),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          );
        }

        // Handle error state
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(title: 'سجل التدقيق'),
                const SizedBox(height: 24),
                Expanded(
                  child: ErrorStateWidget(
                    message: 'حدث خطأ أثناء تحميل سجل التدقيق',
                    errorDetail: snapshot.error.toString(),
                    onRetry: _retry,
                  ),
                ),
              ],
            ),
          );
        }

        // Handle empty state and success state
        final auditLogs = snapshot.data ?? [];
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDarkMode),
              const SizedBox(height: 24),

              // Timeline view - matching PRD requirements
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.darkBgSurface
                        : AppColors.bgSurface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 12,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: auditLogs.isNotEmpty ? auditLogs.length : 1,
                    itemBuilder: (context, index) {
                      if (auditLogs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment,
                                size: 64,
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد سجلات تدقيق',
                                style: AppTypography.h3.copyWith(
                                  color: isDarkMode
                                      ? AppColors.darkTextHead
                                      : AppColors.textHeading,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'سيتم إضافة السجلات هنا عند تنفيذ الإجراءات',
                                style: AppTypography.bodyMd.copyWith(
                                  color: isDarkMode
                                      ? AppColors.darkTextBody
                                      : AppColors.textBody,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final log = auditLogs[index];
                      return _buildTimelineItem(log, index,
                          isDarkMode: isDarkMode);
                    },
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'سجل التدقيق',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ).animate().fadeIn(duration: 300.ms),
        Row(
          children: [
            // Date filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'فلتر بالتاريخ ▼',
                    style: AppTypography.labelLg.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Action filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'فلتر بالإجراء ▼',
                    style: AppTypography.labelLg.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Search bar
            Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'بحث...',
                    style: AppTypography.labelLg.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextMuted
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
      ],
    );
  }

  Widget _buildTimelineItem(dynamic log, int index,
      {required bool isDarkMode}) {
    // Determine color based on log type
    Color color = AppColors.statusActive;
    String type = '';

    if (log is AuditLogEntry) {
      // Real audit log entry from database
      type = log.type;
      switch (log.type) {
        case 'دفعة':
          color = AppColors.statusActive;
          break;
        case 'تعديل':
          color = AppColors.statusInfo;
          break;
        case 'إضافة':
          color = AppColors.statusActive;
          break;
        case 'قطع':
          color = AppColors.statusDanger;
          break;
        default:
          color = AppColors.statusActive;
      }
    } else if (log is Map<String, dynamic>) {
      // Mock data
      color = log['color'];
      type = log['type'];
    }

    // Format time display
    String timeDisplay = '';
    if (log is AuditLogEntry) {
      timeDisplay =
          '${log.timestamp.hour}:${log.timestamp.minute.toString().padLeft(2, '0')}';
    } else if (log is Map<String, dynamic>) {
      timeDisplay = log['time'];
    }

    // Format user display
    String userDisplay = '';
    if (log is AuditLogEntry) {
      userDisplay = log.user;
    } else if (log is Map<String, dynamic>) {
      userDisplay = log['user'];
    }

    // Format action display
    String actionDisplay = '';
    if (log is AuditLogEntry) {
      actionDisplay = log.action;
    } else if (log is Map<String, dynamic>) {
      actionDisplay = log['action'];
    }

    // Format target display
    String targetDisplay = '';
    if (log is AuditLogEntry) {
      targetDisplay = log.target;
    } else if (log is Map<String, dynamic>) {
      targetDisplay = log['target'];
    }

    // Format details display
    String detailsDisplay = '';
    if (log is AuditLogEntry) {
      detailsDisplay = log.details;
    } else if (log is Map<String, dynamic>) {
      detailsDisplay = log['details'];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              // Only show connector line if not the last item
              // We'll use a fixed number for mock data
              if (index < 4)
                Container(
                  width: 2,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.darkBorder
                        : AppColors.borderLight,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Log details
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.darkBgSurfaceAlt
                    : AppColors.bgSurfaceAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '[$timeDisplay]',
                        style: AppTypography.bodySm.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type,
                          style: AppTypography.labelMd.copyWith(
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: userDisplay,
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextHead
                                : AppColors.textHeading,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: ' ← $actionDisplay ← ',
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextBody
                                : AppColors.textBody,
                          ),
                        ),
                        TextSpan(
                          text: targetDisplay,
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode
                                ? AppColors.darkTextHead
                                : AppColors.textHeading,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (detailsDisplay.isNotEmpty) const SizedBox(height: 4),
                  if (detailsDisplay.isNotEmpty)
                    Text(
                      detailsDisplay,
                      style: AppTypography.bodySm.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                ],
              ),
            ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms),
          ),
        ],
      ),
    );
  }
}
