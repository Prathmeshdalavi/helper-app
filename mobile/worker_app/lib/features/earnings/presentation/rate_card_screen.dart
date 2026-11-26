import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/ui.dart';
import '../../rewards/data/rewards_store.dart';
import '../data/rate_card.dart';

class RateCardScreen extends ConsumerStatefulWidget {
  const RateCardScreen({super.key});

  @override
  ConsumerState<RateCardScreen> createState() => _RateCardScreenState();
}

class _RateCardScreenState extends ConsumerState<RateCardScreen> {
  int? _picked;

  @override
  Widget build(BuildContext context) {
    final mine = ExpertLevel.forCoins(
      ref.watch(rewardsProvider.select((r) => r.coins)),
    );
    final level = ExpertLevel.values[_picked ?? mine.index];
    return AppPage(
      title: 'Rate card',
      children: [
        ChoiceChips(
          options: [
            for (final l in ExpertLevel.values)
              l == mine ? '${l.label} (you)' : l.label,
          ],
          selected: level.index,
          onSelected: (i) => setState(() => _picked = i),
        ),
        const SectionTitle('Hourly pay'),
        AppCard(
          child: Column(
            children: [
              ValueRow(
                'Monday to Friday',
                '${rupees(level.weekdayHourly)} / hr',
              ),
              ValueRow(
                'Saturday and Sunday',
                '${rupees(level.weekendHourly)} / hr',
              ),
              ValueRow(
                'Festival days',
                '${rupees(level.weekendHourly + 30)} / hr',
              ),
            ],
          ),
        ),
        const SectionTitle('Daily minimum (8 hour shift)'),
        AppCard(
          child: Column(
            children: [
              ValueRow('Monday to Friday', rupees(level.weekdayMinimum)),
              ValueRow('Saturday and Sunday', rupees(level.weekendMinimum)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'You get the higher of your job earnings or the daily minimum when you complete the full shift. Demo rates.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
