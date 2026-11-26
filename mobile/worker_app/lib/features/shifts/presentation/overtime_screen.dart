import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/ui.dart';
import '../data/shift_store.dart';

class OvertimeScreen extends ConsumerWidget {
  const OvertimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taken = ref.watch(shiftProvider.select((s) => s.overtime));
    final today = ref.watch(todayProvider);
    // TODO(shifts): load open slots from the scheduling service.
    final slots = [
      ('ot1', today.add(const Duration(days: 1)), '5:00 – 8:00 PM', 480),
      ('ot2', today.add(const Duration(days: 2)), '7:00 – 9:00 AM', 300),
      ('ot3', today.add(const Duration(days: 4)), '10:00 AM – 2:00 PM', 700),
    ];
    return AppPage(
      title: 'Overtime shifts',
      children: [
        const Text(
          'Extra hours you can pick up. Drop them any time before they start.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        for (final (id, date, time, pay) in slots)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayDate(date),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          time,
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Pill(
                          'Earn about ${rupees(pay)}',
                          color: AppColors.success,
                          fill: AppColors.successSoft,
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () =>
                        ref.read(shiftProvider.notifier).toggleOvertime(id),
                    style: FilledButton.styleFrom(
                      backgroundColor: taken.contains(id)
                          ? AppColors.softLavender
                          : AppColors.lavender,
                      foregroundColor: taken.contains(id)
                          ? AppColors.lavenderDeep
                          : AppColors.white,
                    ),
                    child: Text(taken.contains(id) ? 'Drop' : 'Take'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
