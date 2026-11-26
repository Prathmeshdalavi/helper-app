import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/ui.dart';
import '../data/shift_store.dart';

class LeaveScreen extends ConsumerWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaves = ref.watch(shiftProvider.select((s) => s.leaves));
    return AppPage(
      title: 'Leaves',
      floating: FloatingActionButton.extended(
        onPressed: () =>
            showAppSheet<void>(context, builder: (_) => const _ApplyLeave()),
        backgroundColor: AppColors.lavender,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Apply leave'),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      children: [
        if (leaves.isEmpty)
          const EmptyState(
            icon: Icons.beach_access_rounded,
            title: 'No leaves yet',
            message: 'Your leave requests show up here.',
          )
        else
          MenuCard(
            children: [
              for (final l in leaves)
                AppRow(
                  icon: Icons.event_busy_rounded,
                  title: dayDate(l.date),
                  subtitle: l.reason,
                  trailing: l.approved
                      ? const Pill(
                          'Approved',
                          color: AppColors.success,
                          fill: AppColors.successSoft,
                        )
                      : const Pill(
                          'Pending',
                          color: AppColors.warning,
                          fill: AppColors.warningSoft,
                        ),
                ),
            ],
          ),
      ],
    );
  }
}

class _ApplyLeave extends ConsumerStatefulWidget {
  const _ApplyLeave();

  @override
  ConsumerState<_ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends ConsumerState<_ApplyLeave> {
  static const _reasons = [
    ShiftNotifier.careLeaveReason,
    'Sick',
    'Family',
    'Other',
  ];
  int _day = 0;
  int _reason = 0;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final days = [
      for (var i = 1; i <= 14; i++)
        DateTime(today.year, today.month, today.day + i),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Apply leave',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        const Text('Day', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ChoiceChips(
          options: [for (final d in days) dayDate(d)],
          selected: _day,
          onSelected: (i) => setState(() {
            _day = i;
            _error = null;
          }),
        ),
        const SizedBox(height: 16),
        const Text('Reason', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ChoiceChips(
          options: _reasons,
          selected: _reason,
          onSelected: (i) => setState(() {
            _reason = i;
            _error = null;
          }),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: const TextStyle(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () {
            final error = ref
                .read(shiftProvider.notifier)
                .applyLeave(days[_day], _reasons[_reason]);
            if (error != null) {
              setState(() => _error = error);
              return;
            }
            Navigator.pop(context);
          },
          child: const Text('Submit request'),
        ),
      ],
    );
  }
}
