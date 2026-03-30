// lib/core/theme/app_typography.dart
// خطوط محلية في assets/fonts/ — لا google_fonts
import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static const h1 = TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      height: 1.3,
      letterSpacing: -0.3);
  static const h2 = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.35,
      letterSpacing: -0.2);
  static const h3 = TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      height: 1.4);
  static const h4 = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4);
  static const bodyLg = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.6);
  static const bodyMd = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.6);
  static const bodySm = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5);
  static const labelLg = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      height: 1.3);
  static const labelMd = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.3);
  static const labelSm = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      height: 1.3);
  static const statHuge = TextStyle(
      fontSize: 38,
      fontWeight: FontWeight.w800,
      height: 1.1);
  static const statLg = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.1);
  static const numMd = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.3);
}
// ⚠️ لا تُضف color داخل TextStyle — مررها دائماً عبر: AppTypography.h2.copyWith(color: ...)