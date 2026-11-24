import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/booking_store.dart';

/// Choose how to pay. UPI apps first, then cards and other options.
class PaymentOptionsScreen extends ConsumerStatefulWidget {
  const PaymentOptionsScreen({super.key});

  @override
  ConsumerState<PaymentOptionsScreen> createState() =>
      _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends ConsumerState<PaymentOptionsScreen> {
  bool _upiId = false;
  final _upiController = TextEditingController();

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  bool get _upiIdValid {
    final t = _upiController.text.trim();
    return RegExp(r'^[\w.\-]{2,}@[\w]{2,}$').hasMatch(t);
  }

  void _pay() => context.pushReplacement(Routes.paymentStatus);

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(draftProvider);
    final method = ref.watch(paymentMethodProvider);
    final total = draft?.bill.total ?? 0;

    return PremiumScope(
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8D70D2), Color(0xFF6C4FB3)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: PremiumTopBar(
                    title: 'Payment options',
                    subtitle: 'To pay: ₹${total.toStringAsFixed(2)}',
                    onDark: true,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _Section(
                    title: 'Pay via any UPI app',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final app in upiApps)
                              _UpiTile(
                                app: app,
                                selected: !_upiId && app.id == method.id,
                                onTap: () {
                                  setState(() => _upiId = false);
                                  ref
                                      .read(paymentMethodProvider.notifier)
                                      .select(app);
                                },
                              ),
                          ],
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 240),
                          curve: premiumEase,
                          alignment: Alignment.topCenter,
                          child: _upiId
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: TextField(
                                    controller: _upiController,
                                    onChanged: (_) => setState(() {}),
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                    decoration: InputDecoration(
                                      hintText: 'Enter UPI ID, like name@bank',
                                      filled: true,
                                      fillColor: const Color(0xFFF6F6FA),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(width: double.infinity),
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: 'Pay ₹${total.toStringAsFixed(2)}',
                          onPressed: (!_upiId || _upiIdValid) ? _pay : null,
                        ),
                        const SizedBox(height: 10),
                        SecondaryButton(
                          label: _upiId
                              ? 'Use a UPI app instead'
                              : 'More UPI options',
                          icon: _upiId
                              ? Icons.apps_rounded
                              : Icons.chevron_right_rounded,
                          onPressed: () => setState(() => _upiId = !_upiId),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Section(
                    title: 'Credit & debit cards',
                    child: _OptionRow(
                      icon: Icons.credit_card_rounded,
                      label: 'Add new card',
                      divider: false,
                      onTap: () => comingSoon(context, 'Card payments'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _Section(
                    title: 'Other options',
                    child: Column(
                      children: [
                        _OptionRow(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'Wallet',
                          hint: 'Balance ₹0',
                          onTap: () => comingSoon(context, 'Wallet payments'),
                        ),
                        _OptionRow(
                          icon: Icons.schedule_send_outlined,
                          label: 'Pay later',
                          onTap: () => comingSoon(context, 'Pay later'),
                        ),
                        _OptionRow(
                          icon: Icons.account_balance_outlined,
                          label: 'Net banking',
                          divider: false,
                          onTap: () => comingSoon(context, 'Net banking'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _UpiTile extends StatelessWidget {
  const _UpiTile({
    required this.app,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod app;
  final bool selected;
  final VoidCallback onTap;

  static const _icons = {
    'gpay': Icons.g_mobiledata_rounded,
    'phonepe': Icons.phone_android_rounded,
    'paytm': Icons.payments_outlined,
    'bhim': Icons.account_balance_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final name = app.label.replaceAll(' UPI', '');
    return Semantics(
      button: true,
      selected: selected,
      child: Pressable(
        onTap: onTap,
        scale: 0.95,
        child: SizedBox(
          width: 68,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: premiumEase,
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: selected ? premiumSelectedFill : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.lavender : AppInk.hairline,
                        width: selected ? 1.6 : 1,
                      ),
                    ),
                    child: Icon(
                      _icons[app.id] ?? Icons.payments_outlined,
                      size: 28,
                      color: selected ? AppColors.lavender : AppInk.muted,
                    ),
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: AnimatedScale(
                      scale: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: AppColors.lavender,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.hint,
    this.divider = true,
  });

  final IconData icon;
  final String label;
  final String? hint;
  final VoidCallback onTap;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  hint!,
                  style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
                ),
              ),
            const Icon(Icons.chevron_right_rounded, color: AppInk.muted),
          ],
        ),
      ),
    );
  }
}
