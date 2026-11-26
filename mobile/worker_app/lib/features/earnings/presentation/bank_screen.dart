import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/ui.dart';
import '../data/earnings_store.dart';

/// Links a UPI id or bank account. Only a masked form is kept.
/// TODO(earnings): send to the payments provider over a secure channel.
class BankScreen extends ConsumerStatefulWidget {
  const BankScreen({super.key});

  @override
  ConsumerState<BankScreen> createState() => _BankScreenState();
}

class _BankScreenState extends ConsumerState<BankScreen> {
  final _upi = TextEditingController();
  final _account = TextEditingController();
  final _ifsc = TextEditingController();
  int _mode = 0;

  bool get _valid => _mode == 0
      ? RegExp(r'^[\w.\-]{2,}@[a-zA-Z]{2,}$').hasMatch(_upi.text.trim())
      : _account.text.length >= 9 &&
            RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
                .hasMatch(_ifsc.text.toUpperCase());

  @override
  void initState() {
    super.initState();
    for (final c in [_upi, _account, _ifsc]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _upi.dispose();
    _account.dispose();
    _ifsc.dispose();
    super.dispose();
  }

  void _save() {
    final masked = _mode == 0
        ? '${_upi.text.trim().substring(0, 2)}••••@${_upi.text.trim().split('@').last}'
        : 'Account ••••${_account.text.substring(_account.text.length - 4)}';
    ref.read(earningsProvider.notifier).linkAccount(masked);
    toast(context, 'Payout account saved (demo)');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final linked = ref.watch(earningsProvider.select((e) => e.payoutAccount));
    return AppPage(
      title: 'Payout account',
      bottom: FilledButton(
        onPressed: _valid ? _save : null,
        child: const Text('Save'),
      ),
      children: [
        if (linked != null) ...[
          Pill(
            'Currently: $linked',
            icon: Icons.check_circle_rounded,
            color: AppColors.success,
            fill: AppColors.successSoft,
          ),
          const SizedBox(height: 14),
        ],
        ChoiceChips(
          options: const ['UPI ID', 'Bank account'],
          selected: _mode,
          onSelected: (i) => setState(() => _mode = i),
        ),
        const SizedBox(height: 18),
        if (_mode == 0)
          TextField(
            controller: _upi,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'name@bank'),
          )
        else ...[
          TextField(
            controller: _account,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(18),
            ],
            decoration: const InputDecoration(hintText: 'Account number'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ifsc,
            autocorrect: false,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [LengthLimitingTextInputFormatter(11)],
            decoration: const InputDecoration(hintText: 'IFSC code'),
          ),
        ],
        const SizedBox(height: 14),
        const Text(
          'The account must be in your own name. Never share your PIN or OTP with anyone.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
