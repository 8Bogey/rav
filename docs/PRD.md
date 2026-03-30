# PRD — المولد الذكي (Smart Generator Manager)

نظام إدارة مشتركي مولدات الكهرباء على Windows Desktop (Flutter/RTL).  
يُدير المشتركين، الكابينات، التحصيل الشهري، العمال، التقارير، وإرسال واتساب.

> **للمنفّذ:** نمط التصميم المعتمد هو **Bitepoint POS** (الصور المرجعية مرفقة).  
> الـ Sidebar يعتمد لون Athena الأخضر الداكن `#1B4332` مع nav item نشط بـ pill ذهبي `#F5A623`.  
> يجب تطبيق هذه القواعد بدقة على كل شاشة دون استثناء.

---

## 1. Design System

### 1.1 Color Tokens

```dart
// lib/core/theme/app_colors.dart
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
```

### 1.2 Typography

```dart
// lib/core/theme/app_typography.dart
// خطوط محلية في assets/fonts/ — لا google_fonts
class AppTypography {
  AppTypography._();
  static const String _cairo  = 'Cairo';
  static const String _nunito = 'Nunito';

  static const h1       = TextStyle(fontFamily: _cairo,  fontSize: 26, fontWeight: FontWeight.w700, height: 1.3,  letterSpacing: -0.3);
  static const h2       = TextStyle(fontFamily: _cairo,  fontSize: 20, fontWeight: FontWeight.w700, height: 1.35, letterSpacing: -0.2);
  static const h3       = TextStyle(fontFamily: _cairo,  fontSize: 17, fontWeight: FontWeight.w600, height: 1.4);
  static const h4       = TextStyle(fontFamily: _cairo,  fontSize: 15, fontWeight: FontWeight.w600, height: 1.4);
  static const bodyLg   = TextStyle(fontFamily: _cairo,  fontSize: 15, fontWeight: FontWeight.w400, height: 1.6);
  static const bodyMd   = TextStyle(fontFamily: _cairo,  fontSize: 13, fontWeight: FontWeight.w400, height: 1.6);
  static const bodySm   = TextStyle(fontFamily: _cairo,  fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const labelLg  = TextStyle(fontFamily: _cairo,  fontSize: 13, fontWeight: FontWeight.w600, height: 1.3);
  static const labelMd  = TextStyle(fontFamily: _cairo,  fontSize: 11, fontWeight: FontWeight.w600, height: 1.3);
  static const statHuge = TextStyle(fontFamily: _nunito, fontSize: 38, fontWeight: FontWeight.w800, height: 1.1);
  static const statLg   = TextStyle(fontFamily: _nunito, fontSize: 28, fontWeight: FontWeight.w700, height: 1.1);
  static const numMd    = TextStyle(fontFamily: _nunito, fontSize: 14, fontWeight: FontWeight.w600, height: 1.3);
}
// ⚠️ لا تُضف color داخل TextStyle — مررها دائماً عبر: AppTypography.h2.copyWith(color: ...)
```

### 1.3 Dimensions

```dart
// lib/core/theme/app_dimens.dart
class AppDimens {
  AppDimens._();
  // 8px Grid
  static const double s4=4, s6=6, s8=8, s10=10, s12=12, s16=16,
                      s20=20, s24=24, s28=28, s32=32, s40=40, s48=48, s64=64;
  // Border Radius
  static const double rXs=4, rSm=6, rMd=10, rLg=14, rXl=20, rFull=999;
  // Layout — RTL: Sidebar على اليمين
  static const double sidebarWidth=220, sidebarCollapsed=62, topBarHeight=56;
  static const double contentPaddingH=24, contentPaddingV=20;
  static const double cardPadding=20, cardGap=16;
  static const double iconNav=20, iconSm=16, iconMd=20, iconLg=24;
  static const double avatarSm=32, avatarMd=36, avatarLg=48;
  static const double windowMinWidth=1200, windowMinHeight=720;
}
```

### 1.4 Shadows

```dart
// lib/core/theme/app_shadows.dart
// Bitepoint: ظلال خفيفة جداً — لا ظلال ثقيلة
class AppShadows {
  AppShadows._();
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4,  offset: Offset(0, 1)),
    BoxShadow(color: Color(0x06000000), blurRadius: 12, offset: Offset(0, 3)),
  ];
  static const List<BoxShadow> elevated = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 32, offset: Offset(0, 8)),
  ];
  static const List<BoxShadow> cardHover = [
    BoxShadow(color: Color(0x12000000), blurRadius: 8,  offset: Offset(0, 2)),
    BoxShadow(color: Color(0x08000000), blurRadius: 20, offset: Offset(0, 6)),
  ];
  // Modal overlay
  static const List<BoxShadow> modal = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 24, offset: Offset(0, 8)),
  ];
}
```

---

## 2. pubspec.yaml

```yaml
name: mawlid_al_dhaki
description: "المولد الذكي — نظام إدارة مشتركي مولدات الكهرباء"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'
  flutter: ">=3.22.0"

flutter:
  uses-material-design: true
  assets:
    - assets/fonts/
    - assets/icons/
    - assets/rive/
    - assets/images/
    - assets/sounds/
  fonts:
    - family: Cairo
      fonts:
        - asset: assets/fonts/Cairo-Regular.ttf
          weight: 400
        - asset: assets/fonts/Cairo-Medium.ttf
          weight: 500
        - asset: assets/fonts/Cairo-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Cairo-Bold.ttf
          weight: 700
        - asset: assets/fonts/Cairo-ExtraBold.ttf
          weight: 800
    - family: Nunito
      fonts:
        - asset: assets/fonts/Nunito-Regular.ttf
          weight: 400
        - asset: assets/fonts/Nunito-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Nunito-Bold.ttf
          weight: 700
        - asset: assets/fonts/Nunito-ExtraBold.ttf
          weight: 800

dependencies:
  flutter:
    sdk: flutter

  # ── State Management ──────────────────────────────────────────
  flutter_riverpod: ^2.6.1       # ✅ إدارة الحالة الرئيسية
  riverpod_annotation: ^2.3.5    # ✅ code generation لـ Riverpod
  freezed_annotation: ^2.4.4     # ✅ immutable models

  # ── Navigation ────────────────────────────────────────────────
  go_router: ^14.2.7             # ✅ التنقل بين الشاشات

  # ── Database ──────────────────────────────────────────────────
  drift: ^2.18.0                 # ✅ قاعدة البيانات المحلية (أفضل من Isar المهجور)
  drift_flutter: ^0.1.0
  sqlite3_flutter_libs: ^0.5.24

  # ── Cloud Sync ────────────────────────────────────────────────
  supabase_flutter: ^2.8.0       # ✅ مزامنة سحابية

  # ── Icons & SVG ───────────────────────────────────────────────
  phosphor_flutter: ^2.1.0       # ✅ أيقونات Outlined رفيقة 20px (مطابق Bitepoint)
  flutter_svg: ^2.0.10+1         # ✅ شعار التطبيق + أيقونات SVG

  # ── Animations ────────────────────────────────────────────────
  flutter_animate: ^4.5.0        # ✅ micro-animations + sequential entry (Bitepoint style)
  rive: ^0.13.20                 # 🔄 بديل Lottie — 60 FPS مقابل 17 FPS، حجم أصغر 10-15×
  confetti: ^0.7.0               # ✅ احتفال اكتمال الكابينة

  # ── Layout ────────────────────────────────────────────────────
  gap: ^3.0.1                    # ✅ مسافات نظيفة

  # ── Visual Effects ────────────────────────────────────────────
  flutter_acrylic: ^1.1.4        # 🆕 تأثير Mica/Acrylic حقيقي من Windows 11
  figma_squircle: ^0.5.3         # 🔄 بديل smooth_corner — squircle دقيق مطابق Figma

  # ── Desktop DataGrid ──────────────────────────────────────────
  pluto_grid_plus: ^8.4.0        # 🆕 جدول Desktop احترافي — keyboard navigation + sort + sticky headers
  # data_table_2: ^2.5.14        # بديل أخف إذا لم تحتج pluto_grid

  # ── Desktop UX ────────────────────────────────────────────────
  context_menus: ^2.0.0          # ✅ right-click context menu
  super_tooltip: ^2.0.4          # ✅ tooltips متقدمة

  # ── Loading ───────────────────────────────────────────────────
  shimmer: ^3.0.0                # ✅ skeleton loading

  # ── Charts ────────────────────────────────────────────────────
  fl_chart: ^0.68.0              # ✅ PieChart + BarChart + LineChart

  # ── Toasts ────────────────────────────────────────────────────
  toastification: ^2.1.0         # ✅ toast احترافي مع queue management

  # ── Images ────────────────────────────────────────────────────
  cached_network_image: ^3.3.1   # ✅ تحميل وكاش الصور

  # ── Window Management ─────────────────────────────────────────
  window_manager: ^0.4.2         # ✅ إدارة نافذة Windows
  screen_retriever: ^0.1.9       # ✅ معلومات الشاشة للتمركز

  # ── Print / PDF ───────────────────────────────────────────────
  pdf: ^3.11.0                   # ✅ توليد PDF للتقارير
  printing: ^5.13.1              # ✅ طباعة PDF
  esc_pos_utils_plus: ^2.0.4     # ✅ طباعة إيصالات ESC/POS
  flutter_thermal_printer: ^0.3.2 # ✅ طابعة حرارية

  # ── Files ─────────────────────────────────────────────────────
  path_provider: ^2.1.4          # ✅ مسارات الملفات
  open_file: ^3.3.2              # ✅ فتح ملفات PDF
  process_run: ^1.1.1            # ✅ تشغيل Node.js (WhatsApp bridge)

  # ── Logging & Debugging ───────────────────────────────────────
  talker_flutter: ^4.4.1         # 🆕 logging احترافي + UI viewer + Riverpod integration
  # يدعم: Riverpod logs، crash reports، history، share logs

  # ── Utils ─────────────────────────────────────────────────────
  intl: ^0.19.0                  # ✅ تنسيق التواريخ والأرقام العربية
  shared_preferences: ^2.3.2     # ✅ إعدادات محلية
  package_info_plus: ^8.0.2      # ✅ معلومات التطبيق
  uuid: ^4.4.2                   # ✅ توليد UUIDs
  collection: ^1.18.0            # ✅ عمليات Lists/Maps
  rxdart: ^0.28.0                # ✅ search debounce 300ms

  # ── Audio ─────────────────────────────────────────────────────
  audioplayers: ^6.1.0           # ✅ أصوات النجاح والتنبيه

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.11
  drift_dev: ^2.18.0
  riverpod_generator: ^2.4.3
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  flutter_lints: ^4.0.0
  custom_lint: ^0.6.7
  riverpod_lint: ^2.3.13
```

### Assets المطلوبة

```
assets/
├── fonts/         Cairo-*.ttf (400,500,600,700,800) + Nunito-*.ttf
├── icons/         SVG مخصصة (شعار التطبيق ⚡)
├── rive/                        # 🔄 بديل lottie/ — أداء GPU أفضل، حجم أصغر
│   ├── empty_subscribers.riv
│   ├── empty_collection.riv
│   ├── loading_pulse.riv
│   ├── celebration_confetti.riv
│   ├── success_check.riv
│   └── sync_cloud.riv
└── sounds/
    ├── payment_success.mp3
    ├── cabinet_complete.mp3
    ├── warning_alert.mp3
    └── error.mp3
```

---

## 3. Project Structure

```
mawlid_al_dhaki/
├── assets/
├── node/
│   ├── package.json
│   └── whatsapp_bridge.js
└── lib/
    ├── main.dart
    ├── app.dart
    ├── core/
    │   ├── theme/
    │   │   ├── app_colors.dart
    │   │   ├── app_typography.dart
    │   │   ├── app_dimens.dart
    │   │   ├── app_shadows.dart
    │   │   └── app_theme.dart
    │   ├── router/
    │   │   ├── app_router.dart
    │   │   └── route_names.dart
    │   ├── database/
    │   │   ├── app_database.dart
    │   │   ├── tables/
    │   │   │   ├── subscribers_table.dart
    │   │   │   ├── cabinets_table.dart
    │   │   │   ├── payments_table.dart
    │   │   │   ├── workers_table.dart
    │   │   │   └── audit_log_table.dart
    │   │   └── daos/
    │   │       ├── subscribers_dao.dart
    │   │       ├── payments_dao.dart
    │   │       └── audit_dao.dart
    │   ├── sync/
    │   │   ├── sync_service.dart
    │   │   └── conflict_resolver.dart
    │   └── services/
    │       ├── print_service.dart
    │       ├── audio_service.dart
    │       ├── whatsapp_service.dart
    │       └── update_service.dart
    ├── shared/widgets/
    │   ├── layout/
    │   │   ├── app_shell.dart
    │   │   ├── app_sidebar.dart
    │   │   ├── app_topbar.dart
    │   │   └── app_custom_titlebar.dart
    │   ├── data_display/
    │   │   ├── stat_card.dart
    │   │   ├── subscriber_avatar.dart
    │   │   ├── status_badge.dart
    │   │   ├── debt_display.dart
    │   │   ├── cabinet_progress.dart
    │   │   └── sync_status_dot.dart
    │   ├── inputs/
    │   │   ├── app_text_field.dart
    │   │   ├── app_password_field.dart
    │   │   ├── app_search_bar.dart
    │   │   ├── app_dropdown.dart
    │   │   └── app_date_picker.dart
    │   ├── buttons/
    │   │   ├── primary_button.dart
    │   │   ├── secondary_button.dart
    │   │   └── ghost_button.dart
    │   └── feedback/
    │       ├── app_toast.dart
    │       ├── confirm_dialog.dart
    │       ├── empty_state.dart
    │       ├── skeleton_card.dart
    │       └── confetti_overlay.dart
    └── features/
        ├── auth/
        ├── dashboard/
        ├── subscribers/
        ├── cabinets/
        ├── collection/
        ├── workers/
        ├── reports/
        ├── whatsapp/
        ├── settings/
        └── audit/
```

---

## 4. main.dart

```dart
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  final screen = await screenRetriever.getPrimaryDisplay();
  const w = AppDimens.windowMinWidth;
  const h = AppDimens.windowMinHeight;
  final offsetX = (screen.size.width  - w) / 2;
  final offsetY = (screen.size.height - h) / 2;

  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      size: Size(w, h),
      minimumSize: Size(w, h),
      center: false,
      title: 'المولد الذكي',
      titleBarStyle: TitleBarStyle.hidden,
      backgroundColor: Colors.transparent,
    ),
    () async {
      await windowManager.setPosition(Offset(offsetX, offsetY));
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(const ProviderScope(child: AppRoot()));
}
```

---

## 5. RTL Setup

```dart
// app.dart
MaterialApp.router(
  locale: const Locale('ar', 'IQ'),
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('ar', 'IQ')],
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: ref.watch(themeModeProvider),
  routerConfig: appRouter,
)
```

---

## 6. App Shell Layout

**التخطيط العام — RTL: Sidebar اليمين (أخضر داكن Athena)، المحتوى اليسار (كريمي Bitepoint)**

```
┌─────────────────────────────────────────────────────────────────┐
│  Custom TitleBar 32px (شفاف) — drag region + [─ □ ✕] يسار     │
├────────────────────────────────┬────────────────────────────────┤
│  Main Content — bgPage كريمي  │  Sidebar 220px — bgSidebar     │
│                                │  أخضر داكن #1B4332             │
│  ┌──────────────────────────┐  │                                 │
│  │ TopBar 56px — bgSurface  │  │  [⚡ شعار أبيض]  المولد الذكي  │
│  │ عنوان الصفحة + أفعال     │  │  ─────────────────────────     │
│  └──────────────────────────┘  │                                 │
│                                │  ████ لوحة التحكم  ◀ نشط       │
│  [محتوى scrollable]           │       (pill ذهبي #F5A623)       │
│                                │                                 │
│                                │  ○   المشتركون                  │
│                                │  ○   الكابينات                  │
│                                │  ○   التحصيل                   │
│                                │  ○   العمال                    │
│                                │  ○   التقارير                  │
│                                │  ○   واتساب                    │
│                                │  ─────────────────────────     │
│                                │  ○   الإعدادات                 │
│                                │  ○   سجل التدقيق               │
│                                │  ─────────────────────────     │
│                                │  [avatar] الأدمن  نص أبيض      │
│                                │  [↪ خروج]  أيقونة أبيض         │
└────────────────────────────────┴────────────────────────────────┘
```

**Sidebar Visual Rules (Bitepoint + Athena):**

| العنصر | القيمة |
|---|---|
| خلفية Sidebar | `#1B4332` (أخضر داكن) |
| نص + أيقونات عادية | أبيض `opacity 0.75` |
| nav item نشط | pill ذهبي `#F5A623` كامل العرض، نص أبيض `opacity 1.0` |
| nav item hover | خلفية `rgba(255,255,255,0.08)` + نص أبيض كامل |
| أيقونات | `phosphor_flutter` نمط `light` حجم 20px |
| فاصل | خط `1px rgba(255,255,255,0.12)` |
| شعار | SVG أبيض أعلى `padding: 20px` |
| معلومات المستخدم + Logout | أسفل، نص أبيض |

---

## 7. Screens

### Routes

| الشاشة | Route |
|---|---|
| تسجيل الدخول | `/login` |
| لوحة التحكم | `/dashboard` |
| المشتركون | `/subscribers` |
| الكابينات | `/cabinets` |
| التحصيل | `/collection` |
| العمال | `/workers` |
| التقارير | `/reports` |
| واتساب | `/whatsapp` |
| الإعدادات | `/settings` |
| سجل التدقيق | `/audit` |

---

### SCREEN A: تسجيل الدخول `/login`

**المظهر العام:** خلفية كريمية `bgPage`، بطاقة بيضاء مركزية — مطابق نمط Bitepoint modal.

```
خلفية: bgPage (#F5F5E8) كريمي دافئ

┌──────────────────────────────────┐
│  [SVG شعار ⚡ أخضر داكن]        │  card:
│  المولد الذكي                    │  - w=400px, bg=bgSurface
│  نظام إدارة مشتركي المولدات     │  - radius=rXl (20px)
│  ─────────────────────────────   │  - shadow=elevated
│  كلمة المرور                     │
│  [●●●●●●●●●  ————————  👁]      │  AppPasswordField
│                                  │  (border رمادي خفيف، radius rMd)
│  [         دخول         ]        │  PrimaryButton
│                                  │  (bg=gold, نص أبيض, radius rMd)
│  نسيت كلمة المرور؟              │  TextButton (textSecondary)
└──────────────────────────────────┘

v1.0.0                      © 2026 المولد الذكي
```

```dart
// دخول البطاقة
LoginCard().animate()
  .fadeIn(duration: 400.ms)
  .slideY(begin: 0.05, duration: 350.ms, curve: Curves.easeOut)
```

---

### SCREEN B: لوحة التحكم `/dashboard`

**المظهر العام:** TopBar أبيض نظيف + محتوى على خلفية كريمية — مطابق Bitepoint Dashboard.

```
TopBar (bgSurface أبيض):
  "مرحباً، الأدمن 👋"              الاثنين، 2 مارس 2026

═══════════════════════════════════════════════════════════════

[ ROW بطاقات إحصاء — 4 بطاقات، gap=cardGap ]

┌──────────────────────┐ ┌────────────────────┐ ┌────────────────────┐ ┌───────────────────┐
│ bg: primary #1B4332  │ │ bg: bgSurface أبيض │ │ bg: bgSurface أبيض │ │ bg: gold #F5A623  │
│ [🔔 أيقونة أبيض]    │ │ [✓ primary]        │ │ [⏱ statusWarning]  │ │ نص أبيض           │
│ المحصّل اليوم        │ │ المشتركون          │ │ لم يدفعوا          │ │                   │
│ ─────────────────── │ │ ─────────────────  │ │ ─────────────────  │ │  + إضافة مشترك   │
│ 247,000              │ │ 1,240              │ │ 89                 │ │  [CTA زر رئيسي]  │
│ (Nunito w800 أبيض)  │ │ مشترك              │ │ +7 هذا الأسبوع    │ │                   │
│ IQD subtext أبيض    │ │                    │ │                    │ │                   │
└──────────────────────┘ └────────────────────┘ └────────────────────┘ └───────────────────┘

[ ROW 3 أعمدة، gap=cardGap ]

┌──────────────────────────┐  ┌─────────────────────────┐  ┌───────────────────────┐
│ آخر الدفعات              │  │ يحتاجون دفع (عاجل)      │  │ حالة الكابينات        │
│ bg: bgSurface, radius rLg│  │ bg: bgSurface, radius rLg│  │ bg: bgSurface, rLg    │
│ ─────────────────────── │  │ ──────────────────────  │  │ ────────────────────  │
│ [🔍 بحث داخل البطاقة]   │  │ [🔍 بحث داخل البطاقة]   │  │ PieChart (fl_chart)   │
│                          │  │                          │  │ RepaintBoundary       │
│ [A4] أحمد  ✅ 15,000   │  │ [B2] محمد  [Pay Now →]  │  │ كابينة A  85%         │
│      avatar+نص+badge     │  │ [C5] خالد  [Pay Now →]  │  │ ████████░░            │
│ [B7] علي   ✅  8,000   │  │ [A9] فهد   [Pay Now →]  │  │ كابينة B  60%         │
│ [C2] سامي  🟡 جزئي      │  │                          │  │ ██████░░░░            │
│                          │  │ زر Pay Now: bg=gold,     │  │                       │
│ [عرض الكل ←]            │  │ radius rMd, نص أبيض     │  │                       │
└──────────────────────────┘  └─────────────────────────┘  └───────────────────────┘
```

```dart
// دخول متسلسل للبطاقات (Bitepoint style)
for (int i = 0; i < 4; i++)
  StatCard(...).animate(delay: (i * 80).ms).fadeIn().slideY(begin: 0.06)

// أرقام تُعدّ من صفر عند الدخول
AnimatedFlipCounter(value: collectedToday, duration: 800.ms)
```

---

### SCREEN C: المشتركون `/subscribers`

**المظهر العام:** قائمة بطاقات مشتركين بنمط Order List في Bitepoint — avatar ملون + بيانات + badge حالة.

```
TopBar (bgSurface):
  "المشتركون"   [فلتر ▼]   [🔍 بحث — AppSearchBar]      [+ إضافة مشترك ← gold button]

[ Filter Tabs — نمط Bitepoint tab pills ]
[ الكل (1240) ] [ نشط (1100) ] [ موقوف (89) ] [ مقطوع (34) ] [ معلق (17) ]
Tab نشط: bg=primary نص أبيض، غير نشط: bg=bgSurfaceAlt نص textSecondary

[ DataTable — ListView.builder، 50 مشترك/صفحة ]
┌──────┬──────────────────────────┬───────┬──────────┬───────────────────────┬──────────┬──────────┐
│  #   │ المشترك                   │ الكود │ الكابينة │ الدين المتراكم         │ آخر دفعة │ الحالة   │
├──────┼──────────────────────────┼───────┼──────────┼───────────────────────┼──────────┼──────────┤
│ [A4] │ أحمد علي محمود           │  A4   │    A     │           —           │01/03/26  │ ✅ نشط  │
│ [B2] │ محمد حسن سامي            │  B2   │    B     │ 10,000 + 12,000       │01/01/26  │ 🟡 موقوف│
│ [C7] │ خالد رامي فهد            │  C7   │    C     │ 8,000 + 7,000 + 9,000 │01/11/25  │ 🔴 مقطوع│
└──────┴──────────────────────────┴───────┴──────────┴───────────────────────┴──────────┴──────────┘

Header صف: bg=bgSurfaceAlt، نص textSecondary labelMd
صفوف بديلة: bgSurface / bgSurfaceAlt
Hover على صف: bg=primarySurface خفيف

Right-click context menu (context_menus):
  ├── تسجيل دفعة...      [PhosphorIcon.currencyDollar]
  ├── عرض التفاصيل       [PhosphorIcon.eye]
  ├── تعديل البيانات      [PhosphorIcon.pencilSimple]
  ├── قطع / توصيل        [PhosphorIcon.plugs]
  └── حذف               [PhosphorIcon.trash — textDanger]
```

**Drawer تفاصيل المشترك — يظهر من اليسار في RTL:**

```dart
// AnimatedContainer عرض 360px، يدخل من يسار الشاشة
// overlay رمادي شفاف خلفه

┌──────────────────────────────────────┐
│ [avatar 64px squircle]  أحمد علي    │  bg: bgSurface
│ كود: A4 │ كابينة A │ 5 أمبير        │  shadow: elevated
│ 📞 07701234567                       │  radius يمين فقط: rXl
│ ──────────────────────────────────   │
│ الحالة: ✅ نشط  │ آخر دفعة: 01/03  │
│ بداية الاشتراك: 01/01/2024          │
│ ──────────────────────────────────   │
│ الدين: [لا يوجد ✓] أو [10,000+...] │
│ الوسوم: [VIP] [منتظم]               │  pill صغير
│ الملاحظات: ...                      │
│ ──────────────────────────────────   │
│ [✏️ تعديل]  [✂️ قطع/توصيل]  [🗑 حذف] │  3 أزرار
│ ──────────────────────────────────   │
│ سجل الدفعات ▼ (Expandable)          │
│   ● 01/03 — 15,000 — علي (عامل)    │
│   ● 01/02 — 15,000 — أحمد (عامل)  │
└──────────────────────────────────────┘
```

---

### SCREEN D: الكابينات `/cabinets`

**المظهر العام:** Grid بطاقات — كل بطاقة تشبه Order Card في Bitepoint مع progress bar.

```
TopBar (bgSurface):
  "الكابينات"                                          [+ إضافة كابينة ← gold button]

[ Grid — 4 بطاقات/صف، gap=cardGap، مرتبة تنازلياً بالنسبة المئوية ]

┌──────────────────────────┐  ┌──────────────────────────┐
│ bg: bgSurface            │  │ bg: bgSurface            │
│ radius: rLg, shadow: card│  │ radius: rLg, shadow: card│
│                          │  │                          │
│ كابينة A    🏆 badge ذهبي│  │ كابينة B                 │
│                          │  │                          │
│ ████████████░░  94%      │  │ ████████░░░░  78%        │
│ (progress bar أخضر)      │  │ (progress bar أخضر)      │
│ ─────────────────────── │  │ ─────────────────────── │
│ المشتركون:  310 / 320    │  │ المشتركون:  187 / 240    │
│ المحصّل:   620,000 IQD   │  │ المحصّل:   374,000 IQD   │
│ المتأخرون: 10 مشترك      │  │ المتأخرون: 53 مشترك      │
│ ─────────────────────── │  │ ─────────────────────── │
│ [عرض المشتركين ←]       │  │ [عرض المشتركين ←]        │
│ (ghost button)           │  │ (ghost button)           │
└──────────────────────────┘  └──────────────────────────┘
```

```dart
// احتفال عند اكتمال كابينة 100%
ConfettiWidget(
  confettiController: _controller,
  blastDirectionality: BlastDirectionality.explosive,
  colors: [AppColors.primary, AppColors.gold, Colors.white],
  numberOfParticles: 60,
  gravity: 0.3,
)
// + AudioService.play('assets/sounds/cabinet_complete.mp3')
// + Toast نجاح: "اكتملت كابينة A بنسبة 100% 🎉"
```

---

### SCREEN E: التحصيل `/collection`

**المظهر العام:** 3 أعمدة بنمط Kanban — مشابه عمود Payment في Bitepoint Dashboard.

```
TopBar (bgSurface):
  "التحصيل — مارس 2026"        سعر الأمبير: 2,500 IQD  [✏️ تعديل]

مؤشر تقدم الشهر (progress bar full-width تحت TopBar):
▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░  52%   جُمع: 1,248,000  │  متبقي: 1,152,000

[ 3 أعمدة Kanban، gap=cardGap ]

┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│ ❌ لم يدفعوا (89)   │  │ 🟡 دفع جزئي (34)    │  │ ✅ مكتمل (1,117)   │
│ header: statusDangerS│  │ header: statusWarnS  │  │ header: statusActS  │
│ ─────────────────── │  │ ─────────────────── │  │ ─────────────────── │
│                      │  │                      │  │                      │
│ [A9] محمود فاروق     │  │ [C2] خالد سامي       │  │ [A4] أحمد  ✓        │
│      15,000 IQD      │  │    10,000 + 3,000    │  │ [B1] سامي  ✓        │
│ [Pay Now →] gold btn │  │ [أكمل →] gold btn    │  │ [C3] علي   ✓        │
│                      │  │                      │  │                      │
│ [B4] فهد رامي        │  │ [A7] عمر حسن         │  │ (scrollable)         │
│      12,000 IQD      │  │     8,000 + 4,000    │  │                      │
│ [Pay Now →]          │  │ [أكمل →]             │  │                      │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
```

**Payment Dialog — بنمط Payment modal في Bitepoint:**

```
overlay رمادي شفاف rgba(0,0,0,0.4) — بطاقة مركزية

┌────────────────────────────────────────────┐
│ تسجيل دفعة                            [✕] │  bg: bgSurface
│ ─────────────────────────────────────────  │  radius: rXl
│ المشترك: محمود فاروق (A9)                 │  shadow: modal
│ المستحق: 15,000 IQD                       │
│ ─────────────────────────────────────────  │
│ المبلغ المدفوع:                           │
│ [  15,000                         IQD   ] │  AppTextField كبير
│                                            │
│ Quick amounts (chips):                     │
│ [15,000 كاملاً] [10,000] [7,500] [5,000] │  chips: border primary
│                                            │
│ العامل المستلم: [ علي محمد ▼ ]            │  AppDropdown
│ ─────────────────────────────────────────  │
│ [ 🖨 طباعة + تسجيل ] [ تسجيل فقط ]       │  الأول: gold | الثاني: ghost
└────────────────────────────────────────────┘
```

```dart
// بعد التسجيل الناجح
AudioService.play('assets/sounds/payment_success.mp3');
Toastification.show(
  type: ToastificationType.success,
  title: Text('تم تسجيل الدفعة'),
  description: Text('15,000 IQD — محمود فاروق (A9)'),
  alignment: Alignment.bottomLeft, // bottomLeft في RTL
  autoCloseDuration: Duration(seconds: 3),
);
```

---

### SCREEN F: العمال `/workers`

**المظهر العام:** Grid بطاقات عمال — مشابه Popular Dishes section في Bitepoint.

```
TopBar (bgSurface):
  "العمال"                                              [+ إضافة عامل ← gold button]

[ Grid — 3 بطاقات/صف، gap=cardGap ]

┌──────────────────────────────────┐
│ bg: bgSurface, radius: rLg       │
│ shadow: card                     │
│                                  │
│ [avatar 48px squircle]           │
│ علي محمد                         │
│ 📞 07701234567                   │
│ ─────────────────────────────── │
│ الصلاحيات:                       │
│ [تحصيل] [إضافة مشترك]           │  badges صغيرة primary
│                                  │
│ المحصّل اليوم: 180,000 IQD      │  Nunito w700 textHeading
│ إجمالي هذا الشهر: 620,000 IQD   │
│ ─────────────────────────────── │
│ [✏️ تعديل الصلاحيات] [🗑 حذف]    │  ghost + danger
└──────────────────────────────────┘

[ Emergency Banner — يظهر فقط عند حدث طارئ، bg: statusDangerS ]
⚠️ تم تسجيل دخول غير مصرح به — راجع سجل التدقيق
```

---

### SCREEN G: التقارير `/reports`

**المظهر العام:** لوحة charts + جداول — مشابه Accounting section في Bitepoint.

```
TopBar (bgSurface):
  "التقارير"        [ تحديد الشهر ▼ ]        [ 📄 تصدير PDF — gold button ]

[ ROW Charts — 3 بطاقات متساوية، gap=cardGap ]

┌──────────────────────────┐  ┌──────────────────────────┐  ┌──────────────────────┐
│ PieChart — نسب الدفع     │  │ BarChart — إيرادات شهرية  │  │ LineChart — تقدم الشهر│
│ fl_chart                 │  │ fl_chart                  │  │ fl_chart             │
│ RepaintBoundary          │  │ RepaintBoundary            │  │ RepaintBoundary      │
│ ألوان: primary/gold/warn │  │ bars: primary/gold        │  │ line: primary        │
└──────────────────────────┘  └──────────────────────────┘  └──────────────────────┘

[ Row Tabs ]
[ تقرير العمال ] [ تقرير المديونين ] [ تقرير الكابينات ]
Tab نشط: border-bottom primary، نص primary

[ DataTable تفصيلي حسب التاريخ المختار ]
```

---

### SCREEN H: واتساب `/whatsapp`

**المظهر العام:** 3 أعمدة — مشابه تخطيط Orders 3-column في Bitepoint.

```
TopBar (bgSurface):
  "واتساب"

[ 3 أعمدة، gap=cardGap ]

┌────────────────────┐  ┌──────────────────────────────────────┐  ┌─────────────────┐
│ القوالب            │  │ محرر الرسالة                          │  │ سجل الإرسال     │
│ bg:bgSurface rLg   │  │ bg:bgSurface rLg                     │  │ bg:bgSurface rLg│
│ ─────────────────  │  │ ──────────────────────────────────── │  │ ──────────────  │
│ [القالب 1 ✓]      │  │ [textarea RTL — محرر نص عربي]        │  │ ✓ أحمد  10:30  │
│ [القالب 2]        │  │ placeholder: "اكتب رسالتك..."         │  │ ✓ علي   10:31  │
│ [القالب 3]        │  │                                       │  │ ✗ محمد  خطأ   │
│                    │  │ المستقبلون: [ اختر المجموعة ▼ ]      │  │                 │
│ [+ قالب جديد]     │  │ ────────────────────────────────────  │  │ (scrollable)    │
│ ghost button       │  │ [ إرسال للجميع ]  [ إرسال للمختارين ]│  │                 │
│                    │  │ الأول: gold full-width                │  │                 │
└────────────────────┘  └──────────────────────────────────────┘  └─────────────────┘
```

```dart
// lib/core/services/whatsapp_service.dart
// يُشغّل: node node/whatsapp_bridge.js كـ subprocess
class WhatsAppService {
  Future<void> sendMessage({required String phone, required String message}) async {
    final result = await Process.run(
      'node',
      ['node/whatsapp_bridge.js', '--phone=$phone', '--msg=$message'],
    );
    if (result.exitCode != 0) throw WhatsAppException(result.stderr as String);
  }
}
```

---

### SCREEN I: الإعدادات `/settings`

**المظهر العام:** ثنائي الشريط — Settings Sidebar داخلي أبيض + محتوى.

```
[ تخطيط ثنائي داخل المحتوى الرئيسي ]

┌──────────────────────┬──────────────────────────────────────────────┐
│ Settings Sidebar     │ Content Area                                  │
│ bg:bgSurfaceAlt      │ bg:bgSurface, radius:rLg, shadow:card         │
│ w=200px              │                                               │
│ ──────────────────── │ ─────────────────────────────────────────── │
│ ● معلومات المولد     │ [قسم: معلومات صاحب المولد]                   │
│ ○ المظهر             │                                               │
│ ○ الطباعة            │ اسم المولد:    [___________________]         │
│ ○ الأمان             │ رقم الهاتف:    [___________________]         │
│ ○ المزامنة           │ العنوان:       [___________________]         │
│ ○ الإشعارات          │ الشعار:        [📎 رفع صورة]                 │
│ ○ النسخ الاحتياطي    │                                               │
│ ○ الترخيص            │          [    حفظ التغييرات    ]             │
│                      │          (gold button, radius rMd)            │
└──────────────────────┴──────────────────────────────────────────────┘
```

**8 تبويبات:**
- **معلومات المولد** — اسم، هاتف، عنوان، شعار
- **المظهر** — Light / Dark / System (3 cards اختيار بصري)
- **الطباعة** — اختيار طابعة ESC/POS، اختبار طباعة
- **الأمان** — تغيير كلمة المرور + إدارة صلاحيات العمال
- **المزامنة** — Supabase URL/Key + حالة الاتصال
- **الإشعارات** — تفعيل/تعطيل أنواع الإشعارات
- **النسخ الاحتياطي** — تصدير/استيراد قاعدة البيانات
- **الترخيص** — معلومات النسخة + مفتاح الترخيص

---

### SCREEN J: سجل التدقيق `/audit`

**المظهر العام:** Timeline عمودي — مشابه Order history في Bitepoint.

```
TopBar (bgSurface):
  "سجل التدقيق"     [فلتر بالتاريخ ▼]   [فلتر بالإجراء ▼]   [🔍 بحث]

[ Timeline عمودي — خط رأسي primary خفيف على اليمين في RTL ]

● [10:45]  الأدمن ← تسجيل دفعة ← أحمد علي (A4) ← 15,000 IQD
           badge: statusActiveS "دفعة"

● [10:30]  علي (عامل) ← تعديل مشترك ← محمد حسن (B2)
           badge: statusInfoS "تعديل"

● [09:15]  الأدمن ← إضافة مشترك ← خالد رامي (C7)
           badge: statusActiveS "إضافة"

● [08:00]  الأدمن ← قطع خدمة ← فهد سامي (D3)
           badge: statusDangerS "قطع"
```

---

## 8. Shared Widgets

### StatusBadge

```dart
// نمط Bitepoint: badge صغير pill — خلفية فاتحة ملونة + نقطة 6px + نص
// active    → bg: statusActiveS  / dot+text: statusActive
// suspended → bg: statusWarningS / dot+text: statusWarning
// cut       → bg: statusDangerS  / dot+text: statusDanger
// pending   → bg: statusInfoS    / dot+text: statusInfo

Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: bgColor,
    borderRadius: BorderRadius.circular(AppDimens.rFull),
  ),
  child: Row(children: [
    Container(width: 6, height: 6, decoration: BoxDecoration(
      color: dotColor,
      shape: BoxShape.circle,
    )),
    Gap(4),
    Text(label, style: AppTypography.labelMd.copyWith(color: textColor)),
  ]),
)
```

### SubscriberAvatar

```dart
// مربع squircle (smooth_corner) ملون بـ hash الكود — نمط Bitepoint Order Avatar
static const _avatarColors = [
  Color(0xFF1B4332), Color(0xFF1E40AF), Color(0xFF7C3AED),
  Color(0xFFB45309), Color(0xFF0E7490), Color(0xFF065F46),
  Color(0xFF9D174D), Color(0xFF92400E),
];

Color _colorFromCode(String code) =>
    _avatarColors[code.codeUnits.fold(0, (a, b) => a + b) % _avatarColors.length];

// الحرفان الأوليان من الاسم أو الكود — نص أبيض Nunito w700
```

### DebtDisplay

```dart
// "10,000 + 12,000 + 7,000" — في RTL الأحدث يمين تلقائياً
// لون: statusDanger، خط: numMd
Row(
  children: debts.mapIndexed((i, debt) => [
    if (i > 0) Text(' + ', style: AppTypography.numMd.copyWith(color: AppColors.textMuted)),
    Text(formatAmount(debt.amount), style: AppTypography.numMd.copyWith(color: AppColors.statusDanger)),
  ]).expand((x) => x).toList(),
)
```

### AppSearchBar

```dart
// نمط Bitepoint: حقل بحث بيضاء، border رمادي خفيف، أيقونة بحث Phosphor يسار
// radius: rMd، padding: s8 أفقي
// placeholder: textMuted
```

---

## 9. Interaction Patterns

### Animations (flutter_animate — Bitepoint style)

```dart
// بطاقات إحصاء — دخول متسلسل
StatCard(...).animate(delay: (i * 80).ms).fadeIn().slideY(begin: 0.06)

// صفوف القوائم
ListItem(...).animate(delay: (i * 40).ms).fadeIn().slideX(begin: 0.03)

// أرقام تعدّ من صفر
AnimatedFlipCounter(value: total, duration: 800.ms)

// Modal دخول
Dialog().animate().fadeIn(duration: 200.ms).scale(begin: Offset(0.96, 0.96))
```

### Hover States (Desktop)

```dart
// MouseRegion + AnimatedContainer (200ms Curves.easeOut)
// Cards:     border → primaryBorder + shadow كبير
// NavItems:  bg → rgba(255,255,255,0.08) [في sidebar أخضر]
// Buttons:   opacity 0.92 + scale 0.985
// TableRows: bg → bgSurfaceAlt
// PayNow btn: bg → goldDark
```

### Toast System (Bitepoint — bottomLeft في RTL)

```dart
Toastification.instance.show(
  type: ToastificationType.success,
  title: Text('تم تسجيل الدفعة'),
  description: Text('15,000 — أحمد علي (A4)'),
  alignment: Alignment.bottomLeft,
  autoCloseDuration: const Duration(seconds: 3),
);
```

### Context Menu (Right-click)

```dart
ContextMenuRegion(
  contextMenuBuilder: (context, offset) =>
    AdaptiveTextSelectionToolbar.buttonItems(
      anchors: TextSelectionToolbarAnchors(primaryAnchor: offset),
      buttonItems: [
        ContextMenuButtonItem(label: 'تسجيل دفعة', onPressed: () {}),
        ContextMenuButtonItem(label: 'عرض التفاصيل', onPressed: () {}),
        ContextMenuButtonItem(label: 'تعديل', onPressed: () {}),
        ContextMenuButtonItem(
          label: 'حذف',
          onPressed: () {},
          type: ContextMenuButtonType.destructive,
        ),
      ],
    ),
  child: SubscriberRow(...),
)
```

### Skeleton Loading

```dart
// shimmer لبطاقات المشتركين عند التحميل الأول
Shimmer.fromColors(
  baseColor: AppColors.borderLight,
  highlightColor: AppColors.bgSurface,
  child: SkeletonCard(),
)
```

---

## 10. Dark Mode

```dart
// lib/core/theme/app_theme.dart
ThemeData buildDarkTheme() => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBgPage,
  cardColor: AppColors.darkBgSurface,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.gold,
    surface: AppColors.darkBgSurface,
    outline: AppColors.darkBorder,
  ),
);

// Sidebar Dark Mode — flutter_acrylic: تأثير Mica حقيقي من Windows 11
// في main.dart:
await Window.initialize();
await Window.setEffect(effect: WindowEffect.mica, dark: true);
// الـ Sidebar: Container(color: AppColors.darkBgSidebar.withOpacity(0.85))
```

---

## 11. Database Schema (Drift)

```dart
class Subscribers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().withLength(min: 36, max: 36)();
  TextColumn get name => text()();
  TextColumn get code => text().withLength(min: 1, max: 10)();
  TextColumn get phone => text().nullable()();
  IntColumn get cabinetId => integer().references(Cabinets, #id)();
  IntColumn get amperes => integer().withDefault(const Constant(5))();
  TextColumn get status => text()(); // active | suspended | cut | pending
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get lastPaymentDate => dateTime().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Cabinets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get totalSubscribers => integer()();
}

class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text()();
  IntColumn get subscriberId => integer().references(Subscribers, #id)();
  IntColumn get workerId => integer().nullable().references(Workers, #id)();
  IntColumn get amount => integer()();
  DateTimeColumn get paidAt => dateTime()();
  TextColumn get month => text()(); // "2026-03"
  BoolColumn get isPrinted => boolean().withDefault(const Constant(false))();
}

class Workers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get permissions => text()(); // JSON array
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class AuditLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get actorName => text()();
  TextColumn get action => text()();
  TextColumn get targetType => text()(); // subscriber | payment | cabinet | worker
  IntColumn get targetId => integer().nullable()();
  TextColumn get details => text().nullable()(); // JSON
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

---

## 12. Performance Rules

```dart
// ListView دائماً .builder — لا ListView العادي
// Pagination: 50 مشترك/صفحة
// Search debounce: 300ms (rxdart BehaviorSubject)
// لا إعادة بناء Sidebar عند navigation
// RepaintBoundary لجميع Charts

RepaintBoundary(child: MonthlyBarChart(...))
RepaintBoundary(child: PaymentPieChart(...))
```

---

## 13. Build Setup

```bash
# بعد flutter pub get:
dart run build_runner build --delete-conflicting-outputs

# وضع watch أثناء التطوير:
dart run build_runner watch --delete-conflicting-outputs
```

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml
analyzer:
  plugins:
    - custom_lint
```

---

## 14. Bitepoint + Athena Visual Rules (تطبيق صارم على كل شاشة)

| العنصر | القيمة الصارمة |
|---|---|
| خلفية الصفحة | `#F5F5E8` (كريمي دافئ Bitepoint) |
| خلفية البطاقات | `#FFFFFF` |
| خلفية Sidebar | `#1B4332` (أخضر داكن — Athena style) |
| Nav item نشط | pill ذهبي `#F5A623` كامل العرض، نص أبيض |
| Nav item hover | `rgba(255,255,255,0.08)` خفيف |
| نص + أيقونات Sidebar | أبيض `opacity 0.75` عادي / `1.0` نشط |
| بطاقة إحصاء رئيسية | خلفية `#1B4332`، رقم Nunito w800 أبيض كبير |
| بطاقة إحصاء ثانوية | خلفية `#FFFFFF`، رقم Nunito w700 |
| زر CTA رئيسي | خلفية `#F5A623`، نص أبيض، radius `rMd` (10px) |
| زر Ghost | border `borderMid`، نص `textBody`، bg شفاف |
| Avatar المشترك | squircle `36px`، لون من hash الكود، نص أبيض |
| Badge حالة | pill: خلفية فاتحة + نقطة `6px` + نص ملون |
| Modal | overlay `rgba(0,0,0,0.4)` + card بيضاء radius `rXl` |
| Shadow | خفيفة: `0 1px 4px rgba(0,0,0,0.08)` |
| DataTable header | `bgSurfaceAlt`، صفوف بديلة `bgSurface/bgSurfaceAlt` |
| Search bar | بيضاء، border `borderLight`، أيقونة Phosphor |
| Separator | خط `1px #EAEAE4` |
| TopBar | `bgSurface` أبيض، `shadow: card` خفيف |
| Filter Tabs | نشط: bg primary نص أبيض / غير نشط: bgSurfaceAlt |
