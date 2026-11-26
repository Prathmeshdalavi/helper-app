import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/extras.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../../home/presentation/home_tab_provider.dart';
import '../../jobs/data/work_store.dart';
import '../data/earnings_store.dart';

class EarningsTab extends ConsumerStatefulWidget {
  const EarningsTab({super.key});

  @override
  ConsumerState<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends ConsumerState<EarningsTab> {
  int _back = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(earningsProvider);
    final month = ref.read(earningsProvider.notifier).monthBack(_back);
    final today = ref.watch(todayProvider);
    final shown = DateTime(today.year, today.month - _back);
    final pan = state.hasPan;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const PageHeader(title: 'Earnings', actions: [OvertimeButton()]),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              children: [
                if (ref.watch(workProvider.select((w) => w.online))) ...[
                  const AppCard(
                    color: AppColors.infoSoft,

                    shadow: false,

                    child: Row(
                      children: [
                        Icon(Icons.timelapse_rounded, color: AppColors.info),

                        SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Shift in progress. Today is final after you go offline.',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                ],

                Pager(
                  label: '${monthNames[shown.month - 1]} ${shown.year}',
                  onPrevious: _back < 3 ? () => setState(() => _back++) : null,
                  onNext: _back > 0 ? () => setState(() => _back--) : null,
                ),
                const SizedBox(height: 14),
                AppCard(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.lavender, AppColors.lavenderDeep],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total earnings',
                        style: TextStyle(color: AppColors.white),
                      ),
                      CountUp(
                        value: month.total(pan),
                        format: rupees,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _back == 0
                            ? '${rupees(month.remaining(pan))} still to be paid to you'
                            : 'Month closed and paid out',
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
                if (_back == 0) ...[
                  const SectionTitle('This week'),
                  AppCard(
                    child: WeekChart(
                      values: state.week,
                      today: today.weekday - 1,
                    ),
                  ),
                ],
                SectionTitle(
                  'Breakdown',
                  action: 'Rate card',
                  onAction: () => context.push(Routes.rateCard),
                ),
                AppCard(
                  child: Column(
                    children: [
                      ValueRow('Job earnings', rupees(month.jobs)),
                      ValueRow('Incentives', rupees(month.incentives)),
                      ValueRow('Referral bonus', rupees(month.referral)),
                      ValueRow('Tips', rupees(month.tips)),
                      ValueRow('Product cost', rupees(-month.productCost)),
                      ValueRow(
                        pan ? 'Tax (1%)' : 'Tax (20%)',
                        rupees(-month.tax(pan)),
                        valueColor: AppColors.danger,
                        hint: pan ? null : 'Add your PAN to reduce this',
                      ),
                      const Divider(color: AppColors.border),
                      ValueRow(
                        'Total earnings',
                        rupees(month.total(pan)),
                        bold: true,
                      ),
                      ValueRow('Cash collected', rupees(-month.cashCollected)),
                      ValueRow('Early payout', rupees(-month.earlyPayout)),
                      ValueRow(
                        'Remaining payout',
                        rupees(month.remaining(pan)),
                        bold: true,
                        valueColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
                const SectionTitle('Rewards and warnings'),

                MenuCard(
                  children: [
                    AppRow(
                      icon: Icons.toll_rounded,

                      title: 'Coins',

                      subtitle: 'Early start, perfect job and streaks',

                      color: AppColors.warning,

                      fill: AppColors.warningSoft,

                      onTap: () => context.push(Routes.coins),
                    ),

                    AppRow(
                      icon: Icons.flag_rounded,

                      title: 'Warnings this month',

                      subtitle: 'Late arrival or a missed shift adds one',

                      color: AppColors.success,

                      fill: AppColors.successSoft,

                      trailing: const Pill(
                        '0',
                        color: AppColors.success,
                        fill: AppColors.successSoft,
                      ),
                    ),
                  ],
                ),

                const SectionTitle('Quick actions'),
                MenuCard(
                  children: [
                    AppRow(
                      icon: Icons.bolt_rounded,
                      title: 'Request early payout',
                      subtitle: 'Available ${rupees(state.earlyLimit)}',
                      onTap: () => context.push(Routes.earlyPayout),
                    ),
                    AppRow(
                      icon: Icons.receipt_long_rounded,
                      title: 'Payout history',
                      onTap: () => context.push(Routes.payouts),
                    ),
                    AppRow(
                      icon: Icons.group_add_rounded,
                      title: 'Referral earnings',
                      onTap: () => ref
                          .read(homeTabProvider.notifier)
                          .show(HomeTabId.refer),
                    ),
                    AppRow(
                      icon: Icons.account_balance_rounded,
                      title: state.payoutAccount == null
                          ? 'Add UPI or bank account'
                          : 'Payout account',
                      subtitle: state.payoutAccount,
                      onTap: () => context.push(Routes.bank),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Seven bars, Monday first. Tap one to read its value.
class WeekChart extends StatefulWidget {
  const WeekChart({super.key, required this.values, required this.today});

  final List<int> values;
  final int today;

  @override
  State<WeekChart> createState() => _WeekChartState();
}

class _WeekChartState extends State<WeekChart> {
  late int _picked = widget.today;

  @override
  Widget build(BuildContext context) {
    final top = widget.values.fold(1, math.max);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${weekdayShort[_picked]}  ${rupees(widget.values[_picked])}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(
          'Week so far: ${rupees(widget.values.fold(0, (a, b) => a + b))}',
          style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Pressable(
                    label: '${weekdayShort[i]}, ${rupees(widget.values[i])}',
                    selected: i == _picked,
                    onTap: () => setState(() => _picked = i),
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: widget.values[i] / top,
                              ),
                              duration: Duration(milliseconds: 500 + i * 70),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) => FractionallySizedBox(
                                heightFactor: math.max(0.04, v),
                                child: Container(
                                  width: 22,
                                  decoration: BoxDecoration(
                                    color: i == _picked
                                        ? AppColors.lavender
                                        : AppColors.softLavender,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          weekdayShort[i].substring(0, 1),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: i == _picked
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
