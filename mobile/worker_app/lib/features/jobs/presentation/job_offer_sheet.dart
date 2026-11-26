import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/task_art.dart';
import '../../../shared/widgets/ui.dart';
import '../data/work_store.dart';
import '../domain/job.dart';

/// Shows an incoming request. True when accepted; false when declined or the
/// countdown runs out.
Future<bool> showJobOffer(BuildContext context, Job job) async {
  final accepted = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (_) => PopScope(canPop: false, child: _OfferSheet(job)),
  );
  return accepted ?? false;
}

class _OfferSheet extends ConsumerStatefulWidget {
  const _OfferSheet(this.job);

  final Job job;

  @override
  ConsumerState<_OfferSheet> createState() => _OfferSheetState();
}

class _OfferSheetState extends ConsumerState<_OfferSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _countdown;
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _countdown =
        AnimationController(
            vsync: this,
            duration: ref.read(jobTimingProvider).answerWithin,
            // The deadline is real time, even with reduced motion switched on.
            animationBehavior: AnimationBehavior.preserve,
          )
          ..addStatusListener((s) {
            if (s == AnimationStatus.completed) _close(false);
          })
          ..forward();
  }

  void _close(bool accepted) {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.pop(context, accepted);
  }

  @override
  void dispose() {
    _countdown.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final seconds = ref.read(jobTimingProvider).answerWithin.inSeconds;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Pill('New request', icon: Icons.bolt_rounded),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _countdown,
                  builder: (context, _) {
                    final left = (seconds * (1 - _countdown.value)).ceil();
                    return Semantics(
                      label: '$left seconds left to answer',
                      excludeSemantics: true,
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: 1 - _countdown.value,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              backgroundColor: AppColors.softLavender,
                              color: left <= 8
                                  ? AppColors.danger
                                  : AppColors.lavender,
                            ),
                            Center(
                              child: Text(
                                '$left',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.service,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${job.area} · ${job.distanceKm} km · ${job.etaMinutes} min away',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              color: AppColors.softLavender,
              shadow: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Fact('You earn', rupees(job.pay)),
                  _Fact('Duration', '${job.durationMinutes} min'),
                  Column(
                    children: [
                      Row(
                        children: [
                          const CoinIcon(size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '+${job.coins}',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Coins',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final t in job.tasks)
                  Expanded(
                    child: Column(
                      children: [
                        TaskArt(t, size: 52),
                        Text(
                          t.label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => _close(false),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.softLavender,
                      foregroundColor: AppColors.lavenderDeep,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () => _close(true),
                    child: const Text('Accept job'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      ),
    ],
  );
}
