import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/ui.dart';

/// TODO(ratings): load from GET /experts/me/ratings.
class PerformanceScreen extends ConsumerStatefulWidget {
  const PerformanceScreen({super.key});

  @override
  ConsumerState<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends ConsumerState<PerformanceScreen> {
  static const _ratings = [4.8, 4.7, 4.6, 4.7];
  static const _breakdown = [
    ('On time', 0.96),
    ('Work quality', 0.93),
    ('Behaviour', 0.99),
    ('Uniform and hygiene', 0.88),
  ];
  static const _feedback = [
    ('Meera', 5, 'Very neat work, the kitchen looks new.'),
    ('Sana', 5, 'Polite and on time. Please send her again.'),
    ('Ritu', 4, 'Good work. Came ten minutes late.'),
  ];

  int _back = 0;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final month = DateTime(today.year, today.month - _back);
    return AppPage(
      title: 'Performance',
      bottom: FilledButton(
        onPressed: () => context.push(Routes.training),
        child: const Text('Improve with training'),
      ),
      children: [
        Pager(
          label: '${monthNames[month.month - 1]} ${month.year}',
          onPrevious: _back < _ratings.length - 1
              ? () => setState(() => _back++)
              : null,
          onNext: _back > 0 ? () => setState(() => _back--) : null,
        ),
        const SizedBox(height: 14),
        AppCard(
          color: AppColors.warningSoft,
          shadow: false,
          child: Column(
            children: [
              Text(
                '${_ratings[_back]}',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= _ratings[_back].round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: AppColors.gold,
                      size: 28,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Monthly rating',
                style: TextStyle(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        const SectionTitle('Breakdown'),
        AppCard(
          child: Column(
            children: [
              for (final (name, base) in _breakdown)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Builder(
                    builder: (context) {
                      final score = base - _back * 0.02;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(name)),
                              Text(
                                '${(score * 100).round()}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: score),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, v, _) => LinearProgressIndicator(
                              value: v,
                              minHeight: 8,
                              semanticsLabel: name,
                              borderRadius: BorderRadius.circular(4),
                              backgroundColor: AppColors.softLavender,
                              color: score >= 0.9
                                  ? AppColors.success
                                  : AppColors.gold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SectionTitle('What customers said'),
        for (final (name, stars, text) in _feedback)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.gold,
                      ),
                      Text(' $stars'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
