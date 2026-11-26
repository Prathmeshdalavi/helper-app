import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';

/// Four boxes fed by one hidden text field. Used for sign-in and job codes.
class CodeField extends StatefulWidget {
  const CodeField({
    super.key,
    required this.controller,
    required this.label,
    this.length = 4,
    this.error = false,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final String label;
  final int length;
  final bool error;
  final bool autofocus;

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_repaint);
  }

  void _repaint() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_repaint);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    return Semantics(
      label: widget.label,
      textField: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _focus.requestFocus,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Hidden field that actually receives the keystrokes.
            Opacity(
              opacity: 0,
              child: SizedBox(
                width: 1,
                height: 1,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: widget.autofocus,
                  keyboardType: TextInputType.number,
                  enableInteractiveSelection: false,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < widget.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 56,
                    height: 66,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: widget.error
                          ? AppColors.dangerSoft
                          : i < text.length
                          ? AppColors.softLavender
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lavender.withValues(
                            alpha: i == text.length ? 0.35 : 0.1,
                          ),
                          blurRadius: i == text.length ? 14 : 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      i < text.length ? text[i] : '•',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: i < text.length
                            ? AppColors.text
                            : AppColors.lavenderLight,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
