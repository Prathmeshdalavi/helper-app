import 'package:material_ui/material_ui.dart';

/// What a visit covers. Shown on the "What's included" sheet.
/// TODO(catalog): replace with GET /catalog/tasks.
class TaskGroup {
  const TaskGroup({
    required this.title,
    required this.icon,
    required this.included,
    this.notIncluded = const [],
  });

  final String title;
  final IconData icon;
  final List<String> included;
  final List<String> notIncluded;
}

abstract final class DemoInclusions {
  static const groups = [
    TaskGroup(
      title: 'House cleaning',
      icon: Icons.cleaning_services_rounded,
      included: [
        'Sweep and mop accessible floors',
        'Dust and wipe furniture and wardrobes',
        'Dust reachable walls, fans and ceilings',
        'Change or rearrange existing bedding',
        'Dispose of wet and dry household waste',
      ],
      notIncluded: [
        'Cleaning unsafe or inaccessible areas',
        'Any task that needs a ladder or working at height',
        'Moving heavy furniture or appliances',
        'Cleaning areas outside the home',
        'Child, elderly, pet or medical care',
      ],
    ),
    TaskGroup(
      title: 'Dusting & wiping',
      icon: Icons.dry_cleaning_rounded,
      included: [
        'Dust shelves and furniture',
        'Wipe counters, tables and decor',
        'Clean window sills and grills',
        'Remove reachable cobwebs',
        'Wipe appliance exteriors',
      ],
      notIncluded: [
        'Dusting ceilings or high areas',
        'Using unstable stools or ladders',
        'Chandeliers or fragile items',
        'Exterior grills and windows',
        'Stain removal or restoration',
      ],
    ),
    TaskGroup(
      title: 'Bathroom cleaning',
      icon: Icons.bathtub_outlined,
      included: [
        'Clean mirrors and reachable walls',
        'Clean the toilet seat, rim and lid',
        'Scrub sinks and wipe fittings',
        'Mop and dry the bathroom floor',
        'Basic surface clean of the bathroom',
      ],
      notIncluded: [
        'Hard stains, grout or acid wash',
        'Ceilings and exhausts',
        'Drain unclogging or dismantling',
        'Handling biohazard waste',
        'Electrical or open wiring work',
      ],
    ),
    TaskGroup(
      title: 'Wash, fold & arrange',
      icon: Icons.local_laundry_service_outlined,
      included: [
        'Separate clothes into whites and colours',
        'Load detergent and run the machine',
        'Dry clothes on a line or rack',
        'Fold and arrange in cupboards',
        'Tidy the laundry area afterwards',
      ],
      notIncluded: [
        'Ironing or steaming clothes',
        'Biohazard-stained clothes',
        'Cleaning the washing machine or dryer',
        'Advanced stain treatments',
        'Hand washing bed sheets or footwear',
      ],
    ),
    TaskGroup(
      title: 'Cleaning dishes',
      icon: Icons.soup_kitchen_outlined,
      included: [
        'Wash regular household utensils',
        'Scrub and clean the kitchen sink',
        'Clean burners and wipe the stove top',
        'Dispose of wet and dry kitchen waste',
        'Leave the sink area clean and dry',
      ],
      notIncluded: [
        'Chimney, degreasing or duct cleaning',
        'Cleaning inside electrical appliances',
        'Heavy scrubbing of burnt or old deposits',
        'Handling broken glass or sharp waste',
        'Specialised cookware handling',
      ],
    ),
    TaskGroup(
      title: 'And many more',
      icon: Icons.add_circle_outline_rounded,
      included: [
        'Clean reachable fans and cobwebs',
        'Basic kitchen prep, washing and chopping',
        'Clean the fridge',
        'Organise wardrobes',
        'Clean the kitchen slab and stove top',
        'Clean interior windows',
        'Arrange sofa cushions',
        'Arrange tabletops, dining or study',
        'Shine mirrors and taps',
      ],
    ),
  ];
}
