import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../earnings/data/earnings_store.dart';
import '../domain/shop_item.dart';

/// TODO(shop): load the catalogue and place orders on the backend.
const shopItems = <ShopItem>[
  ShopItem(
    id: 'apron',
    section: ShopSection.uniform,
    name: 'Work apron',
    about: 'Two deep pockets, washes easily.',
    price: 140,
    art: ProductArt.apron,
  ),
  ShopItem(
    id: 'tunic',
    section: ShopSection.uniform,
    name: 'Uniform tunic',
    about: 'Soft cotton in HerCare lavender.',
    price: 320,
    art: ProductArt.tunic,
    soldOut: true,
  ),
  ShopItem(
    id: 'cycle',
    section: ShopSection.accessories,
    name: 'Ladies cycle',
    about: 'Step-through frame with basket and carrier.',
    price: 4800,
    art: ProductArt.cycle,
    soldOut: true,
  ),
  ShopItem(
    id: 'cycle-dp',
    section: ShopSection.accessories,
    name: 'Cycle down payment',
    about: 'Pay part now and the rest from later payouts.',
    price: 1600,
    art: ProductArt.cyclePlan,
  ),
  ShopItem(
    id: 'kit',
    section: ShopSection.accessories,
    name: 'Care kit',
    about: 'Gloves, masks and hand cream.',
    price: 70,
    art: ProductArt.careKit,
  ),
  ShopItem(
    id: 'bag',
    section: ShopSection.accessories,
    name: 'Tote bag',
    about: 'Room for your uniform and lunch.',
    price: 180,
    art: ProductArt.bag,
  ),
  ShopItem(
    id: 'bottle',
    section: ShopSection.accessories,
    name: 'Steel bottle',
    about: 'Keeps water cool through a shift.',
    price: 150,
    art: ProductArt.bottle,
  ),
  ShopItem(
    id: 'umbrella',
    section: ShopSection.accessories,
    name: 'Folding umbrella',
    about: 'Small enough for your bag.',
    price: 220,
    art: ProductArt.umbrella,
  ),
];

/// Ids of the items already ordered.
class OrdersNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// Orders [item] and books its cost against the next payout. Refused when it
  /// is sold out, already ordered, or costs more than is waiting to be paid.
  bool order(ShopItem item) {
    final earnings = ref.read(earningsProvider);
    if (item.soldOut ||
        state.contains(item.id) ||
        item.price > earnings.month.remaining(earnings.hasPan)) {
      return false;
    }
    ref.read(earningsProvider.notifier).addProductCost(item.price);
    state = {...state, item.id};
    return true;
  }
}

final ordersProvider = NotifierProvider<OrdersNotifier, Set<String>>(
  OrdersNotifier.new,
);
