import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/ui.dart';
import '../data/earnings_store.dart';
import '../domain/earnings.dart';

class PayoutsScreen extends ConsumerStatefulWidget {
  const PayoutsScreen({super.key});

  @override
  ConsumerState<PayoutsScreen> createState() => _PayoutsScreenState();
}

class _PayoutsScreenState extends ConsumerState<PayoutsScreen> {
  static const _filters = ['All', 'Successful', 'Processing', 'Failed'];
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningsProvider);
    final list = state.payouts
        .where(
          (p) => switch (_filter) {
            1 => p.status == PayoutStatus.paid,
            2 => p.status == PayoutStatus.processing,
            3 => p.status == PayoutStatus.failed,
            _ => true,
          },
        )
        .toList();
    return AppPage(
      title: 'Payout history',
      actions: [
        TextButton(
          onPressed: () => context.push(Routes.help),
          child: const Text('Payout issue?'),
        ),
      ],
      children: [
        MenuCard(
          children: [
            AppRow(
              icon: Icons.account_balance_rounded,
              title: state.payoutAccount == null
                  ? 'Add bank account to get paid'
                  : 'Linked account',
              subtitle: state.payoutAccount,
              onTap: () => context.push(Routes.bank),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ChoiceChips(
          options: _filters,
          selected: _filter,
          onSelected: (i) => setState(() => _filter = i),
        ),
        const SizedBox(height: 14),
        if (list.isEmpty)
          const EmptyState(
            icon: Icons.receipt_long_rounded,
            title: 'No transactions yet',
            message: 'Your payouts will show up here.',
          )
        else
          MenuCard(
            children: [
              for (final p in list)
                AppRow(
                  icon: switch (p.status) {
                    PayoutStatus.paid => Icons.south_west_rounded,
                    PayoutStatus.processing => Icons.hourglass_top_rounded,
                    PayoutStatus.failed => Icons.error_outline_rounded,
                  },
                  color: switch (p.status) {
                    PayoutStatus.paid => AppColors.success,
                    PayoutStatus.processing => AppColors.warning,
                    PayoutStatus.failed => AppColors.danger,
                  },
                  fill: switch (p.status) {
                    PayoutStatus.paid => AppColors.successSoft,
                    PayoutStatus.processing => AppColors.warningSoft,
                    PayoutStatus.failed => AppColors.dangerSoft,
                  },
                  title: p.kind,
                  subtitle:
                      '${shortDate(p.date)} · ${p.status.name[0].toUpperCase()}${p.status.name.substring(1)}',
                  trailing: Text(
                    rupees(p.amount),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
