import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/ui.dart';
import '../../auth/presentation/login_hero.dart' show PageDots;
import '../../earnings/data/earnings_store.dart';

class _Alert {
  const _Alert(
    this.icon,
    this.title,
    this.message,
    this.action,
    this.route,
    this.color,
    this.fill,
  );

  final IconData icon;
  final String title;
  final String message;
  final String action;
  final String route;
  final Color color;
  final Color fill;
}

/// Things the expert still has to do. Finished ones drop out.
class AlertCarousel extends ConsumerStatefulWidget {
  const AlertCarousel({super.key});

  @override
  ConsumerState<AlertCarousel> createState() => _AlertCarouselState();
}

class _AlertCarouselState extends ConsumerState<AlertCarousel> {
  final _pages = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earnings = ref.watch(earningsProvider);
    final alerts = [
      if (earnings.payoutAccount == null)
        const _Alert(
          Icons.account_balance_rounded,
          'Add UPI or bank',
          'Needed before you can be paid',
          'Add',
          Routes.bank,
          AppColors.warning,
          AppColors.warningSoft,
        ),
      if (!earnings.hasPan)
        const _Alert(
          Icons.credit_card_rounded,
          'Add your PAN',
          'A smaller tax cut from your pay',
          'Add',
          Routes.documents,
          AppColors.info,
          AppColors.infoSoft,
        ),
      _Alert(
        Icons.health_and_safety_rounded,
        'Cashless treatment',
        'At partner hospitals near you',
        'View',
        Routes.insuranceFor('health'),
        AppColors.success,
        AppColors.successSoft,
      ),
    ];
    final index = _index.clamp(0, alerts.length - 1);
    return Column(
      children: [
        SizedBox(
          height: 76 * MediaQuery.textScalerOf(context).scale(14) / 14,
          child: PageView(
            controller: _pages,
            onPageChanged: (i) => setState(() => _index = i),
            children: [
              for (final a in alerts)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: AppCard(
                    color: a.fill,
                    shadow: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    onTap: () => context.push(a.route),
                    child: Row(
                      children: [
                        Icon(a.icon, color: a.color, size: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                a.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                a.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Pill(a.action, color: a.color, fill: AppColors.card),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (alerts.length > 1) ...[
          const SizedBox(height: 8),
          PageDots(count: alerts.length, index: index),
        ],
      ],
    );
  }
}
