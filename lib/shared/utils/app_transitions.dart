import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';

class AppTransitions {
  AppTransitions._();

  /// Shows a premium dialog with a smooth scale and fade transition.
  static Future<T?> showPremiumDialog<T>({
    required BuildContext context,
    required Widget child,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
    String? barrierLabel,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel ?? 'Close',
      barrierColor: barrierColor,
      transitionDuration: AppDimens.durationNormal,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeOutQuart;
        final scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );
        final opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: curve),
        );

        return FadeTransition(
          opacity: opacityAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
    );
  }
}
