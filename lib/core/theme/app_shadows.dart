// lib/core/theme/app_shadows.dart
// Bitepoint: ظلال خفيفة جداً — لا ظلال ثقيلة
import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();
  
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 3)),
  ];
  
  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 32, offset: Offset(0, 8)),
  ];
  
  static const List<BoxShadow> cardHover = [
    BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x08000000), blurRadius: 20, offset: Offset(0, 6)),
  ];
  
  // Modal overlay
  static const List<BoxShadow> modal = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}