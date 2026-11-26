import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/extras.dart';
import '../../../shared/widgets/ui.dart';
import '../data/shift_store.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shift = ref.watch(shiftProvider);
    final today = ref.watch(todayProvider);
    final tomorrow = today.add(const Duration(days: 1));
    final present = shift.tomorrowPresent;

    Widget choice(
      String label,
      bool value,
      Color color,
      IconData icon,
    ) => Expanded(
      child: FilledButton.icon(
        onPressed: () {
          ref.read(shiftProvider.notifier).markTomorrow(value);
          toast(
            context,
            value ? 'See you tomorrow' : 'Marked absent for tomorrow',
          );
        },
        style: FilledButton.styleFrom(
          backgroundColor: present == value ? color : AppColors.softLavender,
          foregroundColor: present == value ? AppColors.white : AppColors.text,
        ),
        icon: Icon(icon),
        label: Text(label),
      ),
    );

    // This month's calendar. Past weekdays count as worked in the demo.
    final first = DateTime(today.year, today.month);
    final days = DateTime(today.year, today.month + 1, 0).day;
    final leaveDays = {
      for (var d = 1; d <= days; d++)
        if (shift.leaves.any(
          (l) => l.covers(DateTime(today.year, today.month, d)),
        ))
          d,
    };

    return AppPage(
      title: 'Attendance and shift',
      actions: const [OvertimeButton()],
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tomorrow · ${dayDate(tomorrow)}",
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              const Text(
                '9:00 AM – 5:00 PM',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  choice(
                    'Present',
                    true,
                    AppColors.success,
                    Icons.check_rounded,
                  ),
                  const SizedBox(width: 12),
                  choice(
                    'Absent',
                    false,
                    AppColors.danger,
                    Icons.close_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        SectionTitle('${monthNames[today.month - 1]} so far'),
        AppCard(
          child: GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              for (final d in weekdayShort)
                Center(
                  child: Text(
                    d.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              for (var i = 1; i < first.weekday; i++) const SizedBox.shrink(),
              for (var d = 1; d <= days; d++)
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: leaveDays.contains(d)
                        ? AppColors.roseSoft
                        : d < today.day &&
                              DateTime(today.year, today.month, d).weekday !=
                                  DateTime.sunday
                        ? AppColors.successSoft
                        : d == today.day
                        ? AppColors.lavender
                        : AppColors.clear,
                  ),
                  child: Text(
                    '$d',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: d == today.day ? AppColors.white : AppColors.text,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Wrap(
          spacing: 8,
          children: [
            Pill(
              'Worked',
              color: AppColors.success,
              fill: AppColors.successSoft,
            ),
            Pill('Leave', color: AppColors.roseDeep, fill: AppColors.roseSoft),
          ],
        ),
        const SizedBox(height: 18),
        MenuCard(
          children: [
            AppRow(
              icon: Icons.beach_access_rounded,
              title: 'Leaves',
              onTap: () => context.push(Routes.leave),
            ),
            AppRow(
              icon: Icons.more_time_rounded,
              title: 'Overtime shifts',
              onTap: () => context.push(Routes.overtime),
            ),
          ],
        ),
      ],
    );
  }
}
