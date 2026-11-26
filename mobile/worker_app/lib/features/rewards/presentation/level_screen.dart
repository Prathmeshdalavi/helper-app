import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/ui.dart';
import '../../earnings/data/rate_card.dart';
import '../data/rewards_store.dart';

class LevelScreen extends ConsumerWidget {
  const LevelScreen({super.key});

  static const _benefits = <(IconData, String, ExpertLevel)>[
    (Icons.health_and_safety_rounded, 'Health cover', ExpertLevel.seed),
    (Icons.shield_rounded, 'Accident cover', ExpertLevel.seed),
    (Icons.bolt_rounded, 'Early payout', ExpertLevel.bloom),
    (Icons.storefront_rounded, 'Store offers', ExpertLevel.bloom),
    (Icons.support_agent_rounded, 'Priority help', ExpertLevel.shine),
    (Icons.cake_rounded, 'Birthday gift', ExpertLevel.shine),
    (Icons.account_balance_rounded, 'Loan help', ExpertLevel.star),
    (Icons.restaurant_rounded, 'Flexible lunch', ExpertLevel.star),
    (Icons.trending_up_rounded, 'Trainer role', ExpertLevel.star),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(rewardsProvider);
    final level = ExpertLevel.forCoins(coins);
    final next = level.next;
    final progress = next == null
        ? 1.0
        : (coins - level.coinsNeeded) / (next.coinsNeeded - level.coinsNeeded);
    return AppPage(
      title: 'My level',
      children: [
        AppCard(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.lavender, AppColors.lavenderDeep],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const IconTile(
                Icons.local_florist_rounded,
                size: 88,
                fill: AppColors.card,
              ),
              const SizedBox(height: 10),
              Text(
                '${level.label} level',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  for (final l in ExpertLevel.values)
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            l == level
                                ? Icons.radio_button_checked_rounded
                                : l.index < level.index
                                ? Icons.check_circle_rounded
                                : Icons.lock_rounded,
                            color: l.index <= level.index
                                ? AppColors.gold
                                : AppColors.lavenderLight,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0, 1)),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(6),
                  backgroundColor: AppColors.white.withValues(alpha: 0.25),
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                next == null
                    ? 'You are at the top level'
                    : '${next.coinsNeeded - coins} more coins to ${next.label}',
                style: const TextStyle(color: AppColors.white),
              ),
            ],
          ),
        ),
        SectionTitle(
          'Benefits',
          action: 'Pay rates',
          onAction: () => context.push(Routes.rateCard),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            for (final (icon, name, from) in _benefits)
              Semantics(
                label: from.index <= level.index
                    ? '$name, unlocked'
                    : '$name, unlocks at ${from.label}',
                excludeSemantics: true,
                child: Opacity(
                  opacity: from.index <= level.index ? 1 : 0.55,
                  child: AppCard(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          from.index <= level.index ? icon : Icons.lock_rounded,
                          color: AppColors.lavender,
                          size: 28,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
