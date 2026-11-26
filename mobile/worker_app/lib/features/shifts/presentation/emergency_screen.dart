import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/ui.dart';
import '../../jobs/data/work_store.dart';
import '../data/shift_store.dart';

/// Ends today's shift early.
class EmergencyLogoutScreen extends ConsumerStatefulWidget {
  const EmergencyLogoutScreen({super.key});

  @override
  ConsumerState<EmergencyLogoutScreen> createState() =>
      _EmergencyLogoutScreenState();
}

class _EmergencyLogoutScreenState extends ConsumerState<EmergencyLogoutScreen> {
  static const _reasons = [
    'I am unwell',
    'Family emergency',
    'I feel unsafe',
    'Something else',
  ];
  int? _reason;

  @override
  Widget build(BuildContext context) {
    final done = ref.watch(shiftProvider.select((s) => s.loggedOutEarly));
    final busy = ref.watch(workProvider.select((w) => w.active != null));
    return AppPage(
      title: 'Emergency logout',
      bottom: done
          ? null
          : FilledButton(
              onPressed: _reason == null || busy
                  ? null
                  : () {
                      ref.read(workProvider.notifier).setOnline(false);
                      ref.read(shiftProvider.notifier).logOutEarly();
                      toast(context, 'Shift ended (demo)');
                      context.pop();
                    },
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('End my shift now'),
            ),
      children: [
        if (done)
          const EmptyState(
            icon: Icons.logout_rounded,
            title: 'Shift ended',
            message: 'Take care. We will see you next shift.',
          )
        else ...[
          if (busy)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Pill(
                'Finish or hand over your job first. Call support if you are unsafe.',
                icon: Icons.info_rounded,
                color: AppColors.warning,
                fill: AppColors.warningSoft,
              ),
            ),
          const Text(
            'Why do you need to stop?',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          MenuCard(
            children: [
              for (var i = 0; i < _reasons.length; i++)
                AppRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: _reasons[i],
                  onTap: () => setState(() => _reason = i),
                  trailing: Icon(
                    _reason == i
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: AppColors.lavender,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
