import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/routes.dart';
import '../../../shared/widgets/task_art.dart';
import '../../../shared/widgets/task_grid.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/data/session.dart';
import 'step_header.dart';

/// Name, area and the kinds of work a new expert wants.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _name = TextEditingController();
  final _area = TextEditingController();
  final _skills = <HomeTask>{};

  bool get _valid =>
      _name.text.trim().length > 1 &&
      _area.text.trim().length > 1 &&
      _skills.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
    _area.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    super.dispose();
  }

  void _next() {
    // TODO(onboarding): POST /experts with name, area and skills.
    ref
        .read(sessionProvider.notifier)
        .setProfile(name: _name.text.trim(), area: _area.text.trim());
    context.push(Routes.documents, extra: true);
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'About you',
      bottom: FilledButton(
        onPressed: _valid ? _next : null,
        child: const Text('Continue'),
      ),
      children: [
        const StepHeader(step: 1, of: 2, text: 'Tell us who you are'),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(hintText: 'Full name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _area,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Area you want to work in',
          ),
        ),
        const SectionTitle('What work can you do?'),
        TaskGrid(
          selected: _skills,
          onToggle: (t) => setState(
            () => _skills.contains(t) ? _skills.remove(t) : _skills.add(t),
          ),
        ),
      ],
    );
  }
}
