import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/core/utils/format.dart';
import 'package:mawlid_al_dhaki/features/cabinets/providers/cabinets_provider.dart';
import 'package:mawlid_al_dhaki/features/subscribers/providers/subscribers_provider.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/router/route_names.dart';
import 'package:mawlid_al_dhaki/shared/widgets/common/screen_header.dart';
import 'package:mawlid_al_dhaki/shared/widgets/common/error_state_widget.dart';
import 'package:mawlid_al_dhaki/shared/widgets/common/empty_state_widget.dart';

class CabinetsScreen extends ConsumerStatefulWidget {
  const CabinetsScreen({super.key});

  @override
  ConsumerState<CabinetsScreen> createState() => _CabinetsScreenState();
}

class _CabinetsScreenState extends ConsumerState<CabinetsScreen> {
  // Track which cabinet is pending delete confirmation
  String? _pendingDeleteCabinetId;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final cabinetsState = ref.watch(cabinetsProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(
            title: 'الكابينات',
            actionLabel: 'إضافة كابينة',
            onActionPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const AddCabinetDialog(),
              );
              if (result == true) {
                ref.read(cabinetsProvider.notifier).loadCabinets();
              }
            },
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 24),

          // Loading state
          if (cabinetsState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error state
          if (cabinetsState.error != null && !cabinetsState.isLoading)
            Expanded(
              child: ErrorStateWidget(
                message: 'حدث خطأ أثناء تحميل الكابينات',
                errorDetail: cabinetsState.error,
                onRetry: () {
                  ref.read(cabinetsProvider.notifier).loadCabinets();
                },
              ),
            ),

          // Empty state
          if (!cabinetsState.isLoading &&
              cabinetsState.error == null &&
              cabinetsState.cabinets.isEmpty)
            const Expanded(
              child: EmptyStateWidget(
                icon: Icons.apps_outlined,
                title: 'لا توجد كابينات',
                subtitle: 'اضغط على زر "إضافة كابينة" لإنشاء كابينة جديدة',
              ),
            ),

          // Success state with data
          if (!cabinetsState.isLoading &&
              cabinetsState.error == null &&
              cabinetsState.cabinets.isNotEmpty)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: cabinetsState.cabinets.length,
                itemBuilder: (context, index) {
                  final cabinet = cabinetsState.cabinets[index];
                  return _buildCabinetCard(context, cabinet, index,
                      isDarkMode: isDarkMode, ref: ref);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCabinetCard(BuildContext context, Cabinet cabinet, int index,
      {required bool isDarkMode, required WidgetRef ref}) {
    // Calculate progress based on currentSubscribers and totalSubscribers
    double progress = 0.0;
    if (cabinet.totalSubscribers > 0) {
      progress = cabinet.currentSubscribers / cabinet.totalSubscribers;
    }

    // Determine color based on progress
    Color color = AppColors.statusActive;
    if (progress < 0.5) {
      color = AppColors.statusDanger;
    } else if (progress < 0.8) {
      color = AppColors.statusWarning;
    }

    // Format subscribers text
    final subscribersText =
        '${cabinet.currentSubscribers} / ${cabinet.totalSubscribers}';

    // Format collected amount with IQD formatting
    final collectedText = formatIQD(cabinet.collectedAmount);

    // Format delayed subscribers
    final delayedText = '${cabinet.delayedSubscribers} مشترك';

    // Check if this cabinet is pending delete confirmation
    final isPendingDelete = _pendingDeleteCabinetId == cabinet.id;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: isPendingDelete
            ? Border.all(color: AppColors.statusDanger, width: 2)
            : Border.all(
                color:
                    isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
              ),
        boxShadow: [
          BoxShadow(
            color: isPendingDelete
                ? AppColors.statusDanger.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: isPendingDelete ? 16 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabinet header with completion badge and actions
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cabinet letter circle
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          cabinet.letter.isNotEmpty
                              ? cabinet.letter[0].toUpperCase()
                              : (cabinet.name.isNotEmpty
                                  ? cabinet.name[0].toUpperCase()
                                  : '?'),
                          style: AppTypography.h3.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Action buttons
                    Row(
                      children: [
                        // Edit button
                        _buildActionButton(
                          icon: Icons.edit_outlined,
                          color: isDarkMode
                              ? AppColors.darkTextBody
                              : AppColors.textSecondary,
                          onTap: () => showDialog(
                            context: context,
                            builder: (context) =>
                                EditCabinetDialog(cabinet: cabinet),
                          ),
                          tooltip: 'تعديل',
                        ),
                        const SizedBox(width: 8),
                        // Delete button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isPendingDelete
                                ? AppColors.statusDanger
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _buildActionButton(
                            icon: isPendingDelete
                                ? Icons.check
                                : Icons.delete_outline,
                            color: isPendingDelete
                                ? Colors.white
                                : AppColors.statusDanger,
                            onTap: () =>
                                _handleDeleteTap(ref, cabinet.id.toString()),
                            tooltip: isPendingDelete ? 'تأكيد الحذف' : 'حذف',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Cabinet name
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'كابينة ${cabinet.name}',
                        style: AppTypography.labelLg.copyWith(
                          color: isDarkMode
                              ? AppColors.darkTextHead
                              : AppColors.textHeading,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (progress >= 1.0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: AppColors.textOnGold,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'مكتمل',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textOnGold,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Content area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Progress section
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? AppColors.darkBgSurfaceAlt.withOpacity(0.5)
                          : AppColors.bgSurfaceAlt.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المشتركون',
                              style: AppTypography.labelSm.copyWith(
                                color: isDarkMode
                                    ? AppColors.darkTextBody
                                    : AppColors.textBody,
                              ),
                            ),
                            Text(
                              subscribersText,
                              style: AppTypography.labelMd.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: isDarkMode
                                ? AppColors.darkBorder
                                : AppColors.borderLight,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Statistics - compact
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricTile(
                          label: 'المحصّل',
                          value: collectedText,
                          icon: Icons.attach_money,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildMetricTile(
                          label: 'المتأخرون',
                          value: delayedText,
                          icon: Icons.warning_amber_outlined,
                          valueColor: cabinet.delayedSubscribers > 0
                              ? AppColors.statusDanger
                              : null,
                          isDarkMode: isDarkMode,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _navigateToSubscribers(context, ref, cabinet.name);
                      },
                      icon: const Icon(Icons.arrow_forward, size: 14),
                      label: const Text('عرض المشتركين'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color.withValues(alpha: 0.1),
                        foregroundColor: color,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        minimumSize: const Size.fromHeight(28),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, curve: Curves.easeOutQuart);
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isDarkMode,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkBgSurfaceAlt.withValues(alpha: 0.65)
            : AppColors.bgSurfaceAlt.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isDarkMode
                    ? AppColors.darkTextBody
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextBody
                        : AppColors.textBody,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMd.copyWith(
              color: valueColor ??
                  (isDarkMode ? AppColors.darkTextHead : AppColors.textHeading),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }

  void _handleDeleteTap(WidgetRef ref, String cabinetId) {
    if (_pendingDeleteCabinetId == cabinetId) {
      // Confirm delete
      ref.read(cabinetsProvider.notifier).deleteCabinet(cabinetId);
      setState(() {
        _pendingDeleteCabinetId = null;
      });
    } else {
      // First click - show confirmation
      setState(() {
        _pendingDeleteCabinetId = cabinetId;
      });
    }
  }

  /// Calculate the next available cabinet letter (A, B, C, ... Z, AA, AB, ...)
  String _getNextCabinetLetter(List<String> existingNames) {
    // Extract single letters from existing cabinets (A, B, C, etc.)
    final Set<String> usedLetters = {};
    for (final name in existingNames) {
      if (name.isNotEmpty) {
        usedLetters.add(name.toUpperCase());
      }
    }

    // Generate letters: A-Z, then AA, AB, etc.
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

    // First check single letters A-Z
    for (int i = 0; i < letters.length; i++) {
      final letter = letters[i];
      if (!usedLetters.contains(letter)) {
        return letter;
      }
    }

    // If all A-Z are used, start with AA, AB, etc.
    for (int i = 0; i < letters.length; i++) {
      for (int j = 0; j < letters.length; j++) {
        final letter = '${letters[i]}${letters[j]}';
        if (!usedLetters.contains(letter)) {
          return letter;
        }
      }
    }

    // Fallback (shouldn't reach here)
    return 'A';
  }

  void _navigateToSubscribers(
      BuildContext context, WidgetRef ref, String cabinetName) {
    // Set the cabinet filter before navigating
    ref.read(selectedCabinetFilterProvider.notifier).state = cabinetName;

    // Navigate to subscribers screen
    context.go(AppRoutes.subscribers);
  }
}

class AddCabinetDialog extends ConsumerStatefulWidget {
  const AddCabinetDialog({super.key});

  @override
  ConsumerState<AddCabinetDialog> createState() => _AddCabinetDialogState();
}

class _AddCabinetDialogState extends ConsumerState<AddCabinetDialog> {
  late final TextEditingController nameController;
  late final TextEditingController letterController;

  @override
  void initState() {
    super.initState();
    final cabinetsState = ref.read(cabinetsProvider);
    final existingLetters =
        cabinetsState.cabinets.map((c) => c.letter).toList();
    final nextLetter = _getNextLetter(existingLetters);

    nameController = TextEditingController();
    letterController = TextEditingController(text: nextLetter);
  }

  String _getNextLetter(List<String> existingNames) {
    final Set<String> usedLetters = {};
    for (final name in existingNames) {
      if (name.isNotEmpty) {
        usedLetters.add(name.toUpperCase());
      }
    }
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int i = 0; i < letters.length; i++) {
      final letter = letters[i];
      if (!usedLetters.contains(letter)) return letter;
    }
    for (int i = 0; i < letters.length; i++) {
      for (int j = 0; j < letters.length; j++) {
        final letter = '${letters[i]}${letters[j]}';
        if (!usedLetters.contains(letter)) return letter;
      }
    }
    return 'A';
  }

  @override
  void dispose() {
    nameController.dispose();
    letterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    return AlertDialog(
      backgroundColor:
          isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
      title: Text(
        'إضافة كابينة جديدة',
        style: AppTypography.h3.copyWith(
          color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'اسم الكابينة',
              labelStyle: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
            style: AppTypography.bodyMd.copyWith(
              color:
                  isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: letterController,
            decoration: InputDecoration(
              labelText: 'حرف الكابينة',
              labelStyle: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
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
                letterController.text.trim().isNotEmpty) {
              await ref.read(cabinetsProvider.notifier).addCabinet(
                    name: nameController.text,
                    letter: letterController.text.trim().toUpperCase(),
                  );
              if (context.mounted) Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
          child: Text(
            'إضافة',
            style: AppTypography.labelLg.copyWith(color: AppColors.textOnGold),
          ),
        ),
      ],
    );
  }
}

class EditCabinetDialog extends ConsumerStatefulWidget {
  final Cabinet cabinet;
  const EditCabinetDialog({super.key, required this.cabinet});

  @override
  ConsumerState<EditCabinetDialog> createState() => _EditCabinetDialogState();
}

class _EditCabinetDialogState extends ConsumerState<EditCabinetDialog> {
  late final TextEditingController nameController;
  late final TextEditingController letterController;
  late final TextEditingController subscribersController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.cabinet.name);
    letterController = TextEditingController(text: widget.cabinet.letter);
    subscribersController =
        TextEditingController(text: widget.cabinet.totalSubscribers.toString());
  }

  @override
  void dispose() {
    nameController.dispose();
    letterController.dispose();
    subscribersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    return AlertDialog(
      backgroundColor:
          isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
      title: Text(
        'تعديل الكابينة',
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
              labelText: 'اسم الكابينة',
              labelStyle: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
            style: AppTypography.bodyMd.copyWith(
              color:
                  isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: letterController,
            decoration: InputDecoration(
              labelText: 'حرف الكابينة',
              labelStyle: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
              ),
            ),
            style: AppTypography.bodyMd.copyWith(
              color:
                  isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: subscribersController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'عدد المشتركين',
              labelStyle: AppTypography.bodyMd.copyWith(
                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
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
            if (nameController.text.isNotEmpty) {
              await ref.read(cabinetsProvider.notifier).updateCabinet(
                    widget.cabinet.copyWith(
                      name: nameController.text,
                      letter: letterController.text.trim().toUpperCase(),
                      totalSubscribers:
                          int.tryParse(subscribersController.text) ??
                              widget.cabinet.totalSubscribers,
                    ),
                  );
              if (context.mounted) Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          child: Text(
            'حفظ',
            style:
                AppTypography.labelLg.copyWith(color: AppColors.textOnPrimary),
          ),
        ),
      ],
    );
  }
}
