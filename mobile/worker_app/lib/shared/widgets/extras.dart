import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import '../../app/router/routes.dart';
import 'ui.dart';

class Tip {
  const Tip(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}

/// "Helpful tips" bubbles. Each opens a short explanation.
class TipsRow extends StatelessWidget {
  const TipsRow(this.tips, {super.key});

  final List<Tip> tips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Helpful tips'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final tip in tips)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Pressable(
                    label: 'Tip: ${tip.title}',
                    onTap: () => showAppSheet<void>(
                      context,
                      builder: (_) => Column(
                        children: [
                          IconTile(tip.icon, size: 72),
                          const SizedBox(height: 14),
                          Text(
                            tip.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tip.body,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    child: SizedBox(
                      width: 78,
                      child: Column(
                        children: [
                          Container(
                            width: 66,
                            height: 66,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.softLavender,
                                  AppColors.roseSoft,
                                ],
                              ),
                              boxShadow: softShadow(),
                            ),
                            child: Icon(tip.icon, color: AppColors.lavender),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            tip.title,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Header shortcut to the open overtime shifts.
class OvertimeButton extends StatelessWidget {
  const OvertimeButton({super.key});

  @override
  Widget build(BuildContext context) => Pressable(
    label: 'Overtime shifts',
    onTap: () => context.push(Routes.overtime),
    child: const Pill('Overtime', icon: Icons.more_time_rounded),
  );
}
