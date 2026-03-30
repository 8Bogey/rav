import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/features/workers/providers/workers_provider.dart';

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
          _buildHeader(context, isDarkMode, ref),
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
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 64,
                      color: AppColors.statusDanger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ أثناء تحميل العمال',
                      style: AppTypography.h3.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      workersState.error!,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(workersProvider.notifier).loadWorkers();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textOnPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: AppTypography.labelLg.copyWith(
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Empty state
          if (!workersState.isLoading &&
              workersState.error == null &&
              workersState.workers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: isDarkMode
                          ? AppColors.darkTextBody
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد عمال',
                      style: AppTypography.h3.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextHead
                            : AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'اضغط على زر "إضافة عامل" لإنشاء عامل جديد',
                      style: AppTypography.bodyMd.copyWith(
                        color: isDarkMode
                            ? AppColors.darkTextBody
                            : AppColors.textBody,
                      ),
                    ),
                  ],
                ),
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

  Widget _buildHeader(BuildContext context, bool isDarkMode, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'العمال',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ).animate().fadeIn(duration: 300.ms),
        GestureDetector(
          onTap: () => _showAddWorkerDialog(context, ref, isDarkMode),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.add,
                  color: AppColors.textOnGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'إضافة عامل',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.textOnGold,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate(delay: 100.ms)
            .scaleXY(begin: 0.95, end: 1.0, duration: 400.ms),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
  
  void _showAddWorkerDialog(BuildContext context, WidgetRef ref, bool isDarkMode) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
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
                  color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
              style: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                labelStyle: AppTypography.bodyMd.copyWith(
                  color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                ),
              ),
              style: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
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
              if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
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
                      _showEditPermissionsDialog(context, ref, isDarkMode, worker);
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
  
  void _showEditPermissionsDialog(BuildContext context, WidgetRef ref, bool isDarkMode, Worker worker) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        title: Text(
          'تعديل صلاحيات ${worker.name}',
          style: AppTypography.h3.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ),
        content: Text(
          'سيتم إضافة صلاحيات العامل قريباً',
          style: AppTypography.bodyMd.copyWith(
            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Worker worker) {
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
