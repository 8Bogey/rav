import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// A styled text field with label, hint, and validation support
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool isDarkMode;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDarkMode ? AppColors.darkBorder : AppColors.borderLight;
    final fillColor =
        isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface;
    final hintColor =
        isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMd.copyWith(
              color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          maxLength: maxLength,
          onTap: onTap,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          focusNode: focusNode,
          style: AppTypography.bodyMd.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyMd.copyWith(color: hintColor),
            filled: true,
            fillColor: fillColor,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.statusDanger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.statusDanger, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

/// A password field with show/hide toggle
class AppPasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final bool isDarkMode;

  const AppPasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.isDarkMode = false,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      obscureText: _obscureText,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      focusNode: widget.focusNode,
      isDarkMode: widget.isDarkMode,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color:
              widget.isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}

/// A search bar with debounce functionality
class AppSearchBar extends StatefulWidget {
  final String? hint;
  final Function(String) onSearch;
  final Duration debounceDuration;
  final VoidCallback? onClear;
  final bool autoFocus;
  final bool isDarkMode;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hint,
    required this.onSearch,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.onClear,
    this.autoFocus = false,
    this.isDarkMode = false,
    this.controller,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  bool get isDarkMode => widget.isDarkMode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearch(value);
    });
  }

  void _onClear() {
    _controller.clear();
    widget.onSearch('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDarkMode ? AppColors.darkBorder : AppColors.borderLight;
    final fillColor =
        isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface;

    return TextField(
      controller: _controller,
      autofocus: widget.autoFocus,
      onChanged: _onChanged,
      style: AppTypography.bodyMd.copyWith(
        color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
      ),
      decoration: InputDecoration(
        hintText: widget.hint ?? 'بحث...',
        hintStyle: AppTypography.bodyMd.copyWith(
          color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
        ),
        filled: true,
        fillColor: fillColor,
        prefixIcon: Icon(
          Icons.search,
          color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          size: 20,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: isDarkMode
                      ? AppColors.darkTextMuted
                      : AppColors.textMuted,
                  size: 20,
                ),
                onPressed: _onClear,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// A styled dropdown field
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?)? onChanged;
  final String? hint;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isDarkMode;
  final Widget? prefixIcon;

  const AppDropdown({
    super.key,
    this.label,
    this.value,
    required this.items,
    this.onChanged,
    this.hint,
    this.validator,
    this.enabled = true,
    this.isDarkMode = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDarkMode ? AppColors.darkBorder : AppColors.borderLight;
    final fillColor =
        isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMd.copyWith(
              color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          hint: hint != null
              ? Text(
                  hint!,
                  style: AppTypography.bodyMd.copyWith(
                    color: isDarkMode
                        ? AppColors.darkTextMuted
                        : AppColors.textMuted,
                  ),
                )
              : null,
          style: AppTypography.bodyMd.copyWith(
            color: isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillColor,
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.statusDanger),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          dropdownColor: fillColor,
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: isDarkMode ? AppColors.darkTextMuted : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// A styled date picker field
class AppDatePicker extends StatelessWidget {
  final String? label;
  final DateTime? value;
  final Function(DateTime?)? onChanged;
  final String? hint;
  final String? Function(DateTime?)? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool enabled;
  final bool isDarkMode;
  final String Function(DateTime)? formatDate;

  const AppDatePicker({
    super.key,
    this.label,
    this.value,
    this.onChanged,
    this.hint,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.enabled = true,
    this.isDarkMode = false,
    this.formatDate,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDarkMode
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.darkBgSurface,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    surface: AppColors.bgSurface,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChanged?.call(picked);
    }
  }

  String _formatDate(DateTime date) {
    return formatDate?.call(date) ?? '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDarkMode ? AppColors.darkBorder : AppColors.borderLight;
    final fillColor =
        isDarkMode ? AppColors.darkBgSurface : AppColors.bgSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTypography.labelMd.copyWith(
              color: isDarkMode ? AppColors.darkTextBody : AppColors.textBody,
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: enabled ? () => _pickDate(context) : null,
          child: AbsorbPointer(
            child: TextFormField(
              initialValue: value != null ? _formatDate(value!) : null,
              validator: validator != null ? (_) => validator!(value) : null,
              style: AppTypography.bodyMd.copyWith(
                color:
                    isDarkMode ? AppColors.darkTextHead : AppColors.textHeading,
              ),
              decoration: InputDecoration(
                hintText: hint ?? 'اختر التاريخ',
                hintStyle: AppTypography.bodyMd.copyWith(
                  color: isDarkMode
                      ? AppColors.darkTextMuted
                      : AppColors.textMuted,
                ),
                filled: true,
                fillColor: fillColor,
                prefixIcon: Icon(
                  Icons.calendar_today,
                  color: isDarkMode
                      ? AppColors.darkTextMuted
                      : AppColors.textMuted,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.statusDanger),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
