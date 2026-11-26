import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/extras.dart';
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
    final mine = ExpertLevel.forCoins(ref.watch(rewardsProvider));
    final level = ExpertLevel.values[_picked ?? mine.index];
    const extra = ExpertLevel.distanceMax - ExpertLevel.distanceMin;
    String hr(int v) => rupees(v);
    return AppPage(
      title: 'Rate card',
      actions: const [OvertimeButton()],
      children: [
        ChoiceChips(
          options: [
            for (final l in ExpertLevel.values)
              l == mine ? '${l.label} (you)' : l.label,
          ],
          selected: level.index,
          onSelected: (i) => setState(() => _picked = i),
        ),
        const SectionTitle('Pay per hour'),
        RateTable(
          rows: [
            (
              'Work',
              [
                hr(level.weekdayWork),
                hr(level.weekendWork),
                hr(level.weekendWork),
              ],
            ),
            ('+ Check in', List.filled(3, hr(ExpertLevel.checkInBonus))),
            (
              '+ Distance',
              List.filled(
                3,
                '${hr(ExpertLevel.distanceMin)}–${ExpertLevel.distanceMax}',
              ),
            ),
            ('+ Rain', List.filled(3, hr(ExpertLevel.rainBonus))),
          ],
          total: (
            'You get',
            [
              for (final base in [
                level.weekdayHourly,
                level.weekendHourly,
                level.weekendHourly,
              ])
                '${hr(base)}–${base + extra}',
            ],
          ),
        ),
        const SectionTitle('Daily minimum'),
        RateTable(
          rows: const [],
          total: (
            '8 hours',
            [
              rupees(level.weekdayMinimum),
              rupees(level.weekendMinimum),
              rupees(level.weekendMinimum),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Check in pays when you arrive on time. Distance depends on how far you travel, and rain pays only while it is raining. On a full shift you get your job earnings or the daily minimum, whichever is higher. Sample rates for the demo.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

/// Weekday / Saturday / Sunday grid with a highlighted last row.
class RateTable extends StatelessWidget {
  const RateTable({super.key, required this.rows, required this.total});

  final List<(String, List<String>)> rows;
  final (String, List<String>) total;

  @override
  Widget build(BuildContext context) {
    TableRow row(
      String head,
      List<String> cells, {
      Color? fill,
      bool bold = false,
    }) => TableRow(
      decoration: BoxDecoration(color: fill),
      children: [
        for (final (i, text) in [head, ...cells].indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: i == 0 ? Alignment.centerLeft : Alignment.center,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: bold || i == 0
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(1.4)},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: const TableBorder(
            horizontalInside: BorderSide(color: AppColors.border),
          ),
          children: [
            row(
              '',
              const ['Mon–Fri', 'Sat', 'Sun'],
              fill: AppColors.softLavender,
              bold: true,
            ),
            for (final (head, cells) in rows) row(head, cells),
            row(total.$1, total.$2, fill: AppColors.successSoft, bold: true),
          ],
        ),
      ),
    );
  }
}
