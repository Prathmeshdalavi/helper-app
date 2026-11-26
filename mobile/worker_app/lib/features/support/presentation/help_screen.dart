import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/ui.dart';
import 'sos_sheet.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faq = [
    (
      'When am I paid?',
      'Weekly, every Wednesday, into your linked account. Early payout is available for part of your earnings.',
    ),
    (
      'The customer is not answering',
      'Wait at the door and call twice. After ten minutes call support; you will not be penalised.',
    ),
    (
      'My payout is wrong',
      'Check the breakdown in Earnings first, then raise it with support and mention the date.',
    ),
    (
      'How do I change my shift?',
      'Ask your hub lead, or apply for leave if you cannot come in.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Help and support',
      children: [
        MenuCard(
          children: [
            // TODO(support): dial the helpline and open the support chat.
            AppRow(
              icon: Icons.call_rounded,
              title: 'Call support',
              subtitle: '7 AM to 10 PM',
              onTap: () => toast(context, 'Would call support (demo)'),
            ),
            AppRow(
              icon: Icons.chat_rounded,
              title: 'Chat with us',
              subtitle: 'Usually replies in a few minutes',
              onTap: () => toast(context, 'Chat is not built yet'),
            ),
            AppRow(
              icon: Icons.sos_rounded,
              title: 'Emergency SOS',
              color: AppColors.danger,
              fill: AppColors.dangerSoft,
              onTap: () => showSosSheet(context),
            ),
          ],
        ),
        const SectionTitle('Common questions'),
        for (final (q, a) in _faq)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: AppColors.clear,
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text(
                    q,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a, style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
