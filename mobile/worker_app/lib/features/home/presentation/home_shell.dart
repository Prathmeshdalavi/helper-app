import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/ui.dart';
import '../../earnings/presentation/earnings_tab.dart';
import '../../jobs/presentation/offer_dispatcher.dart';
import '../../profile/presentation/profile_tab.dart';
import '../../refer/presentation/refer_tab.dart';
import '../../updates/presentation/updates_tab.dart';
import 'home_tab.dart';
import 'home_tab_provider.dart';

/// Signed-in shell: five tabs over a bottom bar.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _items = <HomeTabId, (String, IconData, IconData)>{
    HomeTabId.home: ('Home', Icons.home_rounded, Icons.home_outlined),
    HomeTabId.earnings: (
      'Earnings',
      Icons.account_balance_wallet_rounded,
      Icons.account_balance_wallet_outlined,
    ),
    HomeTabId.refer: (
      'Refer',
      Icons.group_add_rounded,
      Icons.group_add_outlined,
    ),
    HomeTabId.updates: (
      'Updates',
      Icons.notifications_rounded,
      Icons.notifications_none_rounded,
    ),
    HomeTabId.profile: (
      'Profile',
      Icons.person_rounded,
      Icons.person_outline_rounded,
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(homeTabProvider);
    return OfferDispatcher(
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(tab),
            child: switch (tab) {
              HomeTabId.home => const HomeTab(),
              HomeTabId.earnings => const EarningsTab(),
              HomeTabId.refer => const ReferTab(),
              HomeTabId.updates => const UpdatesTab(),
              HomeTabId.profile => const ProfileTab(),
            },
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            boxShadow: softShadow(1.6),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
              child: Row(
                children: [
                  for (final id in HomeTabId.values)
                    Expanded(
                      child: Pressable(
                        key: ValueKey('nav-${id.name}'),
                        label: '${_items[id]!.$1} tab',
                        selected: id == tab,
                        onTap: () =>
                            ref.read(homeTabProvider.notifier).show(id),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              width: id == tab ? 54 : 36,
                              height: 30,
                              decoration: BoxDecoration(
                                color: id == tab
                                    ? AppColors.softLavender
                                    : AppColors.clear,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                id == tab ? _items[id]!.$2 : _items[id]!.$3,
                                size: 22,
                                color: id == tab
                                    ? AppColors.lavender
                                    : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _items[id]!.$1,
                              maxLines: 1,
                              textScaler: TextScaler.noScaling,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: id == tab
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: id == tab
                                    ? AppColors.lavender
                                    : AppColors.textMuted,
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
      ),
    );
  }
}
