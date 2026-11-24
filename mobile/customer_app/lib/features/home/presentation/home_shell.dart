import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../account/presentation/account_tab.dart';
import '../../account/presentation/offers_tab.dart';
import '../../booking/presentation/bookings_tab.dart';
import 'home_tab.dart';
import 'home_tab_provider.dart';

/// Signed-in shell: the four main tabs with a floating bottom bar.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  static const _tabs = <_NavTab>[
    _NavTab('Home', Icons.home_rounded, Icons.home_outlined),
    _NavTab('Bookings', Icons.event_note_rounded, Icons.event_note_outlined),
    _NavTab('Offers', Icons.local_offer_rounded, Icons.local_offer_outlined),
    _NavTab('Account', Icons.person_rounded, Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(homeTabProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: index,
            children: const [
              HomeTab(),
              BookingsTab(),
              OffersTab(),
              AccountTab(),
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
                index: index,
                onChanged: (i) => ref.read(homeTabProvider.notifier).show(i),
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
