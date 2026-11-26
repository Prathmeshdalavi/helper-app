import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/ui.dart';
import '../data/rewards_store.dart';

class StoreScreen extends ConsumerWidget {
  const StoreScreen({super.key});

  static const _pictures = <String, (IconData, Color)>{
    'bottle': (Icons.water_drop_rounded, AppColors.infoSoft),
    'bag': (Icons.shopping_bag_rounded, AppColors.softLavender),
    'umbrella': (Icons.umbrella_rounded, AppColors.roseSoft),
    'apron': (Icons.checkroom_rounded, AppColors.warningSoft),
    'shoes': (Icons.directions_walk_rounded, AppColors.successSoft),
    'tiffin': (Icons.lunch_dining_rounded, AppColors.dangerSoft),
  };

  void _redeem(BuildContext context, WidgetRef ref, StoreItem item) {
    showAppSheet<void>(
      context,
      builder: (sheet) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Redeem ${item.name}?',
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.price} coins. Collect it from your hub. Demo only.',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () {
              final ok = ref.read(rewardsProvider.notifier).redeem(item);
              Navigator.pop(sheet);
              toast(context, ok ? '${item.name} is yours' : 'Could not redeem');
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewards = ref.watch(rewardsProvider);
    return AppPage(
      title: 'HerCare store',
      actions: [
        const CoinIcon(size: 20),
        const SizedBox(width: 6),
        Text(
          '${rewards.coins}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
      ],
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.74,
          children: [
            for (final item in storeItems)
              AppCard(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: item.soldOut ? 0.45 : 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _pictures[item.iconCode]!.$2,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            _pictures[item.iconCode]!.$1,
                            size: 56,
                            color: AppColors.lavenderDeep,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Row(
                      children: [
                        const CoinIcon(size: 16),
                        const SizedBox(width: 4),
                        Text('${item.price}'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    FilledButton(
                      onPressed:
                          item.soldOut ||
                              rewards.redeemed.contains(item.id) ||
                              rewards.coins < item.price
                          ? null
                          : () => _redeem(context, ref, item),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(38),
                        padding: EdgeInsets.zero,
                        disabledBackgroundColor: AppColors.border,
                        disabledForegroundColor: AppColors.textMuted,
                      ),
                      child: Text(
                        item.soldOut
                            ? 'Sold out'
                            : rewards.redeemed.contains(item.id)
                            ? 'Redeemed'
                            : rewards.coins < item.price
                            ? 'Need ${item.price - rewards.coins}'
                            : 'Redeem',
                        style: const TextStyle(fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
