import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/premium.dart';
import '../../auth/data/session.dart';
import '../../home/presentation/widgets/common.dart';

/// Opens the "Edit profile" sheet.
Future<void> showEditProfileSheet(BuildContext context) =>
    showPremiumSheet<void>(context, builder: (_) => const _EditProfile());

class _EditProfile extends ConsumerStatefulWidget {
  const _EditProfile();

  @override
  ConsumerState<_EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<_EditProfile> {
  late final Session _s = ref.read(sessionProvider);
  late final _name = TextEditingController(text: _s.name);
  late final _email = TextEditingController(text: _s.email);
  late String? _gender = _s.gender;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  bool get _emailOk {
    final t = _email.text.trim();
    return t.isEmpty || RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
  }

  bool get _valid => _name.text.trim().length >= 2 && _emailOk;

  void _save() {
    ref
        .read(sessionProvider.notifier)
        .updateProfile(
          name: _name.text.trim(),
          email: _email.text.trim(),
          gender: _gender,
        );
    // TODO(auth): PATCH /users/me.
    Navigator.of(context).pop();
    toast(context, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Edit profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F0F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: premiumSelectedFill,
                border: Border.all(color: AppInk.hairline, width: 2),
              ),
              child: Text(
                _name.text.trim().isEmpty
                    ? 'H'
                    : _name.text.trim()[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lavender,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _Label('Name'),
          _Box(
            child: TextField(
              controller: _name,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          const SizedBox(height: 14),
          _Label('E-mail', hint: 'Optional'),
          _Box(
            error: !_emailOk,
            child: TextField(
              controller: _email,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
          if (!_emailOk)
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'Enter a valid e-mail address',
                style: TextStyle(fontSize: 12, color: premiumRed),
              ),
            ),
          const SizedBox(height: 14),
          _Label('Phone number'),
          _Box(
            muted: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                _s.prettyPhone.isEmpty ? '—' : _s.prettyPhone,
                style: const TextStyle(fontSize: 15, color: AppInk.muted),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Label('Gender'),
          Row(
            children: [
              for (final g in const ['Male', 'Female', 'Other'])
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: g == 'Other' ? 0 : 10),
                    child: Pressable(
                      onTap: () => setState(() => _gender = g),
                      scale: 0.97,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 46,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: g == _gender
                              ? premiumSelectedFill
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: g == _gender
                                ? AppColors.lavender
                                : AppInk.hairline,
                            width: g == _gender ? 1.3 : 1,
                          ),
                        ),
                        child: Text(
                          g,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: g == _gender
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Update', onPressed: _valid ? _save : null),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 6),
    child: Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppInk.muted,
          ),
        ),
        if (hint != null) ...[
          const SizedBox(width: 6),
          Text(
            '($hint)',
            style: const TextStyle(fontSize: 12, color: Color(0xFFB4AEC2)),
          ),
        ],
      ],
    ),
  );
}

class _Box extends StatelessWidget {
  const _Box({required this.child, this.muted = false, this.error = false});

  final Widget child;
  final bool muted;
  final bool error;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: muted ? const Color(0xFFF6F6FA) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: error ? premiumRed : AppInk.hairline),
    ),
    child: child,
  );
}
