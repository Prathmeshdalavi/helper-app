import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/premium.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/demo_inclusions.dart';

/// Opens the "What is included?" sheet.
Future<void> showInclusionsSheet(BuildContext context) =>
    showPremiumSheet<void>(context, builder: (_) => const _InclusionsSheet());

class _InclusionsSheet extends StatefulWidget {
  const _InclusionsSheet();

  @override
  State<_InclusionsSheet> createState() => _InclusionsSheetState();
}

class _InclusionsSheetState extends State<_InclusionsSheet> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final group = DemoInclusions.groups[_tab];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Text(
            'What is included?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: DemoInclusions.groups.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final g = DemoInclusions.groups[i];
              final on = i == _tab;
              return Pressable(
                onTap: () => setState(() => _tab = i),
                scale: 0.97,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: premiumEase,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: on ? premiumSelectedFill : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: on ? AppColors.lavender : AppInk.hairline,
                      width: on ? 1.3 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        g.icon,
                        size: 18,
                        color: on ? AppColors.lavender : AppInk.muted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        g.title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              switchInCurve: premiumEase,
              child: Column(
                key: ValueKey(_tab),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your helper is trained to',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  for (final t in group.included)
                    _Item(text: t, included: true),
                  if (group.notIncluded.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Not included',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final t in group.notIncluded)
                      _Item(text: t, included: false),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6FA),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppInk.hairline),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.cleaning_services_outlined,
                          color: AppInk.muted,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please keep the tools and supplies your helper '
                            'will need ready at home.',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: AppInk.muted,
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
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.text, required this.included});

  final String text;
  final bool included;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: included ? premiumGreen : premiumAmber,
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check_rounded : Icons.close_rounded,
              size: 14,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14.5, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
