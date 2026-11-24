import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../auth/data/session.dart';
import '../../home/presentation/widgets/common.dart';

/// Log out and the policies.
class ManageAccountScreen extends ConsumerWidget {
  const ManageAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumScope(
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: SafeArea(
          child: Column(
            children: [
              const PremiumTopBar(title: 'Manage account'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
                  children: [
                    const _Heading('Actions'),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListRow(
                        icon: Icons.logout_rounded,
                        title: 'Log out',
                        divider: false,
                        onTap: () => _confirmLogout(context, ref),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _Heading('Policies & others'),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ListRow(
                            icon: Icons.description_outlined,
                            title: 'Terms of use',
                            onTap: () => comingSoon(context, 'Terms of use'),
                          ),
                          ListRow(
                            icon: Icons.lock_outline_rounded,
                            title: 'Privacy policy',
                            onTap: () => comingSoon(context, 'Privacy policy'),
                          ),
                          ListRow(
                            icon: Icons.event_busy_outlined,
                            title: 'Refund & cancellation policy',
                            onTap: () => _showRefundPolicy(context),
                          ),
                          ListRow(
                            icon: Icons.delete_outline_rounded,
                            title: 'Manage data',
                            divider: false,
                            onTap: () => comingSoon(context, 'Manage data'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showPremiumSheet<void>(
      context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log out?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'You can sign back in any time with your phone number.',
              style: TextStyle(fontSize: 14, height: 1.4, color: AppInk.muted),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: 'Stay',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    label: 'Log out',
                    color: premiumRed,
                    onPressed: () {
                      // TODO(auth): also clear tokens and call POST /auth/logout.
                      ref.read(sessionProvider.notifier).signOut();
                      Navigator.of(ctx).pop();
                      context.go(Routes.login);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRefundPolicy(BuildContext context) {
    showPremiumSheet<void>(
      context,
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refund & cancellation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 16),
            _PolicyPoint(
              'Scheduled bookings',
              'Cancel or reschedule for free until 2 hours before the start '
                  'time. After that, cancelling costs ₹49.',
            ),
            _PolicyPoint(
              'Instant bookings',
              'Cancel for free until an expert is assigned. After that, '
                  'cancelling costs ₹49.',
            ),
            _PolicyPoint(
              'Once your expert arrives',
              'The full service charge applies.',
            ),
            _PolicyPoint(
              'Refunds',
              'Wallet refunds are instant. Other payment methods can take 5 '
                  'to 10 business days.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );
}

class _PolicyPoint extends StatelessWidget {
  const _PolicyPoint(this.title, this.text);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 3),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13.5,
            height: 1.45,
            color: AppInk.muted,
          ),
        ),
      ],
    ),
  );
}
