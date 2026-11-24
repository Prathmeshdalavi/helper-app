import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../data/booking_store.dart';

/// "How would you like to book [service]?": Schedule or Instant.
Future<void> showBookSheet(
  BuildContext context,
  WidgetRef ref, {
  required String service,
}) {
  ref.read(selectedServiceProvider.notifier).set(service);
  return showPremiumSheet<void>(
    context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book $service',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose when you would like your helper.',
            style: TextStyle(fontSize: 13.5, color: AppInk.muted),
          ),
          const SizedBox(height: 18),
          _Choice(
            icon: Icons.schedule_rounded,
            title: 'Schedule',
            subtitle: 'Pick a day and a time that suits you',
            onTap: () {
              Navigator.of(ctx).pop();
              context.push(Routes.schedule);
            },
          ),
          const SizedBox(height: 10),
          _Choice(
            icon: Icons.bolt_rounded,
            title: 'Instant',
            subtitle: 'The nearest helper, in about 9 minutes',
            onTap: () {
              Navigator.of(ctx).pop();
              context.push(Routes.instant);
            },
          ),
        ],
      ),
    ),
  );
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppInk.muted),
        ],
      ),
    );
  }
}
