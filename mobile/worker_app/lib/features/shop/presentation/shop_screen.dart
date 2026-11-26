import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../data/shop_store.dart';
import '../domain/shop_item.dart';
import 'product_art.dart';

/// Work gear, paid for out of the next payout.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  void _confirm(BuildContext context, WidgetRef ref, ShopItem item) {
    showAppSheet<void>(
      context,
      builder: (sheet) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 120, child: ProductPicture(item.art)),
          const SizedBox(height: 12),
          Text(
            item.name,
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          Text(item.about, style: const TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 12),
          ValueRow('Taken from next payout', rupees(item.price), bold: true),
          const Text(
            'Collect it from your hub. Demo only: nothing is ordered.',
            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final ok = ref.read(ordersProvider.notifier).order(item);
              Navigator.pop(sheet);
              toast(
                context,
                ok
                    ? '${item.name} ordered (demo)'
                    : 'Your waiting payout is too low for this',
              );
            },
            child: const Text('Confirm order'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordered = ref.watch(ordersProvider);
    return AppPage(
      title: 'HerCare shop',
      children: [
        AppCard(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.lavender, AppColors.lavenderDeep],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Pill(
                'Gear for your shift',
                icon: Icons.inventory_2_rounded,
                fill: AppColors.card,
              ),
              const SizedBox(height: 10),
              const Text(
                'Look sharp, work easy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: AppColors.gold),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No cash needed. The price comes out of your next payout.',
                        style: TextStyle(color: AppColors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (final section in ShopSection.values) ...[
          SectionTitle(section.title),
          _Grid(
            items: shopItems.where((i) => i.section == section).toList(),
            ordered: ordered,
            onBuy: (item) => _confirm(context, ref, item),
          ),
        ],
      ],
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.items,
    required this.ordered,
    required this.onBuy,
  });

  final List<ShopItem> items;
  final Set<String> ordered;
  final ValueChanged<ShopItem> onBuy;

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent:
            168 + 94 * MediaQuery.textScalerOf(context).scale(14) / 14,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
      ),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < items.length; i++)
          Reveal(
            index: i,
            child: AppCard(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.softLavender,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Opacity(
                            opacity: items[i].soldOut ? 0.4 : 1,
                            child: ProductPicture(items[i].art),
                          ),
                        ),
                        if (items[i].soldOut)
                          const Positioned(
                            left: 6,
                            top: 6,
                            child: Pill(
                              'Sold out',
                              color: AppColors.textMuted,
                              fill: AppColors.card,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    items[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    rupees(items[i].price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.lavender,
                    ),
                  ),
                  const SizedBox(height: 6),
                  FilledButton(
                    onPressed: items[i].soldOut || ordered.contains(items[i].id)
                        ? null
                        : () => onBuy(items[i]),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(38),
                      padding: EdgeInsets.zero,
                      disabledBackgroundColor: AppColors.border,
                      disabledForegroundColor: AppColors.textMuted,
                    ),
                    child: Text(
                      items[i].soldOut
                          ? 'Sold out'
                          : ordered.contains(items[i].id)
                          ? 'Ordered'
                          : 'Order',
                      style: const TextStyle(fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
