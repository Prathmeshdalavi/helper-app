import 'dart:math' as math;

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app_theme.dart';
import '../../features/home/presentation/widgets/common.dart';

/// Wraps a screen in the Figtree typeface and neutral ink colours.
class PremiumScope extends StatelessWidget {
  const PremiumScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.withFigtree(Theme.of(context)),
    // Text outside a Scaffold (tabs, sheets) takes its font from here.
    child: DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: 'Figtree', color: AppInk.text),
      child: child,
    ),
  );
}

const premiumSelectedFill = Color(0xFFF3EEFD);
const premiumGreen = Color(0xFF1E8E5A);
const premiumGreenFill = Color(0xFFE7F6EE);
const premiumRed = Color(0xFFD64550);
const premiumAmber = Color(0xFFD9772B);
const premiumEase = Curves.easeOutCubic;

/// "₹99" or "₹115.75" (only shows paise when there are some).
String rupees(num v) {
  final whole = v == v.roundToDouble();
  return '₹${whole ? v.round() : v.toStringAsFixed(2)}';
}

/// A short floating message at the bottom of the screen.
void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 96),
        backgroundColor: AppInk.text,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(message),
        duration: const Duration(milliseconds: 1800),
      ),
    );
}

/// A white surface with a hairline and a very soft shadow.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
    this.color = Colors.white,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppInk.hairline),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B2540).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
    return onTap == null
        ? box
        : Pressable(onTap: onTap!, scale: 0.985, child: box);
  }
}

/// Back arrow, title and an optional second line.
class PremiumTopBar extends StatelessWidget {
  const PremiumTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onTapTitle,
    this.trailing,
    this.onDark = false,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTapTitle;
  final Widget? trailing;
  final bool onDark;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final fg = onDark ? Colors.white : AppInk.text;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            onPressed: onBack ?? () => context.canPop() ? context.pop() : null,
            icon: Icon(Icons.arrow_back_rounded, size: 22, color: fg),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTapTitle,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: onDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : AppInk.muted,
                      ),
                    ),
                ],
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Filled lavender call to action.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: Size.fromHeight(height),
        backgroundColor: color,
        disabledBackgroundColor: const Color(0xFFE6E4EC),
        disabledForegroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// Outlined secondary action.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size.fromHeight(height),
        foregroundColor: AppColors.lavender,
        side: const BorderSide(color: AppColors.lavender, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Figtree',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// Icon in a soft lavender circle, used on list rows.
class IconBadge extends StatelessWidget {
  const IconBadge(this.icon, {super.key, this.size = 40, this.color});

  final IconData icon;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.lavender;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size * 0.5, color: c),
    );
  }
}

/// One row of a settings-style list: badge, title, optional subtitle, chevron.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.divider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: divider
              ? const Border(bottom: BorderSide(color: AppInk.hairline))
              : null,
        ),
        child: Row(
          children: [
            IconBadge(icon, size: 38),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppInk.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppInk.muted,
            ),
          ],
        ),
      ),
    );
  }
}

/// A scalloped status badge (check, cross) used on result screens.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.icon,
    required this.color,
    this.iconColor = Colors.white,
    this.size = 96,
    this.tilt = 0,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final double size;

  /// Resting rotation in radians; the badge turns into it as it appears.
  final double tilt;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.scale(scale: v, child: child),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ScallopPainter(color),
          child: Center(
            child: Icon(icon, size: size * 0.46, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _ScallopPainter extends CustomPainter {
  _ScallopPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    const lobes = 12;
    final path = Path();
    for (var i = 0; i <= 360; i++) {
      final a = i * math.pi / 180;
      final wobble = 1 + 0.055 * math.cos(a * lobes);
      final p = c + Offset(math.cos(a), math.sin(a)) * (r * 0.93 * wobble);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ScallopPainter old) => old.color != color;
}

/// Rounded bottom sheet with a drag handle.
Future<T?> showPremiumSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool scrollable = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollable,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) => PremiumScope(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppInk.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(child: builder(ctx)),
            ],
          ),
        ),
      ),
    ),
  );
}
