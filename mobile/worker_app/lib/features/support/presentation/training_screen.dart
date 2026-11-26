import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/ui.dart';
import '../data/training_store.dart';

class TrainingScreen extends ConsumerWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(trainingProvider);
    return AppPage(
      title: 'Training',
      children: [
        for (final course in courses)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AppCard(
              child: Builder(
                builder: (context) {
                  final done = progress[course.id] ?? 0;
                  final finished = done >= course.lessons.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IconTile(Icons.play_circle_rounded),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  course.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${course.minutes} min · $done of ${course.lessons.length} lessons',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (finished)
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColors.success,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (var i = 0; i < course.lessons.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                i < done
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 18,
                                color: i < done
                                    ? AppColors.success
                                    : AppColors.lavenderLight,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(course.lessons[i])),
                            ],
                          ),
                        ),
                      if (!finished) ...[
                        const SizedBox(height: 10),
                        FilledButton(
                          // TODO(training): play the lesson video before marking it done.
                          onPressed: () => ref
                              .read(trainingProvider.notifier)
                              .finishLesson(course),
                          child: Text(
                            done == 0 ? 'Start' : 'Finish next lesson',
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
