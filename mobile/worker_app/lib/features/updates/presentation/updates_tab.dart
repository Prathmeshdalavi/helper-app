import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../data/demo_updates.dart';

class UpdatesTab extends ConsumerStatefulWidget {
  const UpdatesTab({super.key});

  @override
  ConsumerState<UpdatesTab> createState() => _UpdatesTabState();
}

class _UpdatesTabState extends ConsumerState<UpdatesTab> {
  int _filter = 0;

  void _openStory(Story story) {
    showDialog<void>(
      context: context,
      builder: (dialog) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Loop(
                  duration: const Duration(seconds: 5),
                  builder: (context, t) =>
                      CustomPaint(painter: HeroArtPainter(story.scene, t)),
                ),
              ),
              Text(
                story.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                story.body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(dialog),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    final list = demoUpdates.where(
      (u) => _filter == 0 || u.kind.index == _filter - 1,
    );
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const PageHeader(title: 'Updates'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              children: [
                SizedBox(
                  height: 150,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    itemCount: demoStories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final story = demoStories[i];
                      return Pressable(
                        label: 'Story: ${story.title}',
                        onTap: () => _openStory(story),
                        child: Container(
                          width: 114,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.softLavender,
                                AppColors.roseSoft,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: CustomPaint(
                                  size: Size.infinite,
                                  painter: HeroArtPainter(story.scene, 0.2),
                                ),
                              ),
                              Text(
                                story.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                ChoiceChips(
                  options: const ['All', 'Info', 'Incentive'],
                  selected: _filter,
                  onSelected: (i) => setState(() => _filter = i),
                ),
                const SizedBox(height: 14),
                for (final u in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          u.kind == UpdateKind.incentive
                              ? const IconTile(
                                  Icons.redeem_rounded,
                                  color: AppColors.roseDeep,
                                  fill: AppColors.roseSoft,
                                )
                              : const IconTile(
                                  Icons.info_rounded,
                                  color: AppColors.info,
                                  fill: AppColors.infoSoft,
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  u.body,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  shortDate(
                                    today.subtract(Duration(days: u.daysAgo)),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
