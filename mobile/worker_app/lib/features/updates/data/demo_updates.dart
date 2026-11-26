import '../../../shared/widgets/art.dart';

enum UpdateKind { info, incentive }

class AppUpdate {
  const AppUpdate(this.kind, this.title, this.body, this.daysAgo);

  final UpdateKind kind;
  final String title;
  final String body;
  final int daysAgo;
}

class Story {
  const Story(this.scene, this.title, this.body);

  final HeroScene scene;
  final String title;
  final String body;
}

/// TODO(updates): load announcements from the backend.
const demoUpdates = <AppUpdate>[
  AppUpdate(
    UpdateKind.incentive,
    'Weekend bonus is on',
    'Finish 6 jobs between Saturday and Sunday to get ₹300 extra.',
    0,
  ),
  AppUpdate(
    UpdateKind.info,
    'New uniform at your hub',
    'Collect your lavender apron from the hub this week.',
    2,
  ),
  AppUpdate(
    UpdateKind.incentive,
    'Rain day extra',
    '₹40 more on every job while it is raining in your area.',
    5,
  ),
  AppUpdate(
    UpdateKind.info,
    'Deductions made clear',
    'Every deduction now shows its reason in your monthly breakdown.',
    9,
  ),
];

const demoStories = <Story>[
  Story(
    HeroScene.earn,
    'Peak hours',
    'Mornings from 8 to 11 have the most requests. Be online early.',
  ),
  Story(
    HeroScene.safe,
    'Your safety',
    'SOS is on every job screen. Use it whenever you feel unsafe.',
  ),
  Story(
    HeroScene.flexible,
    'Plan your week',
    'Mark attendance the evening before so jobs reach you first.',
  ),
];
