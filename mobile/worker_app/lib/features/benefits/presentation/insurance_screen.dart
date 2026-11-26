import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';

/// Accident or health cover. Demo figures only.
/// TODO(benefits): load the policy from the insurer integration.
class InsuranceScreen extends StatefulWidget {
  const InsuranceScreen({super.key, required this.kind});

  /// 'accident' or 'health'.
  final String kind;

  @override
  State<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends State<InsuranceScreen> {
  String? _nominee;

  bool get _health => widget.kind == 'health';

  void _addNominee() {
    final name = TextEditingController();
    showAppSheet<void>(
      context,
      builder: (sheet) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Add a nominee',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Nominee full name'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final value = name.text.trim();
              if (value.isEmpty) return;
              setState(() => _nominee = value);
              Navigator.pop(sheet);
            },
            child: const Text('Save nominee'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cover = _health ? 200000 : 500000;
    final policy = _health ? 'HC-HLT-204518' : 'HC-ACC-908231';
    final tips = _health
        ? const [
            'Show your policy number at a partner hospital',
            'Call support before a planned admission',
            'Keep every bill and prescription',
          ]
        : const [
            'Report an accident within 24 hours',
            'Take photos if it is safe to do so',
            'Keep the hospital discharge summary',
          ];
    return AppPage(
      title: _health ? 'Health insurance' : 'Accident insurance',
      actions: [
        IconButton(
          tooltip: 'Copy policy details',
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: 'HerCare policy $policy, cover ${rupees(cover)}',
              ),
            );
            toast(context, 'Policy details copied');
          },
          icon: const Icon(Icons.ios_share_rounded),
        ),
      ],
      bottom: FilledButton.icon(
        onPressed: () => context.push(Routes.help),
        icon: const Icon(Icons.headset_mic_rounded),
        label: const Text('Call support'),
      ),
      children: [
        AppCard(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.successSoft, AppColors.softLavender],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              IconTile(
                _health
                    ? Icons.health_and_safety_rounded
                    : Icons.shield_rounded,
                size: 72,
                color: AppColors.success,
                fill: AppColors.card,
              ),
              const SizedBox(height: 12),
              const Text('You are covered up to'),
              CountUp(
                value: cover,
                format: rupees,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Pill(
                'Policy $policy',
                color: AppColors.success,
                fill: AppColors.card,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        MenuCard(
          children: [
            AppRow(
              icon: Icons.family_restroom_rounded,
              title: _nominee == null ? 'Add a nominee' : 'Nominee',
              subtitle: _nominee ?? 'Who should receive the claim if needed',
              onTap: _addNominee,
            ),
          ],
        ),
        const SectionTitle('Good to know'),
        MenuCard(
          children: [
            for (var i = 0; i < tips.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Pill('${i + 1}'),
                    const SizedBox(width: 12),
                    Expanded(child: Text(tips[i])),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Sample cover for the demo, not a real policy.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
