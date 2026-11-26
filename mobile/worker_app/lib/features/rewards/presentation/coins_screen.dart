import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/extras.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../data/coin_history.dart';
import '../data/rewards_store.dart';

class CoinsScreen extends ConsumerStatefulWidget {
  const CoinsScreen({super.key});

  @override
  ConsumerState<CoinsScreen> createState() => _CoinsScreenState();
}

class _CoinsScreenState extends ConsumerState<CoinsScreen> {
  int _weeksBack = 0;

  static (IconData, Color, Color) _look(CoinSource s) => switch (s) {
    CoinSource.earlyStart => (
      Icons.login_rounded,
      AppColors.info,
      AppColors.infoSoft,
    ),
    CoinSource.perfectJob => (
      Icons.thumb_up_rounded,
      AppColors.success,
      AppColors.successSoft,
    ),
    CoinSource.streak => (
      Icons.local_fire_department_rounded,
      AppColors.roseDeep,
      AppColors.roseSoft,
    ),
  };

  void _explain(CoinSource s) {
    final (icon, color, fill) = _look(s);
    showAppSheet<void>(
      context,
      builder: (_) => Column(
        children: [
          IconTile(icon, size: 72, color: color, fill: fill),
          const SizedBox(height: 14),
          Text(
            s.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            s.how,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _showDay(DateTime day, Map<CoinSource, int> parts) {
    showAppSheet<void>(
      context,
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dayDate(day),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (parts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No coins on this day.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          else
            for (final e in parts.entries) ValueRow(e.key.title, '+${e.value}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(rewardsProvider);
    final today = ref.watch(todayProvider);
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1) - 7 * _weeksBack,
    );
    // Only days that have started, oldest first.
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(monday.year, monday.month, monday.day + i),
    ].where((d) => !d.isAfter(today)).toList();
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);

    return AppPage(
      title: 'My coins',
      actions: const [OvertimeButton()],
      bottom: FilledButton.icon(
        onPressed: () => context.push(Routes.level),
        icon: const Icon(Icons.local_florist_rounded),
        label: const Text('See what coins unlock'),
      ),
      children: [
        AppCard(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.lavender, AppColors.lavenderDeep],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'HerCare coins',
                      style: TextStyle(color: AppColors.white),
                    ),
                    CountUp(
                      value: coins,
                      format: (v) => '$v',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const Text(
                      'earned so far',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 140,
                height: 120,
                child: Loop(
                  duration: const Duration(milliseconds: 3600),
                  builder: (context, t) {
                    final bob = (t - 0.5).abs();
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 0,
                          bottom: 4 + 14 * bob,
                          child: CoinIcon(size: 34, turn: (t + 0.25) % 1),
                        ),
                        CoinIcon(size: 86, turn: t),
                        Positioned(
                          right: 0,
                          top: 2 + 16 * bob,
                          child: CoinIcon(size: 28, turn: (t + 0.6) % 1),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Ways to earn'),
        Row(
          children: [
            for (final s in CoinSource.values)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: s == CoinSource.values.last ? 0 : 12,
                  ),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 4,
                    ),
                    onTap: () => _explain(s),
                    child: Column(
                      children: [
                        IconTile(
                          _look(s).$1,
                          size: 50,
                          color: _look(s).$2,
                          fill: _look(s).$3,
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            s.title,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SectionTitle('Day by day'),
        Pager(
          label: '${shortDate(monday)} to ${shortDate(sunday)}',
          onPrevious: _weeksBack < 4
              ? () => setState(() => _weeksBack++)
              : null,
          onNext: _weeksBack > 0 ? () => setState(() => _weeksBack--) : null,
        ),
        const SizedBox(height: 12),
        MenuCard(
          children: [
            for (final d in days)
              Builder(
                builder: (context) {
                  final parts = coinsOn(d);
                  final total = parts.values.fold(0, (a, b) => a + b);
                  return Pressable(
                    label: '${dayDate(d)}, $total coins',
                    onTap: () => _showDay(d, parts),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              dayDate(d),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: total == 0
                                    ? AppColors.textMuted
                                    : AppColors.text,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: total == 0
                                  ? AppColors.background
                                  : AppColors.warningSoft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Opacity(
                                  opacity: total == 0 ? 0.3 : 1,
                                  child: const CoinIcon(size: 18),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$total',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        const TipsRow([
          Tip(
            Icons.toll_rounded,
            'What coins do',
            'Coins raise your level. Higher levels pay more per hour and unlock benefits.',
          ),
          Tip(
            Icons.alarm_rounded,
            'Start early',
            'Go online a few minutes before your shift to collect the early start coins.',
          ),
          Tip(
            Icons.star_rounded,
            'Five stars',
            'Greet politely, finish every task and show the customer your work.',
          ),
        ]),
      ],
    );
  }
}
