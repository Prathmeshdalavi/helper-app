import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/auth_backdrop.dart';
import '../../../shared/widgets/glow_badge.dart';
import '../../auth/data/session.dart';
import 'home_tab.dart';

/// Signed-in shell: the four main tabs with a floating bottom bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = <_NavTab>[
    _NavTab('Home', Icons.home_rounded, Icons.home_outlined),
    _NavTab('Bookings', Icons.event_note_rounded, Icons.event_note_outlined),
    _NavTab('Offers', Icons.local_offer_rounded, Icons.local_offer_outlined),
    _NavTab('Account', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: const [
              HomeTab(),
              _EmptyTab(
                icon: Icons.event_note_rounded,
                title: 'No bookings yet',
                message: 'Your upcoming and past bookings will show up here once you book a helper.',
              ),
              _EmptyTab(
                icon: Icons.local_offer_rounded,
                title: 'Offers are on the way',
                message: 'Discounts and promo codes will appear here.',
              ),
              _AccountTab(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: _BottomBar(
                tabs: _tabs,
                index: _index,
                onChanged: (i) => setState(() => _index = i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  const _NavTab(this.label, this.active, this.inactive);
  final String label;
  final IconData active;
  final IconData inactive;
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.tabs,
    required this.index,
    required this.onChanged,
  });

  final List<_NavTab> tabs;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFEFEAF7)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < tabs.length; i++)
            GestureDetector(
              key: ValueKey('nav-$i'),
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: i == index ? 16 : 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: i == index
                      ? AppColors.lavender.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Icon(
                      i == index ? tabs[i].active : tabs[i].inactive,
                      size: 24,
                      color: i == index
                          ? AppColors.lavender
                          : const Color(0xFF9A94A5),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      child: i == index
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                tabs[i].label,
                                style: const TextStyle(
                                  color: AppColors.lavender,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Friendly empty state for tabs that are not built yet.
class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AuthBackdrop(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(36, 0, 36, 90),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlowBadge(icon: icon),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF6B6577),
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

class _AccountTab extends ConsumerWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return AuthBackdrop(
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 90),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        color: AppColors.lavender.withValues(alpha: 0.35),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  (session.name ?? '').isEmpty ? 'Your account' : session.name!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                if (session.prettyPhone.isNotEmpty)
                  Text(
                    session.prettyPhone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B6577),
                    ),
                  ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO(auth): also clear tokens and call POST /auth/logout.
                      ref.read(sessionProvider.notifier).signOut();
                      context.go(Routes.login);
                    },
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    label: const Text('Log out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.lavender,
                      side: BorderSide(
                        color: AppColors.lavender.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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
