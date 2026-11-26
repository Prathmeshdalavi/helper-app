import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/router/routes.dart';
import '../data/work_store.dart';
import '../domain/job.dart';
import 'job_offer_sheet.dart';

/// Wraps the signed-in shell so requests arrive on any tab. In the demo an
/// offer turns up a few seconds after the expert starts searching.
class OfferDispatcher extends ConsumerStatefulWidget {
  const OfferDispatcher({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OfferDispatcher> createState() => _OfferDispatcherState();
}

class _OfferDispatcherState extends ConsumerState<OfferDispatcher> {
  Timer? _nextOffer;
  bool _offerOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _react(ref.read(workProvider)),
    );
  }

  void _react(WorkState work) {
    if (!mounted) return;
    if (work.searching) {
      _nextOffer ??= Timer(ref.read(jobTimingProvider).firstOffer, () {
        _nextOffer = null;
        if (mounted) ref.read(workProvider.notifier).sendOffer();
      });
    } else {
      _nextOffer?.cancel();
      _nextOffer = null;
    }
    if (work.offer != null && !_offerOpen) _showOffer(work.offer!);
  }

  Future<void> _showOffer(Job job) async {
    _offerOpen = true;
    HapticFeedback.heavyImpact();
    final accepted = await showJobOffer(context, job);
    _offerOpen = false;
    if (!mounted) return;
    final work = ref.read(workProvider.notifier);
    if (accepted) {
      work.accept();
      context.push(Routes.job);
    } else {
      work.decline();
    }
  }

  @override
  void dispose() {
    _nextOffer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(workProvider, (_, next) => _react(next));
    return widget.child;
  }
}
