import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mawlid_al_dhaki/core/database/app_database.dart';
import 'package:mawlid_al_dhaki/core/theme/app_colors.dart';
import 'package:mawlid_al_dhaki/core/theme/app_typography.dart';
import 'package:mawlid_al_dhaki/core/theme/theme_provider.dart';
import 'package:mawlid_al_dhaki/core/services/service_providers.dart';
import 'package:mawlid_al_dhaki/core/auth/auth_provider.dart';



class WhatsappScreen extends ConsumerWidget {
  const WhatsappScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final whatsappService = ref.watch(whatsappServiceProvider);
    final ownerId = ref.watch(currentUserIdProvider) ?? '';
    
    return FutureBuilder(
      future: Future.wait([
        whatsappService.getAllTemplates(ownerId: ownerId),
        whatsappService.getSubscribersCount(ownerId: ownerId),
        whatsappService.getMessagesLog(),
      ]),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isDarkMode),
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
                _buildHeader(isDarkMode),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          size: 64,
                          color: AppColors.statusDanger,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ أثناء تحميل بيانات واتساب',
                          style: AppTypography.h3.copyWith(
                            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: AppTypography.bodyMd.copyWith(
                            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Retry loading
                            (context as Element).markNeedsBuild();
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
              ],
            ),
          );
        }
        
        // Extract data from snapshot
        final data = snapshot.data as List<dynamic>;
        final templates = data[0] as List<dynamic>;
        final subscribersCount = data[1] as int;
        final messagesLog = data[2] as List<Map<String, dynamic>>;
        
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and actions - matching Bitepoint style
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'واتساب',
                    style: AppTypography.h2.copyWith(
                      color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                    ),
                  ).animate().fadeIn(duration: 300.ms),
                  Container(
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
                          Icons.send,
                          color: AppColors.textOnGold,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'إرسال رسالة',
                          style: AppTypography.labelLg.copyWith(
                            color: AppColors.textOnGold,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: 100.ms).scaleXY(begin: 0.95, end: 1.0, duration: 400.ms),
                ],
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 24),

              // Three-column layout - matching PRD requirements
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Templates column
                    _buildTemplatesColumn(templates, isDarkMode: isDarkMode),
                    const SizedBox(width: 16),
                    // Message editor column
                    _buildEditorColumn(context, subscribersCount, isDarkMode: isDarkMode),
                    const SizedBox(width: 16),
                    // Send log column
                    _buildLogColumn(messagesLog, isDarkMode: isDarkMode),
                  ],
                ),
              ),
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
          'واتساب',
          style: AppTypography.h2.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
        ).animate().fadeIn(duration: 300.ms),
        Container(
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
                Icons.send,
                color: AppColors.textOnGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'إرسال رسالة',
                style: AppTypography.labelLg.copyWith(
                  color: AppColors.textOnGold,
                ),
              ),
            ],
          ),
        ).animate(delay: 100.ms).scaleXY(begin: 0.95, end: 1.0, duration: 400.ms),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTemplatesColumn(List<dynamic> templates, {required bool isDarkMode}) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Column header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'القوالب',
                    style: AppTypography.h3.copyWith(
                      color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // Add new template
                    },
                  ),
                ],
              ),
            ),
            // Templates list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: template.isActive 
                          ? AppColors.primary.withOpacity(0.1) 
                          : (isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: template.isActive 
                            ? AppColors.primary 
                            : (isDarkMode ? AppColors.darkBorder : AppColors.borderLight),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.title,
                          style: AppTypography.bodyMd.copyWith(
                            color: template.isActive 
                                ? AppColors.primary 
                                : (isDarkMode ? AppColors.darkTextHead : AppColors.textHeading),
                            fontWeight: template.isActive ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          template.content,
                          style: AppTypography.bodySm.copyWith(
                            color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms);
                },
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildEditorColumn(BuildContext context, int subscribersCount, {required bool isDarkMode}) {
    return Expanded(
      flex: 2,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Column header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Text(
                'محرر الرسالة',
                style: AppTypography.h3.copyWith(
                  color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                ),
              ),
            ),
            // Message editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Text area
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                          ),
                        ),
                        child: const TextField(
                          maxLines: null,
                          expands: true,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالتك...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Recipients selector
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.group),
                          const SizedBox(width: 8),
                          Text(
                            'اختر المجموعة ▼',
                            style: AppTypography.bodyMd.copyWith(
                              color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$subscribersCount مشترك',
                              style: AppTypography.labelMd.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Send buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Send to all subscribers
                              _sendToAll(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.textOnGold,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'إرسال للجميع',
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.textOnGold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Send to selected subscribers
                              _sendToSelected(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDarkMode ? AppColors.darkBorder : AppColors.borderLight,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'إرسال للمختارين',
                              style: AppTypography.labelLg.copyWith(
                                color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildLogColumn(List<Map<String, dynamic>> messagesLog, {required bool isDarkMode}) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Column header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.darkBgSurfaceAlt : AppColors.bgSurfaceAlt,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Text(
                'سجل الإرسال',
                style: AppTypography.h3.copyWith(
                  color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
                ),
              ),
            ),
            // Log entries
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messagesLog.length,
                itemBuilder: (context, index) {
                  final logEntry = messagesLog[index];
                  final isSuccess = logEntry['isSuccess'] as bool;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSuccess 
                          ? AppColors.statusActiveS 
                          : AppColors.statusDangerS,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSuccess ? Icons.check_circle : Icons.error,
                          color: isSuccess ? AppColors.statusActive : AppColors.statusDanger,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                logEntry['subscriberName'] as String,
                                style: AppTypography.bodyMd.copyWith(
                                  color: isSuccess 
                                      ? AppColors.statusActive 
                                      : AppColors.statusDanger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                logEntry['message'] as String,
                                style: AppTypography.bodySm.copyWith(
                                  color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          logEntry['time'] as String,
                          style: AppTypography.bodySm.copyWith(
                            color: isDarkMode ? AppColors.darkTextMuted : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: (index * 30).ms).fadeIn(duration: 200.ms);
                },
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }
  
  void _sendToAll(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري الإرسال للجميع...')),
    );
  }
  
  void _sendToSelected(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري الإرسال للمختارين...')),
    );
  }
}