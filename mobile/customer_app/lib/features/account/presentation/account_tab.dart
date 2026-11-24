import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../auth/data/session.dart';
import '../../booking/data/booking_store.dart';
import '../../home/presentation/home_tab_provider.dart';
import '../../home/presentation/widgets/common.dart';
import 'edit_profile_sheet.dart';
import 'saved_addresses_sheet.dart';

const _goldFill = Color(0xFFFBF3E2);
const _gold = Color(0xFFB9852B);

/// "Profile": who you are, shortcuts and account settings.
class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final bookings = ref.watch(bookingStoreProvider);
    final active = bookings.where((b) => b.isActive).length;
    final name = (session.name ?? '').trim();

    return PremiumScope(
      child: Container(
        color: AppInk.canvas,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            children: [
              Center(
                child: Pressable(
                  onTap: () => showEditProfileSheet(context),
                  scale: 0.97,
                  child: Column(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFB39BEE), AppColors.lavender],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.lavender.withValues(alpha: 0.3),
                              blurRadius: 22,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          session.initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name.isEmpty ? 'Your account' : name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppInk.muted,
                          ),
                        ],
                      ),
                      if (session.prettyPhone.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            session.prettyPhone,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppInk.muted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _Tile(
                      icon: Icons.event_note_rounded,
                      title: 'My bookings',
                      subtitle: active > 0
                          ? '$active upcoming'
                          : 'View all bookings',
                      onTap: () => ref.read(homeTabProvider.notifier).show(1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Tile(
                      icon: Icons.account_balance_wallet_rounded,
                      title: 'My wallet',
                      subtitle: '₹0',
                      onTap: () => context.push(Routes.wallet),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Tile(
                      icon: Icons.local_offer_rounded,
                      title: 'All offers',
                      subtitle: 'See what you can use',
                      onTap: () => ref.read(homeTabProvider.notifier).show(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Tile(
                      icon: Icons.help_rounded,
                      title: 'Help & support',
                      subtitle: 'Get quick help',
                      onTap: () => context.push(Routes.help),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _Tile(
                      icon: Icons.favorite_rounded,
                      title: 'Favourite experts',
                      subtitle: 'Your trusted helpers',
                      gold: true,
                      onTap: () => context.push(Routes.favourites),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
              const SizedBox(height: 28),
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Manage account',
                  style: TextStyle(fontSize: 14, color: AppInk.muted),
                ),
              ),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ListRow(
                      icon: Icons.groups_rounded,
                      title: 'Your experts',
                      onTap: () => context.push(Routes.experts),
                    ),
                    ListRow(
                      icon: Icons.location_on_rounded,
                      title: 'Saved addresses',
                      onTap: () => showSavedAddressesSheet(context),
                    ),
                    ListRow(
                      icon: Icons.manage_accounts_rounded,
                      title: 'Manage account',
                      divider: false,
                      onTap: () => context.push(Routes.manageAccount),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Center(
                child: Text(
                  'HerCare · version 0.1.0',
                  style: TextStyle(fontSize: 12, color: Color(0xFFB4AEC2)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.gold = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final accent = gold ? _gold : AppColors.lavender;
    return AppCard(
      onTap: onTap,
      color: gold ? _goldFill : Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon, size: 40, color: accent),
          const SizedBox(height: 14),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppInk.muted),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppInk.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
