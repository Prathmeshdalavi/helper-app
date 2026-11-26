import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../data/rewards_store.dart';

class CoinsScreen extends ConsumerStatefulWidget {
  const CoinsScreen({super.key});

  @override
  ConsumerState<CoinsScreen> createState() => _CoinsScreenState();
}

class _CoinsScreenState extends ConsumerState<CoinsScreen> {
  static const _ways = <(IconData, String, String)>[
    (
      Icons.alarm_rounded,
      'Early start',
      '2 coins when you go online before your shift',
    ),
    (Icons.auto_awesome_rounded, 'Perfect job', '3 coins for a 5 star rating'),
    (
      Icons.local_fire_department_rounded,
      'Daily streak',
      '5 coins for six days in a row',
    ),
  ];

  int _weeksBack = 0;
  int _way = 0;

  /// Demo history: what was earned on a past day.
  int _coinsOn(DateTime day) =>
      day.weekday == DateTime.sunday ? 0 : 2 + (day.day % 3) * 2;

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(rewardsProvider.select((r) => r.coins));
    final today = ref.watch(todayProvider);
    final monday = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday - 1) - 7 * _weeksBack,
    );
    final days = [
      for (var i = 0; i < 7; i++)
        DateTime(monday.year, monday.month, monday.day + i),
    ];
    return AppPage(
      title: 'My coins',
      bottom: FilledButton.icon(
        onPressed: () => context.push(Routes.store),
        icon: const Icon(Icons.storefront_rounded),
        label: const Text('Spend in the store'),
      ),
      children: [
        AppCard(
          color: AppColors.warningSoft,
          shadow: false,
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              SizedBox(
                height: 92,
                child: Loop(
                  duration: const Duration(milliseconds: 3200),
                  builder: (context, t) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 56,
                        top: 8 + 10 * (t - 0.5).abs(),
                        child: CoinIcon(size: 28, turn: (t + 0.2) % 1),
                      ),
                      CoinIcon(size: 84, turn: t),
                      Positioned(
                        right: 56,
                        bottom: 6 + 12 * (t - 0.5).abs(),
                        child: CoinIcon(size: 34, turn: (t + 0.6) % 1),
                      ),
                    ],
                  ),
                ),
              ),
              CountUp(
                value: coins,
                format: (v) => '$v',
                style: const TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text('coins to spend'),
            ],
          ),
        ),
        const SectionTitle('Ways to earn'),
        ChoiceChips(
          options: [for (final w in _ways) w.$2],
          selected: _way,
          onSelected: (i) => setState(() => _way = i),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Row(
            children: [
              IconTile(
                _ways[_way].$1,
                color: AppColors.warning,
                fill: AppColors.warningSoft,
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(_ways[_way].$3)),
            ],
          ),
        ),
        const SectionTitle('Day by day'),
        Pager(
          label: '${shortDate(days.first)} – ${shortDate(days.last)}',
          onPrevious: _weeksBack < 4
              ? () => setState(() => _weeksBack++)
              : null,
          onNext: _weeksBack > 0 ? () => setState(() => _weeksBack--) : null,
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
          child: Row(
            children: [
              for (final d in days)
                Expanded(
                  child: Semantics(
                    label:
                        '${dayDate(d)}: ${d.isBefore(today) ? '${_coinsOn(d)} coins' : 'not earned yet'}',
                    excludeSemantics: true,
                    child: Column(
                      children: [
                        Text(
                          weekdayShort[d.weekday - 1],
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${d.day}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: d == today
                                ? AppColors.lavender
                                : AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Opacity(
                          opacity: d.isBefore(today) && _coinsOn(d) > 0
                              ? 1
                              : 0.25,
                          child: const CoinIcon(size: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          d.isBefore(today) ? '+${_coinsOn(d)}' : '–',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
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
