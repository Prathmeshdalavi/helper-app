import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/ui.dart';
import '../../earnings/data/earnings_store.dart';
import '../data/kyc_store.dart';
import '../domain/kyc.dart';
import 'step_header.dart';

/// KYC upload list, used during sign-up and from the profile.
class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key, this.onboarding = false});

  final bool onboarding;

  void _upload(BuildContext context, WidgetRef ref, KycDoc doc) {
    showAppSheet<void>(
      context,
      builder: (sheet) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            doc.title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Place it on a flat surface with good light. All four corners should be visible.',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: AppColors.softLavender,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              size: 56,
              color: AppColors.lavender,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              ref.read(kycProvider.notifier).upload(doc);
              if (doc == KycDoc.pan) {
                ref.read(earningsProvider.notifier).addPan();
              }
              Navigator.pop(sheet);
              toast(context, '${doc.title} sent for review (demo)');
            },
            icon: const Icon(Icons.photo_camera_rounded),
            label: const Text('Take photo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(kycProvider);
    final ready = KycDoc.values
        .where((d) => d.required)
        .every((d) => docs[d] != DocStatus.missing);
    return AppPage(
      title: 'Documents',
      bottom: onboarding
          ? FilledButton(
              onPressed: ready ? () => context.go(Routes.home) : null,
              child: const Text('Finish sign up'),
            )
          : null,
      children: [
        if (onboarding)
          const StepHeader(step: 2, of: 2, text: 'Verify your identity'),
        for (final doc in KycDoc.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              onTap: docs[doc] == DocStatus.missing
                  ? () => _upload(context, ref, doc)
                  : null,
              child: Row(
                children: [
                  IconTile(switch (doc) {
                    KycDoc.aadhaar => Icons.badge_rounded,
                    KycDoc.pan => Icons.credit_card_rounded,
                    KycDoc.photo => Icons.face_3_rounded,
                    KycDoc.police => Icons.verified_user_rounded,
                  }),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.required ? doc.title : '${doc.title} (optional)',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          doc.why,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  switch (docs[doc]!) {
                    DocStatus.missing => const Pill('Upload'),
                    DocStatus.inReview => const Pill(
                      'In review',
                      color: AppColors.warning,
                      fill: AppColors.warningSoft,
                    ),
                    DocStatus.verified => const Pill(
                      'Verified',
                      color: AppColors.success,
                      fill: AppColors.successSoft,
                    ),
                  },
                ],
              ),
            ),
          ),
        const SizedBox(height: 4),
        const Text(
          'Your documents are only used to verify you. Customers never see them.',
          style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
