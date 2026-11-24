import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/premium.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/booking_store.dart';

/// Opens "Extend service" for a running booking.
Future<void> showExtendSheet(BuildContext context, String bookingId) =>
    showPremiumSheet<void>(
      context,
      builder: (_) => _ExtendSheet(bookingId: bookingId),
    );

class _Option {
  const _Option(this.minutes, this.price);

  final int minutes;
  final int price;
}

const _options = [
  _Option(15, 49),
  _Option(30, 79),
  _Option(45, 109),
  _Option(60, 129),
];

class _ExtendSheet extends ConsumerStatefulWidget {
  const _ExtendSheet({required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<_ExtendSheet> createState() => _ExtendSheetState();
}

class _ExtendSheetState extends ConsumerState<_ExtendSheet> {
  _Option _picked = _options.first;
  bool _paying = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pay() {
    setState(() => _paying = true);
    // TODO(payments): charge through the gateway before extending.
    _timer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      ref
          .read(bookingStoreProvider.notifier)
          .extend(
            widget.bookingId,
            minutes: _picked.minutes,
            price: _picked.price,
          );
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppInk.text,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: Text('Service extended by ${_picked.minutes} min'),
            duration: const Duration(milliseconds: 1800),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final method = ref.watch(paymentMethodProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
          child: Text(
            'Extend service',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Text(
            'Add more time and your helper carries on.',
            style: TextStyle(fontSize: 13.5, color: AppInk.muted),
          ),
        ),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final o = _options[i];
              final on = o.minutes == _picked.minutes;
              return Pressable(
                onTap: () => setState(() => _picked = o),
                scale: 0.97,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: premiumEase,
                  width: 108,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: on ? premiumSelectedFill : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: on ? AppColors.lavender : AppInk.hairline,
                      width: on ? 1.4 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${o.minutes} min',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: on ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                      Text(
                        rupees(o.price),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppInk.hairline)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pay using',
                      style: TextStyle(fontSize: 11.5, color: AppInk.muted),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      method.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: FilledButton(
                  onPressed: _paying ? null : _pay,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _paying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          children: [
                            Text(
                              rupees(_picked.price),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            const Text('Pay now'),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
