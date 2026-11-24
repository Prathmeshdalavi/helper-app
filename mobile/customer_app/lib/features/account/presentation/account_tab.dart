import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../auth/data/session.dart';
import '../../booking/data/booking_store.dart';
import '../../booking/presentation/rating_sheet.dart';
import '../../home/presentation/home_tab_provider.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/address_store.dart';
import '../data/wallet_store.dart';
import 'edit_profile_sheet.dart';
import 'saved_addresses_sheet.dart';

const _gold = Color(0xFFB9852B);
const _goldFill = Color(0xFFFBF3E2);

/// "Profile": who you are, what you have, and where to manage it.
class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final bookings = ref.watch(bookingStoreProvider);
    final experts = ref.watch(expertsProvider);
    final address = ref.watch(selectedAddressProvider);
    final walletBalance = ref.watch(walletProvider).balance;
    final favourites = [
      for (final e in experts)
        if (e.favourite) e,
    ];
    final active = bookings.where((b) => b.isActive).length;
    final name = (session.name ?? '').trim();

    return PremiumScope(
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 130),
            child: Column(
              children: [
                _Hero(
                  initial: session.initial,
                  name: name.isEmpty ? 'Your account' : name,
                  phone: session.prettyPhone,
                  onEdit: () => showEditProfileSheet(context),
                ),
                Transform.translate(
                  offset: const Offset(0, -34),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _StatsCard(
                          bookings: bookings.length,
                          wallet: rupees(walletBalance),
                          favourites: favourites.length,
                          onBookings: () =>
                              ref.read(homeTabProvider.notifier).show(1),
                          onWallet: () => context.push(Routes.wallet),
                          onFavourites: () => context.push(Routes.favourites),
                        ),
                        const SizedBox(height: 26),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _Quick(
                              icon: Icons.event_note_rounded,
                              label: 'Bookings',
                              badge: active > 0 ? '$active' : null,
                              onTap: () =>
                                  ref.read(homeTabProvider.notifier).show(1),
                            ),
                            _Quick(
                              icon: Icons.account_balance_wallet_rounded,
                              label: 'Wallet',
                              onTap: () => context.push(Routes.wallet),
                            ),
                            _Quick(
                              icon: Icons.local_offer_rounded,
                              label: 'Offers',
                              onTap: () =>
                                  ref.read(homeTabProvider.notifier).show(2),
                            ),
                            _Quick(
                              icon: Icons.headset_mic_rounded,
                              label: 'Help',
                              onTap: () => context.push(Routes.help),
                            ),
                          ],
                        ),
                        const SizedBox(height: 26),
                        _FavouritesCard(
                          names: [for (final f in favourites) f.expert.name],
                          onTap: () => context.push(Routes.favourites),
                        ),
                        const SizedBox(height: 14),
                        _ReferCard(onTap: () => showInviteSheet(context)),
                        const SizedBox(height: 26),
                        const _SectionTitle('Your account'),
                        _Group(
                          children: [
                            ListRow(
                              icon: Icons.groups_rounded,
                              title: 'Your experts',
                              subtitle: experts.isEmpty
                                  ? 'Helpers who have visited'
                                  : '${experts.length} helper${experts.length == 1 ? '' : 's'}',
                              onTap: () => context.push(Routes.experts),
                            ),
                            ListRow(
                              icon: Icons.location_on_rounded,
                              title: 'Saved addresses',
                              subtitle: '${address.label} · ${address.line1}',
                              onTap: () => showSavedAddressesSheet(context),
                            ),
                            ListRow(
                              icon: Icons.manage_accounts_rounded,
                              title: 'Manage account',
                              subtitle: 'Log out, policies and data',
                              divider: false,
                              onTap: () => context.push(Routes.manageAccount),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'HerCare · version 0.1.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB4AEC2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.initial,
    required this.name,
    required this.phone,
    required this.onEdit,
  });

  final String initial;
  final String name;
  final String phone;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9B80DE),
                    Color(0xFF6C4FB3),
                    Color(0xFF4F3892),
                  ],
                ),
              ),
            ),
          ),
          // Soft rings, a quiet bit of depth behind the avatar.
          Positioned(
            right: -60,
            top: -40,
            child: _Ring(size: 220, alpha: 0.10),
          ),
          Positioned(
            left: -70,
            bottom: -50,
            child: _Ring(size: 200, alpha: 0.08),
          ),
          // Sized by its content, so a tall status bar can never overflow it.
          Padding(
            padding: EdgeInsets.only(top: top + 18, bottom: 58),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lavender,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onEdit,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (phone.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      phone,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ),
                const SizedBox(height: 14),
                Pressable(
                  onTap: onEdit,
                  scale: 0.96,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_rounded, size: 15, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Edit profile',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
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

class _Ring extends StatelessWidget {
  const _Ring({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: Colors.white.withValues(alpha: alpha),
        width: 26,
      ),
    ),
  );
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.bookings,
    required this.wallet,
    required this.favourites,
    required this.onBookings,
    required this.onWallet,
    required this.onFavourites,
  });

  final int bookings;
  final String wallet;
  final int favourites;
  final VoidCallback onBookings;
  final VoidCallback onWallet;
  final VoidCallback onFavourites;

  @override
  Widget build(BuildContext context) {
    Widget stat(String value, String label, VoidCallback onTap) => Expanded(
      child: Pressable(
        onTap: onTap,
        scale: 0.97,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
              ),
            ],
          ),
        ),
      ),
    );

    Widget divider() => Container(width: 1, height: 34, color: AppInk.hairline);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppInk.hairline),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B2540).withValues(alpha: 0.1),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          stat('$bookings', 'Bookings', onBookings),
          divider(),
          stat(wallet, 'Wallet', onWallet),
          divider(),
          stat('$favourites', 'Favourites', onFavourites),
        ],
      ),
    );
  }
}

class _Quick extends StatelessWidget {
  const _Quick({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Pressable(
        onTap: onTap,
        scale: 0.94,
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: premiumSelectedFill,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(icon, size: 26, color: AppColors.lavender),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.lavender,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavouritesCard extends StatelessWidget {
  const _FavouritesCard({required this.names, required this.onTap});

  final List<String> names;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final has = names.isNotEmpty;
    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _goldFill,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF3E4BF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: _gold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favourite experts',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    has
                        ? names.join(', ')
                        : 'Book once to add helpers you trust',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _gold),
          ],
        ),
      ),
    );
  }
}

class _ReferCard extends StatelessWidget {
  const _ReferCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.985,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1EBFC), Color(0xFFE3D9F8)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Refer & earn ₹200',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Your friend gets ₹50 on their first booking',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: AppInk.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.lavender,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(children: children),
  );
}
