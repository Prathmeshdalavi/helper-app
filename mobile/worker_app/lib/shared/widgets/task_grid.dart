import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import 'task_art.dart';
import 'ui.dart';

/// Picture grid for choosing several household tasks.
class TaskGrid extends StatelessWidget {
  const TaskGrid({super.key, required this.selected, required this.onToggle});

  final Set<HomeTask> selected;
  final ValueChanged<HomeTask> onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.92,
      children: [
        for (final task in HomeTask.values)
          Pressable(
            onTap: () => onToggle(task),
            label: task.label,
            selected: selected.contains(task),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: selected.contains(task)
                    ? AppColors.lavenderLight
                    : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: softShadow(),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: FittedBox(child: TaskArt(task)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selected.contains(task)) ...[
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.lavenderDeep,
                          ),
                          const SizedBox(width: 3),
                        ],
                        Flexible(
                          child: Text(
                            task.label,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }
}
