import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/app_theme.dart';

/// Rounded text field matching the login phone box.
class AuthField extends StatelessWidget {
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
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization capitalization;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? formatters;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: error ? const Color(0xFFD64560) : const Color(0xFFE3DFEA),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF9A94A5)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textCapitalization: capitalization,
              textInputAction: textInputAction,
              inputFormatters: formatters,
              cursorColor: AppColors.lavender,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF9A94A5)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
