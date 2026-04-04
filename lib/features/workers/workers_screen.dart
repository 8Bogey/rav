import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/features/workers/providers/workers_provider.dart'
    show WorkerPermissions, workersProvider;
import 'package:mawlid_al_dhaki/shared/widgets/common/screen_header.dart';
import 'package:mawlid_al_dhaki/shared/widgets/common/error_state_widget.dart';
import 'package:mawlid_al_dhaki/shared/widgets/common/empty_state_widget.dart';

class WorkersScreen extends ConsumerWidget {
  const WorkersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final workersState = ref.watch(workersProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            title: 'العمال',
            actionLabel: 'إضافة عامل',
            onActionPressed: () =>
                _showAddWorkerDialog(context, ref, isDarkMode),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24),

          // Loading state
          if (workersState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error state
          if (workersState.error != null && !workersState.isLoading)
            Expanded(
              child: ErrorStateWidget(
                message: 'حدث خطأ أثناء تحميل العمال',
                errorDetail: workersState.error,
                onRetry: () {
                  ref.read(workersProvider.notifier).loadWorkers();
                },
              ),
            ),

          // Empty state
          if (!workersState.isLoading &&
              workersState.error == null &&
              workersState.workers.isEmpty)
            const Expanded(
              child: EmptyStateWidget(
                icon: Icons.people_outline,
                title: 'لا يوجد عمال',
                subtitle: 'اضغط على زر "إضافة عامل" لإنشاء عامل جديد',
              ),
            ),

          // Success state with data
          if (!workersState.isLoading &&
              workersState.error == null &&
              workersState.workers.isNotEmpty)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: workersState.workers.length,
                itemBuilder: (ctx, index) {
                  final worker = workersState.workers[index];
                  return _buildWorkerCard(ctx, worker, index,
                      isDarkMode: isDarkMode, ref: ref);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showAddWorkerDialog(
      BuildContext context, WidgetRef ref, bool isDarkMode) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        title: Text(
          'إضافة عامل جديد',
          style: AppTypography.h3.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'اسم العامل',
                labelStyle: AppTypography.bodyMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
              style: AppTypography.bodyMd.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                labelStyle: AppTypography.bodyMd.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
              style: AppTypography.bodyMd.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: AppTypography.labelLg.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  phoneController.text.isNotEmpty) {
                await ref.read(workersProvider.notifier).addWorker(
                      name: nameController.text,
                      phone: phoneController.text,
                    );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
            ),
            child: Text(
              'إضافة',
              style: AppTypography.labelLg.copyWith(
                color: AppColors.textOnGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Parse permissions JSON and return Arabic labels for enabled permissions
  List<String> _parsePermissionsToArabic(String permissionsJson) {
    if (permissionsJson.isEmpty) return ['تحصيل'];

    // Map English permission keys to Arabic labels
    const Map<String, String> permissionMap = {
      'canCollect': 'تحصيل',
      'collection': 'تحصيل',
      'canAddSubscriber': 'إضافة مشترك',
      'addSubscriber': 'إضافة مشترك',
      'canEdit': 'تعديل بيانات',
      'editData': 'تعديل بيانات',
      'canViewReports': 'عرض التقارير',
      'viewReports': 'عرض التقارير',
      'canManageWorkers': 'إدارة العمال',
      'manageWorkers': 'إدارة العمال',
      'canSettings': 'الإعدادات',
      'settings': 'الإعدادات',
    };

    try {
      // Use dart:convert for proper JSON parsing
      final decoded = jsonDecode(permissionsJson);
      if (decoded is Map) {
        final List<String> labels = [];
        decoded.forEach((key, value) {
          final keyStr = key.toString();
          if (value == true && permissionMap.containsKey(keyStr)) {
            labels.add(permissionMap[keyStr]!);
          }
        });
        return labels.isEmpty ? ['تحصيل'] : labels;
      }
    } catch (e) {
      // Fallback
    }

    return ['تحصيل'];
  }

  Widget _buildWorkerCard(BuildContext context, Worker worker, int index,
      {required bool isDarkMode, required WidgetRef ref}) {
    // Parse permissions properly and get Arabic labels
    final permissionLabels = _parsePermissionsToArabic(worker.permissions);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Worker avatar and info
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: AppTypography.h3.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextHead
                              : AppColors.textHeading,
                        ),
                      ),
                      Text(
                        worker.phone,
                        style: AppTypography.bodySm.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextBody
                              : AppColors.textBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Permissions section
            Text(
              'الصلاحيات:',
              style: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: permissionLabels.map((permission) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    permission,
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Statistics
            Text(
              'المحصّل اليوم: ${worker.todayCollected.toStringAsFixed(0)} IQD',
              style: AppTypography.h4.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'إجمالي هذا الشهر: ${worker.monthTotal.toStringAsFixed(0)} IQD',
              style: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
            const Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Show edit permissions dialog
                      _showEditPermissionsDialog(
                          context, ref, isDarkMode, worker);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDarkMode
                            ? AppColors.darkBorder
                            : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'تعديل الصلاحيات',
                      style: AppTypography.labelLg.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.statusDangerS,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: AppColors.statusDanger,
                    ),
                    onPressed: () {
                      // Delete worker with confirmation
                      _showDeleteConfirmation(context, ref, worker);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: (index * 100).ms).fadeIn(duration: 400.ms);
  }

  void _showEditPermissionsDialog(
      BuildContext context, WidgetRef ref, bool isDarkMode, Worker worker) {
    // Parse existing permissions
    WorkerPermissions currentPermissions = const WorkerPermissions();
    try {
      final decoded = jsonDecode(worker.permissions);
      if (decoded is Map) {
        currentPermissions =
            WorkerPermissions.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      // Use default permissions if parsing fails
    }

    // Create local state for permissions
    bool canCollect = currentPermissions.collection;
    bool canAddSubscriber = currentPermissions.addSubscriber;
    bool canEditData = currentPermissions.editData;
    bool canViewReports = currentPermissions.viewReports;
    bool canManageWorkers = currentPermissions.manageWorkers;
    bool canSettings = currentPermissions.settings;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor:
              isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
          title: Text(
            'تعديل صلاحيات ${worker.name}',
            style: AppTypography.h3.copyWith(
              color:
                  isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPermissionCheckbox(
                  'تحصيل',
                  canCollect,
                  (value) => setState(() => canCollect = value ?? false),
                  isDarkMode,
                ),
                _buildPermissionCheckbox(
                  'إضافة مشترك',
                  canAddSubscriber,
                  (value) => setState(() => canAddSubscriber = value ?? false),
                  isDarkMode,
                ),
                _buildPermissionCheckbox(
                  'تعديل بيانات',
                  canEditData,
                  (value) => setState(() => canEditData = value ?? false),
                  isDarkMode,
                ),
                _buildPermissionCheckbox(
                  'عرض التقارير',
                  canViewReports,
                  (value) => setState(() => canViewReports = value ?? false),
                  isDarkMode,
                ),
                _buildPermissionCheckbox(
                  'إدارة العمال',
                  canManageWorkers,
                  (value) => setState(() => canManageWorkers = value ?? false),
                  isDarkMode,
                ),
                _buildPermissionCheckbox(
                  'الإعدادات',
                  canSettings,
                  (value) => setState(() => canSettings = value ?? false),
                  isDarkMode,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: AppTypography.labelLg.copyWith(
                  color:
                      isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPermissions = WorkerPermissions(
                  collection: canCollect,
                  addSubscriber: canAddSubscriber,
                  editData: canEditData,
                  viewReports: canViewReports,
                  manageWorkers: canManageWorkers,
                  settings: canSettings,
                );

                await ref.read(workersProvider.notifier).updatePermissions(
                      worker.id,
                      newPermissions,
                    );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
              ),
              child: Text(
                'حفظ',
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.textOnGold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCheckbox(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold,
            side: BorderSide(
              color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.bodyMd.copyWith(
              color:
                  isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, Worker worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف العامل'),
        content: Text('هل أنت متأكد من حذف ${worker.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(workersProvider.notifier).deleteWorker(worker.id);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDanger,
            ),
            child: Text('حذف'),
          ),
        ],
      ),
    );
  }
}
