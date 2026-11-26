import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../booking/data/booking_store.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/when.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/wallet_store.dart';

enum _Filter { all, added, spent }

/// A line in the list: a wallet entry, or a booking paid another way.
class _Line {
  const _Line(this.title, this.detail, this.amount, this.at, this.external);

  final String title;
  final String detail;
  final double amount;
  final DateTime at;

  /// Paid with UPI or card, so it did not touch the wallet.
  final bool external;
}

/// Balance, add money, and what came in and went out.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  _Filter _filter = _Filter.all;

  List<_Line> _lines(WalletState wallet, List<Booking> bookings) {
    final now = DateTime.now();
    final lines = <_Line>[
      for (final e in wallet.entries)
        _Line(e.title, e.detail ?? dayLabel(e.at, now), e.amount, e.at, false),
      for (final b in bookings)
        if (b.paidWith != 'Wallet' && b.status != BookingStatus.cancelled)
          _Line(
            'Paid for ${b.draft.serviceTitle}',
            '${dayLabel(b.createdAt, now)} · ${b.paidWith}',
            -(b.bill.total + b.extraPaid),
            b.createdAt,
            true,
          ),
    ]..sort((a, b) => b.at.compareTo(a.at));
    return switch (_filter) {
      _Filter.all => lines,
      _Filter.added => [
        for (final l in lines)
          if (l.amount > 0) l,
      ],
      _Filter.spent => [
        for (final l in lines)
          if (l.amount < 0) l,
      ],
    };
  }

  void _add(int amount) {
    context.push(Routes.payment, extra: amount);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final bookings = ref.watch(bookingStoreProvider);
    final lines = _lines(wallet, bookings);

    return PremiumScope(
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: SafeArea(
          child: Column(
            children: [
              const PremiumTopBar(title: 'Wallet'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                  children: [
                    _BalanceCard(
                      wallet: wallet,
                      onAdd: () => _showAddMoney(context, _add),
                    ),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text(
                        'Quick add',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (final a in const [100, 200, 500, 1000])
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: a == 1000 ? 0 : 10,
                              ),
                              child: _QuickAmount(
                                amount: a,
                                onTap: () => _add(a),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: premiumGreenFill,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.card_giftcard_rounded,
                            size: 20,
                            color: premiumGreen,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Add ₹500 or more and get 5% extra as bonus. '
                              'Use it on any booking.',
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.4,
                                color: premiumGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _Filters(
                      value: _filter,
                      onChanged: (f) => setState(() => _filter = f),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: lines.isEmpty
                          ? _NoTransactions(key: ValueKey('empty-$_filter'))
                          : AppCard(
                              key: ValueKey('list-$_filter'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                children: [
                                  for (var i = 0; i < lines.length; i++)
                                    _TxRow(
                                      line: lines[i],
                                      divider: i != lines.length - 1,
                                    ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.wallet, required this.onAdd});

  final WalletState wallet;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    Widget pot(IconData icon, String label, double value) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    rupees(value),
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF38383C), Color(0xFF18181B), Color(0xFF050505)],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.lavender.withValues(alpha: 0.35),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 8),
              Text(
                'Available balance',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween(end: wallet.balance),
            duration: const Duration(milliseconds: 600),
            curve: premiumEase,
            builder: (context, v, _) => Text(
              rupees(v),
              style: const TextStyle(
                fontSize: 44,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              pot(Icons.payments_outlined, 'Cash', wallet.cash),
              const SizedBox(width: 10),
              pot(Icons.card_giftcard_rounded, 'Bonus', wallet.bonus),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onAdd,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF141414),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 20),
                SizedBox(width: 6),
                Text('Add money'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAmount extends StatelessWidget {
  const _QuickAmount({required this.amount, required this.onTap});

  final int amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bonus = WalletNotifier.bonusFor(amount);
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppInk.hairline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rupees(amount),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            if (bonus > 0)
              Text(
                '+${rupees(bonus)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: premiumGreen,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.value, required this.onChanged});

  final _Filter value;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = {
      _Filter.all: 'All',
      _Filter.added: 'Added',
      _Filter.spent: 'Spent',
    };
    return Row(
      children: [
        for (final f in _Filter.values)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Pressable(
              onTap: () => onChanged(f),
              scale: 0.97,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: f == value ? AppColors.lavender : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: f == value ? AppColors.lavender : AppInk.hairline,
                  ),
                ),
                child: Text(
                  labels[f]!,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: f == value ? Colors.white : AppInk.text,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.line, required this.divider});

  final _Line line;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final credit = line.amount > 0;
    final amount = line.amount.abs();
    final text = amount == amount.roundToDouble()
        ? amount.round().toString()
        : amount.toStringAsFixed(2);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: AppInk.hairline))
            : null,
      ),
      child: Row(
        children: [
          IconBadge(
            credit ? Icons.south_west_rounded : Icons.north_east_rounded,
            size: 40,
            color: credit ? premiumGreen : AppColors.lavender,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line.detail,
                  style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
                ),
              ],
            ),
          ),
          Text(
            '${credit ? '+' : '−'}₹$text',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: credit
                  ? premiumGreen
                  : (line.external ? AppInk.muted : AppInk.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoTransactions extends StatelessWidget {
  const _NoTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 52, color: Color(0xFFF9D0BB)),
          SizedBox(height: 12),
          Text(
            'No transactions yet',
            style: TextStyle(fontSize: 15, color: AppInk.muted),
          ),
        ],
      ),
    );
  }
}

void _showAddMoney(BuildContext context, ValueChanged<int> onContinue) {
  showPremiumSheet<void>(
    context,
    builder: (_) => _AddMoney(onContinue: onContinue),
  );
}

class _AddMoney extends StatefulWidget {
  const _AddMoney({required this.onContinue});

  final ValueChanged<int> onContinue;

  @override
  State<_AddMoney> createState() => _AddMoneyState();
}

class _AddMoneyState extends State<_AddMoney> {
  final _controller = TextEditingController(text: '500');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_controller.text.trim()) ?? 0;
  bool get _valid => _amount >= 50 && _amount <= 10000;

  void _set(int a) {
    _controller.text = '$a';
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bonus = WalletNotifier.bonusFor(_amount);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 22 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add money',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pay from your wallet at checkout.',
            style: TextStyle(fontSize: 13.5, color: AppInk.muted),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF7F4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text(
                  '₹',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: Text(
              _amount > 0 && !_valid
                  ? 'Enter an amount from ₹50 to ₹10,000'
                  : (bonus > 0
                        ? 'You get ${rupees(bonus)} extra as bonus'
                        : ''),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _valid ? premiumGreen : premiumRed,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in const [100, 200, 500, 1000, 2000])
                Pressable(
                  onTap: () => _set(a),
                  scale: 0.97,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: a == _amount ? premiumSelectedFill : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: a == _amount
                            ? AppColors.lavender
                            : AppInk.hairline,
                        width: a == _amount ? 1.3 : 1,
                      ),
                    ),
                    child: Text(
                      rupees(a),
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: a == _amount
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'Add ${rupees(_amount)}',
            onPressed: _valid
                ? () {
                    final a = _amount;
                    Navigator.of(context).pop();
                    widget.onContinue(a);
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
