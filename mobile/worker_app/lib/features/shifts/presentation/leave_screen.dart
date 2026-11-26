import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
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
      title: 'Your leaves',
      actions: [
        TextButton.icon(
          onPressed: () => context.push(Routes.help),
          icon: const Icon(Icons.headset_mic_rounded, size: 18),
          label: const Text('Help'),
        ),
      ],
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
                  title: l.date == l.until
                      ? dayDate(l.date)
                      : '${dayDate(l.date)} to ${dayDate(l.until)}',
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
  DateTime? _from;
  DateTime? _to;
  int _reason = 0;
  String? _error;

  Future<void> _pick({required bool start}) async {
    final today = ref.read(todayProvider);
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final last = DateTime(today.year, today.month, today.day + 90);
    final first = start ? tomorrow : _from ?? tomorrow;
    final current = start ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      initialDate: current != null && !current.isBefore(first)
          ? current
          : first,
      helpText: start ? 'First day of leave' : 'Last day of leave',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _error = null;
      if (start) {
        _from = picked;
        if (_to == null || _to!.isBefore(picked)) _to = picked;
      } else {
        _to = picked;
      }
    });
  }

  Widget _dateBox(String label, DateTime? value, VoidCallback onTap) =>
      Pressable(
        label: value == null ? '$label date' : '$label ${dayDate(value)}',
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.softLavender,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    Text(
                      value == null ? 'Choose' : dayDate(value),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.calendar_month_rounded,
                color: AppColors.lavender,
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final from = _from;
    final to = _to;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Apply leave',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _dateBox('From', from, () => _pick(start: true))),
            const SizedBox(width: 12),
            Expanded(child: _dateBox('To', to, () => _pick(start: false))),
          ],
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
          onPressed: from == null || to == null
              ? null
              : () {
                  final error = ref
                      .read(shiftProvider.notifier)
                      .applyLeave(from, to, _reasons[_reason]);
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
