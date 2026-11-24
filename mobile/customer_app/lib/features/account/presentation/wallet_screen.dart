import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../shared/widgets/premium.dart';
import '../../booking/data/booking_store.dart';
import '../../booking/domain/booking.dart';
import '../../booking/domain/when.dart';
import '../../home/presentation/widgets/common.dart';

/// Balance, add money and recent transactions.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Until the wallet backend exists the balance is zero.
    // TODO(wallet): GET /wallet for balances and transactions.
    const cash = 0;
    const bonus = 0;
    final paid = [
      for (final b in ref.watch(bookingStoreProvider))
        if (b.status != BookingStatus.cancelled) b,
    ];

    return PremiumScope(
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: AppInk.canvas,
                child: const PremiumTopBar(title: 'Wallet'),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_balance_wallet_rounded,
                                size: 20,
                                color: AppColors.lavender,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Available balance',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppInk.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rupees(cash + bonus),
                            style: const TextStyle(
                              fontSize: 44,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _Pot(
                                  icon: Icons.payments_outlined,
                                  label: 'Cash',
                                  amount: cash,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _Pot(
                                  icon: Icons.card_giftcard_rounded,
                                  label: 'Bonus',
                                  amount: bonus,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: 'Add money',
                            icon: Icons.add_rounded,
                            onPressed: () => _showAddMoney(context),
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
                    if (paid.isEmpty)
                      const _NoTransactions()
                    else
                      AppCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            for (var i = 0; i < paid.length; i++)
                              _TxRow(
                                booking: paid[i],
                                divider: i != paid.length - 1,
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
      ),
    );
  }

  void _showAddMoney(BuildContext context) {
    showPremiumSheet<void>(context, builder: (_) => const _AddMoney());
  }
}

class _Pot extends StatelessWidget {
  const _Pot({required this.icon, required this.label, required this.amount});

  final IconData icon;
  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppInk.muted),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: AppInk.muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rupees(amount),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TxRow extends StatelessWidget {
  const _TxRow({required this.booking, required this.divider});

  final Booking booking;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    final total = booking.bill.total + booking.extraPaid;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: divider
            ? const Border(bottom: BorderSide(color: AppInk.hairline))
            : null,
      ),
      child: Row(
        children: [
          const IconBadge(Icons.north_east_rounded, size: 38),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paid for ${booking.draft.serviceTitle}',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${dayLabel(booking.createdAt, DateTime.now())} · ${booking.paidWith}',
                  style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
                ),
              ],
            ),
          ),
          Text(
            '−₹${total.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _NoTransactions extends StatelessWidget {
  const _NoTransactions();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 52, color: Color(0xFFCFC8DE)),
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

class _AddMoney extends StatefulWidget {
  const _AddMoney();

  @override
  State<_AddMoney> createState() => _AddMoneyState();
}

class _AddMoneyState extends State<_AddMoney> {
  int _amount = 500;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
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
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final a in const [100, 200, 500, 1000, 2000])
                Pressable(
                  onTap: () => setState(() => _amount = a),
                  scale: 0.97,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
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
                        fontSize: 15,
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
            // TODO(wallet): start a payment, then credit the wallet.
            onPressed: () {
              Navigator.of(context).pop();
              comingSoon(context, 'Adding money');
            },
          ),
        ],
      ),
    );
  }
}
