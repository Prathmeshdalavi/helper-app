import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/premium.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/booking_store.dart';
import '../domain/booking.dart';

const _gold = Color(0xFFF2B84B);

/// Opens the rating sheet for a finished booking, then offers an invite.
Future<void> showRatingSheet(
  BuildContext context,
  Booking booking, {
  int initialStars = 0,
}) async {
  final submitted = await showPremiumSheet<bool>(
    context,
    builder: (_) => _RatingSheet(booking: booking, initialStars: initialStars),
  );
  if (submitted == true && context.mounted) {
    await showInviteSheet(context);
  }
}

class _RatingSheet extends ConsumerStatefulWidget {
  const _RatingSheet({required this.booking, required this.initialStars});

  final Booking booking;
  final int initialStars;

  @override
  ConsumerState<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends ConsumerState<_RatingSheet> {
  late int _stars = widget.initialStars;
  bool _extra = false;
  late bool _favourite = widget.booking.favourited;

  static const _labels = ['', 'Poor', 'Fair', 'Good', 'Very good', 'Excellent'];

  void _submit() {
    final store = ref.read(bookingStoreProvider.notifier);
    store.rate(widget.booking.id, stars: _stars, extraStar: _extra);
    store.favourite(widget.booking.id, _favourite);
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop(true);
    if (_favourite && !widget.booking.favourited) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: premiumGreenFill,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: const Text(
              'Added to favourites',
              style: TextStyle(color: AppInk.text),
            ),
            duration: const Duration(milliseconds: 1800),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expert = widget.booking.expert;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your rating',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          if (expert != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Service by ${expert.name}',
                style: const TextStyle(fontSize: 13.5, color: AppInk.muted),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                Semantics(
                  button: true,
                  label: '$i star${i == 1 ? '' : 's'}',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _stars = i;
                        if (i < 5) _extra = false;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: AnimatedScale(
                        scale: i <= _stars ? 1.12 : 1,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          Icons.star_rounded,
                          size: 46,
                          color: i <= _stars ? _gold : const Color(0xFFE3E0EA),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                _labels[_stars],
                key: ValueKey(_stars),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppInk.muted,
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: premiumEase,
            alignment: Alignment.topCenter,
            child: _stars == 5
                ? Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Pressable(
                      onTap: () => setState(() => _extra = !_extra),
                      scale: 0.985,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: _extra
                              ? const Color(0xFFFFF6DE)
                              : const Color(0xFFF6F6FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _extra ? _gold : AppInk.hairline,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _extra
                                  ? Icons.auto_awesome_rounded
                                  : Icons.auto_awesome_outlined,
                              color: _extra ? _gold : AppInk.muted,
                              size: 30,
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Did your expert go the extra mile? '
                                'Add an extra star.',
                                style: TextStyle(fontSize: 14, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 16),
          Pressable(
            onTap: () => setState(() => _favourite = !_favourite),
            scale: 0.985,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF3E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAE4F7),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      expert?.initial ?? 'H',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lavender,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Want ${expert?.name.split(' ').first ?? 'them'} to '
                          'assist you again?',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Add to your favourite experts',
                          style: TextStyle(fontSize: 12.5, color: AppInk.muted),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: _favourite ? AppColors.lavender : Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: _favourite
                            ? AppColors.lavender
                            : const Color(0xFFD5D1DD),
                        width: 1.5,
                      ),
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _favourite ? 1 : 0,
                      child: const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Skip',
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: 'Submit',
                  onPressed: _stars == 0 ? null : _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Invite a friend and get ₹200".
Future<void> showInviteSheet(BuildContext context) =>
    showPremiumSheet<void>(context, builder: (_) => const _InviteSheet());

class _InviteSheet extends StatelessWidget {
  const _InviteSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8D70D2), Color(0xFF5E41A6)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Invite a friend\nand get ₹200',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your friend gets ₹50 on their first booking.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 26),
          const _PhonePair(),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'https://hercare.app/invite'),
                    );
                    Navigator.of(context).pop();
                    comingSoon(context, 'Sharing');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'Figtree',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Copy link'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    comingSoon(context, 'Sharing');
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5E41A6),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ios_share_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Share'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom * 0.4),
        ],
      ),
    );
  }
}

/// Two painted phones, one handing a gift to the other.
class _PhonePair extends StatelessWidget {
  const _PhonePair();

  @override
  Widget build(BuildContext context) {
    Widget phone({
      required Color screen,
      required Color ink,
      double turns = 0,
    }) {
      return Transform.rotate(
        angle: turns,
        child: Container(
          width: 96,
          height: 168,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFF3B2C6B),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: screen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_rounded, color: ink, size: 28),
                const SizedBox(height: 6),
                Text(
                  'HerCare',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 50,
            child: phone(
              screen: AppColors.lavender,
              ink: Colors.white,
              turns: -0.14,
            ),
          ),
          Positioned(
            right: 50,
            child: phone(
              screen: Colors.white,
              ink: AppColors.lavender,
              turns: 0.14,
            ),
          ),
          const Positioned(
            top: 0,
            child: Icon(Icons.auto_awesome_rounded, color: _gold, size: 30),
          ),
          Positioned(
            left: 18,
            bottom: 30,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
          ),
          Positioned(
            right: 24,
            top: 24,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white.withValues(alpha: 0.7),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
