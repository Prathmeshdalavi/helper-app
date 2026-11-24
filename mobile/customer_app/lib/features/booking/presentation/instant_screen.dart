import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/booking_store.dart';
import '../data/demo_instant.dart';
import '../domain/booking.dart';
import 'instant_map.dart';

const _selectedFill = Color(0xFFF3EEFD);
const _ease = Curves.easeOutCubic;

/// "Instant": the nearest helper, at your door in minutes.
class InstantScreen extends StatelessWidget {
  const InstantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.withFigtree(Theme.of(context)),
      child: const _InstantBody(),
    );
  }
}

class _InstantBody extends ConsumerStatefulWidget {
  const _InstantBody();

  @override
  ConsumerState<_InstantBody> createState() => _InstantBodyState();
}

class _InstantBodyState extends ConsumerState<_InstantBody> {
  InstantHelper _helper = DemoInstant.helpers.first;
  InstantDuration _duration = DemoInstant.durations[1];

  void _continue() {
    ref
        .read(draftProvider.notifier)
        .set(
          BookingDraft(
            serviceTitle: 'Home help',
            start: DateTime.now(),
            minutes: _duration.minutes,
            price: _duration.price,
            originalPrice: _duration.originalPrice,
            instant: true,
            etaMinutes: _helper.etaMinutes,
            expertName: _helper.isBest ? null : _helper.name,
          ),
        );
    context.push(Routes.checkout);
  }

  void _pickHelper(InstantHelper h) {
    setState(() {
      _helper = h;
      // Keep the visit length inside what this helper is free for.
      if (_duration.minutes > h.maxMinutes) {
        _duration = DemoInstant.durations.lastWhere(
          (d) => d.minutes <= h.maxMinutes,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapHeight = (MediaQuery.sizeOf(context).height * 0.34).clamp(
      210.0,
      320.0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: mapHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                InstantMap(selected: _helper),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  left: 14,
                  child: _BackButton(),
                ),
                Positioned(
                  top: MediaQuery.paddingOf(context).top + 8,
                  left: 66,
                  right: 14,
                  child: const _AddressPill(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2B2540).withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 18, 0, 16),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Choose a helper',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _EtaPill(minutes: _helper.etaMinutes),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _HelperRow(selected: _helper, onPick: _pickHelper),
                      const SizedBox(height: 22),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Select duration',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _DurationGrid(
                          selected: _duration,
                          maxMinutes: _helper.maxMinutes,
                          onPick: (d) => setState(() => _duration = d),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _ContinueBar(
            price: _duration.price,
            eta: _helper.etaMinutes,
            onTap: _continue,
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: Pressable(
        onTap: () => context.canPop() ? context.pop() : null,
        scale: 0.94,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
      ),
    );
  }
}

class _AddressPill extends StatelessWidget {
  const _AddressPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.home_rounded, size: 17, color: AppColors.lavender),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Home  ·  Sector 6, Navi Mumbai',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Icon(Icons.expand_more_rounded, size: 20, color: AppInk.muted),
        ],
      ),
    );
  }
}

class _EtaPill extends StatelessWidget {
  const _EtaPill({required this.minutes});

  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
      decoration: BoxDecoration(
        color: _selectedFill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 15, color: AppColors.lavender),
          const SizedBox(width: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: Text(
              '$minutes min',
              key: ValueKey(minutes),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.lavender,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelperRow extends StatelessWidget {
  const _HelperRow({required this.selected, required this.onPick});

  final InstantHelper selected;
  final ValueChanged<InstantHelper> onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DemoInstant.helpers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final h = DemoInstant.helpers[i];
          final on = h.id == selected.id;
          return Semantics(
            button: true,
            selected: on,
            child: Pressable(
              onTap: () => onPick(h),
              scale: 0.97,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: _ease,
                width: 94,
                padding: const EdgeInsets.fromLTRB(8, 9, 8, 8),
                decoration: BoxDecoration(
                  color: on ? _selectedFill : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: on ? AppColors.lavender : AppInk.hairline,
                    width: on ? 1.3 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: h.isBest
                            ? AppColors.lavender
                            : const Color(0xFFEAE4F7),
                        shape: BoxShape.circle,
                      ),
                      child: h.isBest
                          ? const Icon(
                              Icons.bolt_rounded,
                              size: 21,
                              color: Colors.white,
                            )
                          : Text(
                              h.initial,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lavender,
                              ),
                            ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        h.name,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: on ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    h.isBest
                        ? Text(
                            '${h.etaMinutes} min',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppInk.muted,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: Color(0xFFF2B84B),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${h.rating}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppInk.muted,
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DurationGrid extends StatelessWidget {
  const _DurationGrid({
    required this.selected,
    required this.maxMinutes,
    required this.onPick,
  });

  final InstantDuration selected;
  final int maxMinutes;
  final ValueChanged<InstantDuration> onPick;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        const gap = 10.0;
        final w = (box.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final d in DemoInstant.durations)
              SizedBox(
                width: w,
                child: _DurationCard(
                  duration: d,
                  selected: d.minutes == selected.minutes,
                  available: d.minutes <= maxMinutes,
                  onTap: () => onPick(d),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DurationCard extends StatelessWidget {
  const _DurationCard({
    required this.duration,
    required this.selected,
    required this.available,
    required this.onTap,
  });

  final InstantDuration duration;
  final bool selected;
  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      enabled: available,
      child: Pressable(
        onTap: available ? onTap : () {},
        scale: 0.97,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: _ease,
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: !available
                ? const Color(0xFFF8F8FB)
                : (selected ? _selectedFill : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected && available
                  ? AppColors.lavender
                  : AppInk.hairline,
              width: selected && available ? 1.3 : 1,
            ),
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: available ? 1 : 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  duration.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                if (available)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          '₹${duration.price}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '₹${duration.originalPrice}',
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF9B97A6),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Text(
                    'Not available',
                    style: TextStyle(fontSize: 11.5, color: AppInk.muted),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContinueBar extends StatelessWidget {
  const _ContinueBar({
    required this.price,
    required this.eta,
    required this.onTap,
  });

  final int price;
  final int eta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom * 0.5),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppInk.hairline)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    '₹$price',
                    key: ValueKey(price),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Arrives in about $eta min',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, color: AppInk.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: FilledButton(
              onPressed: onTap,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
