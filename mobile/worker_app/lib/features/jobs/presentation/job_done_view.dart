import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../domain/job.dart';

/// Celebration, pay summary and a rating for the customer.
class JobDoneView extends StatefulWidget {
  const JobDoneView({super.key, required this.job, required this.onDone});

  final Job job;
  final VoidCallback onDone;

  @override
  State<JobDoneView> createState() => _JobDoneViewState();
}

class _JobDoneViewState extends State<JobDoneView> {
  int _stars = 0;

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onDone();
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                children: [
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.3, end: 1),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.elasticOut,
                      builder: (context, v, child) =>
                          Transform.scale(scale: v, child: child),
                      child: const IconTile(
                        Icons.check_rounded,
                        size: 108,
                        color: AppColors.white,
                        fill: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Job completed',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 22),
                  AppCard(
                    child: Column(
                      children: [
                        const Text(
                          'You earned',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        CountUp(
                          value: job.pay,
                          format: rupees,
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Loop(
                              duration: const Duration(milliseconds: 1600),
                              builder: (context, t) =>
                                  CoinIcon(size: 24, turn: t),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${job.coins} coins',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      children: [
                        Text(
                          'How was ${job.customer}?',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 1; i <= 5; i++)
                              IconButton(
                                tooltip: 'Rate $i of 5',
                                onPressed: () => setState(() => _stars = i),
                                icon: Icon(
                                  i <= _stars
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  size: 34,
                                  color: AppColors.gold,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // TODO(jobs): POST the rating with the job id.
                  FilledButton(
                    onPressed: widget.onDone,
                    child: const Text('Back to home'),
                  ),
                ],
              ),
            ),
            const Positioned.fill(child: ConfettiBurst()),
          ],
        ),
      ),
    );
  }
}
