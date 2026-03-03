// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Primary (Sidebar + Hero Cards) ---
  static const Color primary        = Color(0xFF1B4332); // Sidebar BG + بطاقة إحصاء رئيسية
  static const Color primaryLight   = Color(0xFF2D6A4F);
  static const Color primaryMid     = Color(0xFF52B788);
  static const Color primarySurface = Color(0xFFD8F3DC); // hover خفيف على nav item
  static const Color primaryBorder  = Color(0xFFB7E4C7);

  // --- Gold / CTA (Bitepoint pill نشط + أزرار رئيسية) ---
  static const Color gold           = Color(0xFFF5A623); // nav active pill + CTA buttons
  static const Color goldDark       = Color(0xFFD4891A); // hover على gold
  static const Color goldLight      = Color(0xFFFFF3CD); // خلفية badge ذهبي

  // --- Page & Surface ---
  static const Color bgPage         = Color(0xFFF5F5E8); // خلفية الصفحة (كريمي دافئ Bitepoint)
  static const Color bgSurface      = Color(0xFFFFFFFF); // بطاقات + sidebar
  static const Color bgSurfaceAlt   = Color(0xFFF8F8F4); // صفوف جدول بديلة
  static const Color bgSidebar      = Color(0xFF1B4332); // Sidebar أخضر داكن (Athena style)

  // --- Borders ---
  static const Color borderLight    = Color(0xFFEAEAE4);
  static const Color borderMid      = Color(0xFFD4D4CC);

  // --- Text ---
  static const Color textHeading    = Color(0xFF111111);
  static const Color textBody       = Color(0xFF374151);
  static const Color textSecondary  = Color(0xFF6B7280);
  static const Color textMuted      = Color(0xFF9CA3AF);
  static const Color textOnPrimary  = Color(0xFFFFFFFF); // نص على sidebar + بطاقة خضراء
  static const Color textOnGold     = Color(0xFFFFFFFF); // نص على pill ذهبي

  // --- Status ---
  static const Color statusActive   = Color(0xFF16A34A);
  static const Color statusActiveS  = Color(0xFFDCFCE7);
  static const Color statusWarning  = Color(0xFFD97706);
  static const Color statusWarningS = Color(0xFFFEF3C7);
  static const Color statusDanger   = Color(0xFFDC2626);
  static const Color statusDangerS  = Color(0xFFFEE2E2);
  static const Color statusInfo     = Color(0xFF2563EB);
  static const Color statusInfoS    = Color(0xFFDBEAFE);
  static const Color statusOrange   = Color(0xFFEA580C);
  static const Color statusOrangeS  = Color(0xFFFFEDD5);

  // --- Dark Mode ---
  static const Color darkBgPage       = Color(0xFF0D1117);
  static const Color darkBgSurface    = Color(0xFF161B22);
  static const Color darkBgSurfaceAlt = Color(0xFF1C2128);
  static const Color darkBgSidebar    = Color(0xFF0A1F14); // أخضر داكن جداً للـ Dark Mode
  static const Color darkBorder       = Color(0xFF30363D);
  static const Color darkTextHead     = Color(0xFFF0F6FC);
  static const Color darkTextBody     = Color(0xFFCDD9E5);
  static const Color darkTextMuted    = Color(0xFF768390);
}