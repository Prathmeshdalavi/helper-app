import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/extras.dart';
import '../../../shared/widgets/ui.dart';
import '../data/ratings.dart';

class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  int _back = 0;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final month = DateTime(today.year, today.month - _back);
    final rating = monthRatings[_back];
    final most = rating.counts.fold(1, math.max);
    const title = TextStyle(fontSize: 17, fontWeight: FontWeight.w700);
    return AppPage(
      title: 'Performance',
      actions: const [OvertimeButton()],
      bottom: FilledButton(
        onPressed: () => context.push(Routes.training),
        child: const Text('Improve with training'),
      ),
      children: [
        AppCard(
          child: Column(
            children: [
              Pager(
                label: '${monthNames[month.month - 1]} ${month.year}',
                onPrevious: _back < monthRatings.length - 1
                    ? () => setState(() => _back++)
                    : null,
                onNext: _back > 0 ? () => setState(() => _back--) : null,
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                key: ValueKey(_back),
                tween: Tween(begin: 0, end: rating.average),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, v, _) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      v.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.star_rounded,
                      size: 44,
                      color: AppColors.gold,
                    ),
                  ],
                ),
              ),
              const Text(
                'Monthly rating',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            children: [
              const Text('Ratings breakdown', style: title),
              Text(
                'Based on ${rating.rated} rated jobs',
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 10),
              for (var i = 0; i < 5; i++)
                Semantics(
                  label: '${5 - i} stars: ${rating.counts[i]} jobs',
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 17,
                          color: AppColors.gold,
                        ),
                        SizedBox(
                          width: 22,
                          child: Text(
                            ' ${5 - i}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: rating.counts[i] / most,
                            ),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, v, _) => LinearProgressIndicator(
                              value: v,
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
                              backgroundColor: AppColors.softLavender,
                              color: AppColors.lavender,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${rating.counts[i]}',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          color: AppColors.successSoft,
          shadow: false,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Text('Customers loved', style: title),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final tag in rating.loved)
                      Pill(
                        tag,
                        icon: Icons.favorite_rounded,
                        color: AppColors.success,
                        fill: AppColors.card,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        AppCard(
          color: AppColors.warningSoft,
          shadow: false,
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                const Text('How to get even better', style: title),
                const SizedBox(height: 8),
                Text(rating.advice, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
