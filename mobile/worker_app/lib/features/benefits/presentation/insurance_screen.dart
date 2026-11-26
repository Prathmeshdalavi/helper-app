import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../core/utils/format.dart';
import '../../../shared/widgets/extras.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/data/session.dart';
import '../data/nominee_store.dart';

/// Accident or health cover. Sample figures only.
/// TODO(benefits): load the policy from the insurer integration.
class InsuranceScreen extends ConsumerWidget {
  const InsuranceScreen({super.key, required this.kind});

  /// 'accident' or 'health'.
  final String kind;

  bool get _health => kind == 'health';

  void _addNominee(BuildContext context, WidgetRef ref) {
    showAppSheet<void>(context, builder: (_) => const _NomineeForm());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final nominee = ref.watch(nomineeProvider);
    final cover = _health ? 100000 : 200000;
    final policy = _health ? 'HC-HLT-204518' : 'HC-ACC-908231';
    final name = session.name.isEmpty ? 'HerCare expert' : session.name;

    return AppPage(
      title: _health ? 'Health insurance' : 'Accident insurance',
      actions: const [OvertimeButton()],
      children: [
        AppCard(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.softLavender, AppColors.roseSoft],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cover amount',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        FittedBox(
                          child: CountUp(
                            value: cover,
                            format: rupees,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PulseRings(
                    size: 86,
                    color: AppColors.lavender,
                    child: IconTile(
                      _health
                          ? Icons.monitor_heart_rounded
                          : Icons.shield_rounded,
                      size: 56,
                      fill: AppColors.card,
                    ),
                  ),
                ],
              ),
              const Divider(height: 28, color: AppColors.card),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Detail('Name', name),
                  _Detail('Policy no.', policy),
                ],
              ),
              if (_health) ...[
                const SizedBox(height: 14),
                const Row(
                  children: [
                    _Detail('Plan', 'HerCare Family'),
                    _Detail('Valid till', '31 Mar 2027'),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () {
            // TODO(benefits): open the share sheet.
            Clipboard.setData(
              ClipboardData(
                text: '$name, HerCare policy $policy, cover ${rupees(cover)}',
              ),
            );
            toast(context, 'Policy details copied. Paste them to share.');
          },
          icon: const Icon(Icons.ios_share_rounded),
          label: const Text('Share with family'),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () => context.push(Routes.help),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.softLavender,
            foregroundColor: AppColors.lavenderDeep,
          ),
          icon: const Icon(Icons.headset_mic_rounded),
          label: const Text('Call insurance support'),
        ),
        const SectionTitle('Nominee details'),
        AppCard(
          color: nominee == null ? AppColors.warningSoft : AppColors.card,
          onTap: () => _addNominee(context, ref),
          child: Row(
            children: [
              Icon(
                nominee == null
                    ? Icons.warning_amber_rounded
                    : Icons.family_restroom_rounded,
                color: nominee == null ? AppColors.warning : AppColors.lavender,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nominee == null
                      ? 'Add your family details'
                      : '${nominee.name} · ${nominee.relation}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
        TipsRow(
          _health
              ? const [
                  Tip(
                    Icons.local_hospital_rounded,
                    'At the hospital',
                    'Show your policy number at the insurance desk of a partner hospital.',
                  ),
                  Tip(
                    Icons.event_note_rounded,
                    'Planned care',
                    'Call support before a planned admission so it can be approved.',
                  ),
                  Tip(
                    Icons.receipt_long_rounded,
                    'Keep bills',
                    'Keep every bill and prescription until the claim is closed.',
                  ),
                ]
              : const [
                  Tip(
                    Icons.timer_rounded,
                    'Report fast',
                    'Report an accident within 24 hours.',
                  ),
                  Tip(
                    Icons.photo_camera_rounded,
                    'Take photos',
                    'Only if it is safe to do so.',
                  ),
                  Tip(
                    Icons.description_rounded,
                    'Papers',
                    'Keep the hospital discharge summary.',
                  ),
                ],
        ),
        const SizedBox(height: 18),
        AppCard(
          onTap: () => context.push(Routes.hospitals),
          child: const Row(
            children: [
              IconTile(
                Icons.local_hospital_rounded,
                color: AppColors.danger,
                fill: AppColors.dangerSoft,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cashless hospitals near you',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Treatment without paying first',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Pill('Explore'),
            ],
          ),
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

class _Detail extends StatelessWidget {
  const _Detail(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.lavenderDeep),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _NomineeForm extends ConsumerStatefulWidget {
  const _NomineeForm();

  @override
  ConsumerState<_NomineeForm> createState() => _NomineeFormState();
}

class _NomineeFormState extends ConsumerState<_NomineeForm> {
  static const _relations = ['Spouse', 'Child', 'Parent', 'Sibling'];
  late final _name = TextEditingController(
    text: ref.read(nomineeProvider)?.name,
  );
  int _relation = 0;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(nomineeProvider);
    if (saved != null) _relation = _relations.indexOf(saved.relation);
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Your nominee',
        style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
      ),
      const Text(
        'Who should receive the claim if needed',
        style: TextStyle(color: AppColors.textMuted),
      ),
      const SizedBox(height: 14),
      TextField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Nominee full name'),
      ),
      const SizedBox(height: 14),
      ChoiceChips(
        options: _relations,
        selected: _relation,
        onSelected: (i) => setState(() => _relation = i),
      ),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: _name.text.trim().isEmpty
            ? null
            : () {
                ref
                    .read(nomineeProvider.notifier)
                    .save(_name.text.trim(), _relations[_relation]);
                Navigator.pop(context);
              },
        child: const Text('Save nominee'),
      ),
    ],
  );
}
