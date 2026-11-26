import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../data/earnings_store.dart';

class EarlyPayoutScreen extends ConsumerStatefulWidget {
  const EarlyPayoutScreen({super.key});

  @override
  ConsumerState<EarlyPayoutScreen> createState() => _EarlyPayoutScreenState();
}

class _EarlyPayoutScreenState extends ConsumerState<EarlyPayoutScreen> {
  static const _step = 100;
  int? _amount;

  void _confirm(int amount) {
    showAppSheet<void>(
      context,
      builder: (sheet) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Withdraw ${rupees(amount)}?',
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'It is taken out of your next payout. This is a demo: no money moves.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              final ok = ref
                  .read(earningsProvider.notifier)
                  .withdrawEarly(amount);
              Navigator.pop(sheet);
              setState(() => _amount = null);
              toast(
                context,
                ok ? 'Request placed (demo)' : 'That amount is not available',
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningsProvider);
    final limit = state.earlyLimit;
    final amount = (_amount ?? limit).clamp(0, limit);
    final linked = state.payoutAccount != null;
    return AppPage(
      title: 'Early payout',
      actions: [
        TextButton(
          onPressed: () => context.push(Routes.payouts),
          child: const Text('History'),
        ),
      ],
      bottom: linked
          ? FilledButton(
              onPressed: amount >= _step ? () => _confirm(amount) : null,
              child: Text('Withdraw ${rupees(amount)}'),
            )
          : FilledButton(
              onPressed: () => context.push(Routes.bank),
              child: const Text('Add bank account first'),
            ),
      children: [
        AppCard(
          color: AppColors.softLavender,
          shadow: false,
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const IconTile(
                Icons.bolt_rounded,
                size: 64,
                fill: AppColors.card,
              ),
              const SizedBox(height: 12),
              const Text('Maximum you can take now'),
              CountUp(
                value: limit,
                format: rupees,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            children: [
              ValueRow(
                'Total earnings',
                rupees(state.month.total(state.hasPan)),
              ),
              ValueRow('Already withdrawn', rupees(state.month.earlyPayout)),
              ValueRow(
                'Remaining payout',
                rupees(state.month.remaining(state.hasPan)),
              ),
            ],
          ),
        ),
        if (limit >= _step) ...[
          const SectionTitle('How much?'),
          Slider(
            value: amount.toDouble(),
            max: limit.toDouble(),
            divisions: (limit / _step).ceil(),
            label: rupees(amount),
            semanticFormatterCallback: (v) => rupees(v),
            onChanged: (v) => setState(() => _amount = v.round()),
          ),
        ],
      ],
    );
  }
}
