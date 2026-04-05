// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Primary (Sidebar + Hero Cards) ---
  // Major palette (2 colors only):
  // Blue:  #2573B8
  // Red:   #E32937
  static const Color primary = Color(0xFF2573B8); // Blue accent across the app
  static const Color primaryLight = Color(0xFF4A8FCF);
  static const Color primaryMid = Color(0xFF6CA4DC);
  static const Color primarySurface =
      Color(0xFFD8ECFF); // soft hover/background
  static const Color primaryBorder = Color(0xFFB8D8F3);

  // --- Gold / CTA (Bitepoint pill نشط + أزرار رئيسية) ---
  static const Color gold = Color(0xFFE32937); // Red CTA / active emphasis
  static const Color goldDark = Color(0xFFC71E2A);
  static const Color goldLight = Color(0xFFFFD6D8);

  // --- Page & Surface ---
  static const Color bgPage =
      Color(0xFFF5F5E8); // خلفية الصفحة (كريمي دافئ Bitepoint)
  static const Color bgSurface = Color(0xFFFFFFFF); // بطاقات + sidebar
  static const Color bgSurfaceAlt = Color(0xFFF8F8F4); // صفوف جدول بديلة
  static const Color bgSidebar = Color(0xFF0B2D4A); // Deep blue sidebar

  // --- Borders ---
  static const Color borderLight = Color(0xFFE7EDF5);
  static const Color borderMid = Color(0xFFD2E2F2);

  // --- Text ---
  static const Color textHeading = Color(0xFF111111);
  static const Color textBody = Color(0xFF374151);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnPrimary =
      Color(0xFFFFFFFF); // نص على sidebar + بطاقة خضراء
  static const Color textOnGold = Color(0xFFFFFFFF); // نص على pill ذهبي

  // --- Status ---
  static const Color statusActive = primary;
  static const Color statusActiveS = Color(0xFFD8ECFF);
  static const Color statusWarning = gold;
  static const Color statusWarningS = goldLight;
  static const Color statusDanger = gold;
  static const Color statusDangerS = goldLight;
  static const Color statusInfo = primary;
  static const Color statusInfoS = Color(0xFFD8ECFF);
  static const Color statusOrange = gold;
  static const Color statusOrangeS = goldLight;

  // --- Dark Mode ---
  static const Color darkBgPage = Color(0xFF0D1117);
  static const Color darkBgSurface = Color(0xFF161B22);
  static const Color darkBgSurfaceAlt = Color(0xFF1C2128);
  static const Color darkBgSidebar = Color(0xFF081F33);
  static const Color darkBorder = Color(0xFF2B3B4F);
  static const Color darkTextHead = Color(0xFFF0F6FC);
  static const Color darkTextBody = Color(0xFFCDD9E5);
  static const Color darkTextMuted = Color(0xFF768390);

  // ═══════════════════════════════════════════════════════════════
  // CODDY.TECH STOCK COLORS (Single Theme - No Dark/Light Mode)
  // Extracted from cody.png - coddy.tech login page
  // ═══════════════════════════════════════════════════════════════

  // ── Primary Colors ─────────────────────────────────────────────
  static const Color coddyStockPrimary = Color(0xFF1B78A0); // Teal button
  static const Color coddyStockPrimaryDarker = Color(0xFF145A78); // Button shadow
  static const Color coddyStockLink = Color(0xFF34B4E4); // Links, accents

  // ── Background Colors ──────────────────────────────────────────
  static const Color coddyStockBgPage = Color(0xFF252627); // Page background
  static const Color coddyStockBgCard = Color(0xFF2D2E2F); // Card background
  static const Color coddyStockBgInput = Color(0xFF252627); // Input background

  // ── Text Colors ────────────────────────────────────────────────
  static const Color coddyStockTextPrimary = Color(0xDEFFFFFF); // 87% white
  static const Color coddyStockTextSecondary = Color(0x99FFFFFF); // 60% white
  static const Color coddyStockTextDisabled = Color(0x4DFFFFFF); // 30% white

  // ── Border Colors ──────────────────────────────────────────────
  static const Color coddyStockBorder = Color(0xFF3B3E41); // Input borders
  static const Color coddyStockBorderMid = Color(0xFF494D50); // Button borders

  // ── Semantic Colors ────────────────────────────────────────────
  static const Color coddyStockError = Color(0xFFA90404); // Error states
  static const Color coddyStockSuccess = Color(0xFF00AB72); // Success states
}
