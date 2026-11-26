import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/ui.dart';

/// TODO(benefits): load network hospitals for the expert's location.
class HospitalsScreen extends StatefulWidget {
  const HospitalsScreen({super.key});

  @override
  State<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  static const _hospitals = [
    ('Sample City Hospital', 'Thane West', 1.4),
    ('Sample Women and Child Clinic', 'Manpada', 2.1),
    ('Sample General Hospital', 'Kolshet Road', 3.0),
    ('Sample Heart Centre', 'Hiranandani Estate', 3.6),
  ];

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final shown = _hospitals
        .where(
          (h) => '${h.$1} ${h.$2}'.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();
    return AppPage(
      title: 'Cashless hospitals',
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 150,
            child: ExcludeSemantics(
              child: CustomPaint(size: Size.infinite, painter: MapPainter()),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: const InputDecoration(
            hintText: 'Search by name or area',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 14),
        if (shown.isEmpty)
          const EmptyState(
            icon: Icons.search_off_rounded,
            title: 'Nothing found',
            message: 'Try another area.',
          )
        else
          MenuCard(
            children: [
              for (final (name, area, km) in shown)
                AppRow(
                  icon: Icons.local_hospital_rounded,
                  color: AppColors.danger,
                  fill: AppColors.dangerSoft,
                  title: name,
                  subtitle: '$area · $km km',
                  trailing: IconButton.filledTonal(
                    tooltip: 'Directions to $name',
                    onPressed: () =>
                        toast(context, 'Opens maps directions (demo)'),
                    icon: const Icon(Icons.directions_rounded),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 12),
        const Text(
          'Made-up hospitals for the demo.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
