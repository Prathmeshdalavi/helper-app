import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/premium.dart';
import '../../booking/presentation/book_sheet.dart';
import '../../home/presentation/widgets/common.dart';
import '../data/demo_extra_services.dart';
import '../data/demo_services.dart';

class _Hit {
  const _Hit(this.title, this.tagline, this.icon, this.open);

  final String title;
  final String tagline;
  final IconData icon;
  final void Function(BuildContext, WidgetRef) open;
}

List<_Hit> _all() => [
  for (final c in DemoServices.categories)
    _Hit(
      c.title,
      c.tagline,
      c.icon,
      (context, ref) => context.push(Routes.serviceDetail(c.id)),
    ),
  for (final e in DemoExtraServices.all)
    _Hit(
      e.title,
      e.tagline,
      e.icon,
      (context, ref) => showBookSheet(context, ref, service: e.title),
    ),
];

/// Search across every service.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  static const _popular = [
    'Bathroom cleaning',
    'Dishwashing',
    'Laundry',
    'Cooking',
    'Pet care',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setQuery(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    setState(() => _query = q);
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final hits = q.isEmpty
        ? const <_Hit>[]
        : [
            for (final h in _all())
              if (h.title.toLowerCase().contains(q) ||
                  h.tagline.toLowerCase().contains(q))
                h,
          ];

    return PremiumScope(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF7F3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppInk.muted,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                onChanged: (v) => setState(() => _query = v),
                                textInputAction: TextInputAction.search,
                                decoration: const InputDecoration(
                                  hintText: 'Search for a service',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () => _setQuery(''),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: AppInk.muted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: q.isEmpty
                      ? _Suggestions(
                          key: const ValueKey('suggest'),
                          popular: _popular,
                          onPick: _setQuery,
                        )
                      : hits.isEmpty
                      ? const _NoResults(key: ValueKey('none'))
                      : ListView.separated(
                          key: const ValueKey('hits'),
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          itemCount: hits.length,
                          separatorBuilder: (_, _) =>
                              const Divider(height: 1, color: AppInk.hairline),
                          itemBuilder: (context, i) {
                            final h = hits[i];
                            return Pressable(
                              onTap: () => h.open(context, ref),
                              scale: 0.99,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    IconBadge(h.icon, size: 44),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            h.title,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            h.tagline,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: AppInk.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppInk.muted,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({super.key, required this.popular, required this.onPick});

  final List<String> popular;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      children: [
        const Text(
          'Popular searches',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final p in popular)
              Pressable(
                onTap: () => onPick(p),
                scale: 0.97,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppInk.hairline),
                  ),
                  child: Text(
                    p,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 52, color: Color(0xFFF9D0BB)),
            SizedBox(height: 12),
            Text(
              'No services found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4),
            Text(
              'Try another word, like "cleaning".',
              style: TextStyle(fontSize: 13.5, color: AppInk.muted),
            ),
          ],
        ),
      ),
    );
  }
}
