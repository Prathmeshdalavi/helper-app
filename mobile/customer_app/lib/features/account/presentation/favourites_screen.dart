import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../booking/data/booking_store.dart';
import '../../home/presentation/home_tab_provider.dart';
import 'experts_screen.dart';

const _gold = Color(0xFFE9B955);

/// Favourite experts: the helpers you want again.
class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(expertsProvider);
    final favourites = [
      for (final e in all)
        if (e.favourite) e,
    ];

    return PremiumScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF101010), Color(0xFF141414)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const PremiumTopBar(title: '', onDark: true),
                    const SizedBox(height: 2),
                    const Icon(Icons.favorite_rounded, color: _gold, size: 40),
                    const SizedBox(height: 10),
                    const Text(
                      'Favourites',
                      style: TextStyle(
                        fontSize: 34,
                        height: 1.1,
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w700,
                        color: _gold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your trusted helpers, one tap away',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _Perk(
                              Icons.thumb_up_alt_rounded,
                              'No repeat instructions',
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _Perk(
                              Icons.favorite_rounded,
                              'A familiar face every time',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: favourites.isEmpty
                      ? _Locked(hasVisited: all.isNotEmpty)
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                          children: [
                            for (final e in favourites) ...[
                              ExpertTile(entry: e),
                              const SizedBox(height: 12),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Perk extends StatelessWidget {
  const _Perk(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.25,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Locked extends ConsumerWidget {
  const _Locked({required this.hasVisited});

  final bool hasVisited;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: premiumSelectedFill,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: AppColors.lavender,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasVisited
                  ? 'Add an expert as a favourite'
                  : 'Book your first service to unlock favourites',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasVisited
                  ? 'Tap the heart next to an expert in Your experts.'
                  : 'After a visit, you can add the helper you liked.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppInk.muted),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 190,
              child: PrimaryButton(
                label: hasVisited ? 'Your experts' : 'Book now',
                onPressed: () {
                  if (hasVisited) {
                    context.push(Routes.experts);
                  } else {
                    ref.read(homeTabProvider.notifier).show(0);
                    context.go(Routes.home);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
