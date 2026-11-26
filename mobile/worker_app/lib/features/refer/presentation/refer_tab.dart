import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/data/session.dart';
import '../data/refer_store.dart';

class ReferTab extends ConsumerWidget {
  const ReferTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referrals = ref.watch(referProvider);
    final session = ref.watch(sessionProvider);
    final code = 'HER-${session.expertId.substring(3)}';
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const PageHeader(title: 'Refer a friend'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
              children: [
                AppCard(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.roseSoft, AppColors.softLavender],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 170,
                        width: double.infinity,
                        child: ExcludeSemantics(
                          child: Loop(
                            duration: const Duration(seconds: 5),
                            builder: (context, t) => CustomPaint(
                              painter: HeroArtPainter(HeroScene.earn, t),
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Earn up to ₹5,000',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'for every friend who joins and works',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => showAppSheet<void>(
                            context,
                            builder: (_) => const _AddFriend(),
                          ),
                          icon: const Icon(Icons.person_add_rounded),
                          label: const Text('Invite a friend'),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: code));
                          toast(context, 'Code copied');
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: Text('Your code: $code'),
                      ),
                    ],
                  ),
                ),
                const SectionTitle('How it works'),
                const MenuCard(
                  children: [
                    AppRow(
                      icon: Icons.send_rounded,
                      title: 'Invite her',
                      subtitle: 'Share your code with a friend',
                    ),
                    AppRow(
                      icon: Icons.verified_user_rounded,
                      title: 'She joins',
                      subtitle: 'Documents verified and training done',
                    ),
                    AppRow(
                      icon: Icons.currency_rupee_rounded,
                      title: 'You both earn',
                      subtitle: 'Paid in parts as she completes shifts',
                    ),
                  ],
                ),
                const SectionTitle('Your referrals'),
                if (referrals.isEmpty)
                  const EmptyState(
                    icon: Icons.group_rounded,
                    title: 'No referrals yet',
                    message: 'Invite a friend to start earning.',
                  )
                else
                  MenuCard(
                    children: [
                      for (final r in referrals)
                        AppRow(
                          icon: Icons.person_rounded,
                          title: r.name,
                          subtitle: '+91 ${r.phone}',
                          trailing: Pill(r.status),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFriend extends ConsumerStatefulWidget {
  const _AddFriend();

  @override
  ConsumerState<_AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends ConsumerState<_AddFriend> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() => _error = null));
    _phone.addListener(() => setState(() => _error = null));
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _name.text.trim().isNotEmpty && _phone.text.length == 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Invite a friend',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        const Text(
          'Ask her first. Demo only: no message is sent.',
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Her name'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          decoration: const InputDecoration(hintText: 'Her mobile number'),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _error!,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: valid
              ? () {
                  if (ref
                      .read(referProvider.notifier)
                      .add(_name.text.trim(), _phone.text)) {
                    Navigator.pop(context);
                  } else {
                    setState(() => _error = 'You already invited this number');
                  }
                }
              : null,
          child: const Text('Add invite'),
        ),
      ],
    );
  }
}
