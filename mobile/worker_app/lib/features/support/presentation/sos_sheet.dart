import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/ui.dart';

/// Emergency options. TODO(safety): dial the numbers, share live location and
/// alert the safety desk. The demo only says what would happen.
Future<void> showSosSheet(BuildContext context) => showAppSheet<void>(
  context,
  builder: (sheet) {
    void act(String message) {
      Navigator.pop(sheet);
      toast(context, message);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Are you safe?',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Demo only: nothing is sent or dialled yet.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 10),
        AppRow(
          icon: Icons.local_police_rounded,
          title: 'Call police (112)',
          color: AppColors.danger,
          fill: AppColors.dangerSoft,
          onTap: () => act('Would call 112 (demo)'),
        ),
        AppRow(
          icon: Icons.support_agent_rounded,
          title: 'Call HerCare safety desk',
          color: AppColors.danger,
          fill: AppColors.dangerSoft,
          onTap: () => act('Would call the safety desk (demo)'),
        ),
        AppRow(
          icon: Icons.share_location_rounded,
          title: 'Share my live location',
          color: AppColors.danger,
          fill: AppColors.dangerSoft,
          onTap: () => act('Would share your location (demo)'),
        ),
      ],
    );
  },
);
