import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/app_theme.dart';

/// Rounded text field that matches the login phone box. Glows when focused
/// and shows a tick once the value is valid.
class AuthField extends StatefulWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.capitalization = TextCapitalization.none,
    this.textInputAction,
    this.formatters,
    this.error = false,
    this.valid = false,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? formatters;
  final bool error;

  /// Shows a tick at the end of the field.
  final bool valid;

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFD64560);
    final focused = _focus.hasFocus;
    final accent = widget.error ? red : AppColors.lavender;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: focused ? Colors.white : const Color(0xFFFFFCFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: focused || widget.error ? accent : const Color(0xFFFCE8DD),
          width: focused || widget.error ? 1.6 : 1.2,
        ),
        boxShadow: focused || widget.error
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : const [],
      ),
      child: Row(
        children: [
          Icon(
            widget.icon,
            size: 20,
            color: focused ? AppColors.lavender : const Color(0xFF7C7C7C),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.capitalization,
              textInputAction: widget.textInputAction,
              inputFormatters: widget.formatters,
              cursorColor: AppColors.lavender,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(color: Color(0xFF7C7C7C)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          AnimatedScale(
            scale: widget.valid ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFF1B8A4B),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
