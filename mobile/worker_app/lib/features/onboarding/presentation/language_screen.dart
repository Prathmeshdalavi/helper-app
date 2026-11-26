import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/data/session.dart';

/// Used both during sign-up and from the profile menu.
/// TODO(i18n): translate the app; for now the choice is only remembered.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key, this.onboarding = false});

  final bool onboarding;

  static const languages = <(String, String)>[
    ('English', 'English'),
    ('Hindi', 'हिन्दी'),
    ('Marathi', 'मराठी'),
    ('Kannada', 'ಕನ್ನಡ'),
    ('Tamil', 'தமிழ்'),
    ('Telugu', 'తెలుగు'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(sessionProvider.select((s) => s.language));
    return AppPage(
      title: 'Choose language',
      bottom: FilledButton(
        onPressed: () =>
            onboarding ? context.push(Routes.profileSetup) : context.pop(),
        child: Text(onboarding ? 'Continue' : 'Done'),
      ),
      children: [
        const Text(
          'Pick the language you are most comfortable with.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 18),
        GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 100,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final (name, native) in languages)
              AppCard(
                onTap: () =>
                    ref.read(sessionProvider.notifier).setLanguage(name),
                color: name == selected ? AppColors.lavender : AppColors.card,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      native,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: name == selected
                            ? AppColors.white
                            : AppColors.text,
                      ),
                    ),
                    Text(
                      name == selected ? '$name  ✓' : name,
                      style: TextStyle(
                        color: name == selected
                            ? AppColors.white
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
