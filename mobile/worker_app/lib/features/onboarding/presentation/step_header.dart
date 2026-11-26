import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';

class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.step,
    required this.of,
    required this.text,
  });

  final int step;
  final int of;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 1; i <= of; i++)
              Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i == of ? 0 : 6),
                  decoration: BoxDecoration(
                    color: i <= step ? AppColors.lavender : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Step $step of $of · $text',
          style: const TextStyle(color: AppColors.textMuted),
        ),
      ],
    ),
  );
}
