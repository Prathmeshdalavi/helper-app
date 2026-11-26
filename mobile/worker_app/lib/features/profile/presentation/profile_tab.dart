import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/clock.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/data/session.dart';
import '../../earnings/data/earnings_store.dart';
import '../../earnings/data/rate_card.dart';
import '../../home/presentation/alert_carousel.dart';
import '../../home/presentation/home_tab_provider.dart';
import '../../jobs/data/work_store.dart';
import '../../onboarding/data/kyc_store.dart';
import '../../refer/data/refer_store.dart';
import '../../rewards/data/rewards_store.dart';
import '../../shifts/data/shift_store.dart';
import '../../benefits/data/nominee_store.dart';
import '../../shop/data/shop_store.dart';
import '../../support/data/training_store.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  static const version = '0.1.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final level = ExpertLevel.forCoins(ref.watch(rewardsProvider));
    final today = ref.watch(todayProvider);
    ref.watch(shiftProvider);
    final careUsed = ref.read(shiftProvider.notifier).careLeaveUsed(today);

    AppRow row(IconData icon, String title, String route, [String? subtitle]) =>
        AppRow(
          icon: icon,
          title: title,
          subtitle: subtitle,
          onTap: () => context.push(route),
        );

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const PageHeader(title: 'Profile'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              children: [
                AppCard(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.softLavender, AppColors.roseSoft],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const ExpertAvatar(size: 70),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.name.isEmpty
                                      ? 'HerCare expert'
                                      : session.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'ID ${session.expertId}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Pill(
                                  'Period leave $careUsed/${ShiftNotifier.careLeavePerMonth} used',
                                  icon: Icons.favorite_rounded,
                                  color: AppColors.roseDeep,
                                  fill: AppColors.card,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Pressable(
                        onTap: () => context.push(Routes.level),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_florist_rounded,
                                color: AppColors.lavender,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${level.label} level',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Text(
                                'View level',
                                style: TextStyle(
                                  color: AppColors.lavender,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.lavender,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  color: AppColors.warningSoft,
                  shadow: false,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  onTap: () => context.push(Routes.performance),
                  child: const Row(
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.gold),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '4.8 rating · see how to improve',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppCard(
                  onTap: () => context.push(Routes.training),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: const Row(
                    children: [
                      IconTile(Icons.rocket_launch_rounded),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grow with HerCare',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              'Short lessons that help you earn more',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Pill('Watch', icon: Icons.play_arrow_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const AlertCarousel(),
                const SectionTitle('Earnings and payments'),
                MenuCard(
                  children: [
                    AppRow(
                      icon: Icons.currency_rupee_rounded,
                      title: 'Monthly earnings',
                      onTap: () => ref
                          .read(homeTabProvider.notifier)
                          .show(HomeTabId.earnings),
                    ),
                    row(
                      Icons.receipt_long_rounded,
                      'Payout history',
                      Routes.payouts,
                    ),
                    AppRow(
                      icon: Icons.bolt_rounded,
                      title: 'Early payout',
                      trailing: const Pill(
                        'New',
                        color: AppColors.roseDeep,
                        fill: AppColors.roseSoft,
                      ),
                      onTap: () => context.push(Routes.earlyPayout),
                    ),
                    row(
                      Icons.table_chart_rounded,
                      'Rate card',
                      Routes.rateCard,
                    ),
                  ],
                ),
                const SectionTitle('Shift and availability'),
                MenuCard(
                  children: [
                    row(
                      Icons.event_available_rounded,
                      'Attendance and shift',
                      Routes.attendance,
                    ),
                    row(
                      Icons.beach_access_rounded,
                      'Apply leave',
                      Routes.leave,
                    ),
                    row(
                      Icons.more_time_rounded,
                      'Overtime shifts',
                      Routes.overtime,
                    ),
                    AppRow(
                      icon: Icons.logout_rounded,
                      title: 'Emergency logout',
                      color: AppColors.danger,
                      fill: AppColors.dangerSoft,
                      onTap: () => context.push(Routes.emergencyLogout),
                    ),
                  ],
                ),
                const SectionTitle('Benefits and perks'),
                MenuCard(
                  children: [
                    AppRow(
                      icon: Icons.group_add_rounded,
                      title: 'Refer a friend',
                      trailing: const Pill(
                        'Earn more',
                        color: AppColors.success,
                        fill: AppColors.successSoft,
                      ),
                      onTap: () => ref
                          .read(homeTabProvider.notifier)
                          .show(HomeTabId.refer),
                    ),
                    row(
                      Icons.shield_rounded,
                      'Accident insurance',
                      Routes.insuranceFor('accident'),
                    ),
                    row(
                      Icons.health_and_safety_rounded,
                      'Health insurance',
                      Routes.insuranceFor('health'),
                    ),
                    row(Icons.storefront_rounded, 'HerCare shop', Routes.store),
                    row(Icons.toll_rounded, 'My coins', Routes.coins),
                  ],
                ),
                const SectionTitle('Account and settings'),
                MenuCard(
                  children: [
                    row(Icons.badge_rounded, 'Documents', Routes.documents),
                    row(Icons.school_rounded, 'Training', Routes.training),
                    row(
                      Icons.translate_rounded,
                      'Language',
                      Routes.language,
                      session.language,
                    ),
                    row(
                      Icons.headset_mic_rounded,
                      'Help and support',
                      Routes.help,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextButton.icon(
                  onPressed: () {
                    // Leave nothing of this account behind for the next one.
                    ref.invalidate(workProvider);
                    ref.invalidate(kycProvider);
                    ref.invalidate(shiftProvider);
                    ref.invalidate(rewardsProvider);
                    ref.invalidate(ordersProvider);
                    ref.invalidate(nomineeProvider);
                    ref.invalidate(earningsProvider);
                    ref.invalidate(referProvider);
                    ref.invalidate(trainingProvider);
                    ref.invalidate(homeTabProvider);
                    ref.read(sessionProvider.notifier).signOut();
                    context.go(Routes.login);
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                  ),
                  label: const Text(
                    'Sign out',
                    style: TextStyle(color: AppColors.danger),
                  ),
                ),
                const Center(
                  child: Text(
                    'HerExpert $version (demo)',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
