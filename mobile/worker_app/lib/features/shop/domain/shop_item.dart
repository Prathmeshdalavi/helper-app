enum ShopSection {
  uniform('Uniform and apparel'),
  accessories('Accessories');

  const ShopSection(this.title);
  final String title;
}

enum ProductArt {
  apron,
  tunic,
  cycle,
  cyclePlan,
  careKit,
  bag,
  bottle,
  umbrella,
}

class ShopItem {
  const ShopItem({
    required this.id,
    required this.section,
    required this.name,
    required this.about,
    required this.price,
    required this.art,
    this.soldOut = false,
  });

  final String id;
  final ShopSection section;
  final String name;
  final String about;

  /// In rupees, taken from the next payout.
  final int price;
  final ProductArt art;
  final bool soldOut;
}
