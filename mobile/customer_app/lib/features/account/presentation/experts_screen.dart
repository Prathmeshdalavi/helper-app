import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../booking/data/booking_store.dart';
import '../../home/presentation/home_tab_provider.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/address_store.dart';

const _gold = Color(0xFFBF7734);

/// Every expert who has visited, with a heart to favourite them.
class ExpertsScreen extends ConsumerWidget {
  const ExpertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experts = ref.watch(expertsProvider);
    final address = ref.watch(selectedAddressProvider);
    return PremiumScope(
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                child: PremiumTopBar(
                  title: 'Your experts',
                  subtitle: '${address.label} | ${address.line1}',
                ),
              ),
              const Divider(height: 1, color: AppInk.hairline),
              Expanded(
                child: experts.isEmpty
                    ? const _Empty(
                        icon: Icons.groups_rounded,
                        title: 'All experts who visited you appear here',
                        text: 'Why not make a booking right away?',
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                        children: [
                          for (final e in experts) ...[
                            ExpertTile(entry: e),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One expert row with a favourite heart.
class ExpertTile extends ConsumerWidget {
  const ExpertTile({super.key, required this.entry});

  final ExpertEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = entry.expert;
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFFCE4D8),
              shape: BoxShape.circle,
            ),
            child: Text(
              e.initial,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.lavender,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.name,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: premiumGreen,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${e.rating} · ${entry.visits} visit${entry.visits == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppInk.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Semantics(
            button: true,
            label: entry.favourite ? 'Remove favourite' : 'Add favourite',
            child: Pressable(
              onTap: () => ref
                  .read(bookingStoreProvider.notifier)
                  .setExpertFavourite(e.name, !entry.favourite),
              scale: 0.9,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: c),
                child: Icon(
                  entry.favourite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(entry.favourite),
                  size: 28,
                  color: entry.favourite ? _gold : AppInk.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A calm empty state with a "Book now" button.
class _Empty extends ConsumerWidget {
  const _Empty({required this.icon, required this.title, required this.text});

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                color: premiumSelectedFill,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 52, color: AppColors.lavender),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppInk.muted),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 170,
              child: PrimaryButton(
                label: 'Book now',
                onPressed: () {
                  ref.read(homeTabProvider.notifier).show(0);
                  context.go(Routes.home);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
