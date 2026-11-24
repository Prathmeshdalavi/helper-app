import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../booking/data/booking_store.dart';
import '../../booking/domain/booking.dart';
import '../../booking/presentation/bookings_tab.dart';
import '../../home/presentation/home_tab_provider.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/demo_faq.dart';
import 'edit_profile_sheet.dart';

/// Recent visits, answers to common questions and a way to chat.
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  int _tab = 0;
  int? _open;
  String _query = '';

  List<Faq> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return DemoFaq.categories[_tab].items;
    return [
      for (final c in DemoFaq.categories)
        for (final f in c.items)
          if (f.question.toLowerCase().contains(q) ||
              f.answer.toLowerCase().contains(q))
            f,
    ];
  }

  void _act(String? action) {
    switch (action) {
      case 'chat':
        context.push(Routes.support);
      case 'profile':
        showEditProfileSheet(context);
      case 'book':
        ref.read(homeTabProvider.notifier).show(0);
        context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(bookingStoreProvider);
    final recent = bookings.isEmpty ? null : bookings.first;
    final faqs = _visible;
    final searching = _query.trim().isNotEmpty;

    return PremiumScope(
      child: Scaffold(
        backgroundColor: AppInk.canvas,
        body: SafeArea(
          child: Column(
            children: [
              const PremiumTopBar(title: 'Help & support'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                  children: [
                    const _Heading('Recent visit'),
                    if (recent == null)
                      const AppCard(
                        child: Row(
                          children: [
                            IconBadge(Icons.event_note_outlined),
                            SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Your visits will show here once you book.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppInk.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _RecentVisit(booking: recent),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          ListRow(
                            icon: Icons.event_note_outlined,
                            title: 'Other visits',
                            onTap: () {
                              ref.read(homeTabProvider.notifier).show(1);
                              context.go(Routes.home);
                            },
                          ),
                          ListRow(
                            icon: Icons.currency_rupee_rounded,
                            title: 'No active refunds',
                            divider: false,
                            onTap: () =>
                                toast(context, 'No refunds in progress'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    const _Heading('Get help with other queries'),
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppInk.hairline),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: AppInk.muted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: (v) => setState(() {
                                _query = v;
                                _open = null;
                              }),
                              decoration: const InputDecoration(
                                hintText: 'Search',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!searching)
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: DemoFaq.categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 22),
                          itemBuilder: (context, i) {
                            final on = i == _tab;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() {
                                _tab = i;
                                _open = null;
                              }),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontFamily: 'Figtree',
                                      fontSize: 14.5,
                                      fontWeight: on
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: on
                                          ? AppColors.lavender
                                          : AppInk.muted,
                                    ),
                                    child: Text(DemoFaq.categories[i].title),
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 220),
                                    curve: premiumEase,
                                    height: 3,
                                    width: on ? 28 : 0,
                                    decoration: BoxDecoration(
                                      color: AppColors.lavender,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (faqs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                          child: Text(
                            'No answers found. Try chatting with us.',
                            style: TextStyle(color: AppInk.muted),
                          ),
                        ),
                      )
                    else
                      for (var i = 0; i < faqs.length; i++) ...[
                        _FaqCard(
                          faq: faqs[i],
                          open: _open == i,
                          onToggle: () =>
                              setState(() => _open = _open == i ? null : i),
                          onAction: () => _act(faqs[i].action),
                        ),
                        const SizedBox(height: 10),
                      ],
                    const SizedBox(height: 20),
                    const _Heading('Still need help?'),
                    AppCard(
                      onTap: () => context.push(Routes.support),
                      child: const Row(
                        children: [
                          IconBadge(Icons.chat_bubble_outline_rounded),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Chat with us',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppInk.muted,
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
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(
      text,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    ),
  );
}

class _RecentVisit extends StatelessWidget {
  const _RecentVisit({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final style = BookingCard.statusStyle(booking.status);
    return AppCard(
      onTap: () => context.push(Routes.bookingDetail(booking.id)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.draft.serviceTitle,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${booking.draft.instant ? 'Instant' : 'Scheduled'} · ${booking.totalMinutes} min',
                  style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: style.fill,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  style.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: style.color,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paid ${rupees(booking.bill.total + booking.extraPaid)}',
                style: const TextStyle(fontSize: 12.5, color: AppInk.muted),
              ),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: AppInk.muted),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({
    required this.faq,
    required this.open,
    required this.onToggle,
    required this.onAction,
  });

  final Faq faq;
  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onAction;

  static const _actionLabels = {
    'chat': 'Chat with us',
    'profile': 'Edit profile',
    'book': 'Book now',
  };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Pressable(
            onTap: onToggle,
            scale: 0.99,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      faq.question,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      color: AppInk.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: premiumEase,
            alignment: Alignment.topCenter,
            child: open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          faq.answer,
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.5,
                            color: AppInk.muted,
                          ),
                        ),
                        if (faq.action != null) ...[
                          const SizedBox(height: 12),
                          Pressable(
                            onTap: onAction,
                            scale: 0.97,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: premiumSelectedFill,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _actionLabels[faq.action] ?? 'Open',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.lavender,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: AppColors.lavender,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
