import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/app_theme.dart';
import '../../../app/router/routes.dart';
import '../../../shared/widgets/art.dart';
import '../../../shared/widgets/code_field.dart';
import '../../../shared/widgets/task_art.dart';
import '../../../shared/widgets/ui.dart';
import '../../support/presentation/sos_sheet.dart';
import '../data/work_store.dart';
import '../domain/job.dart';
import 'job_done_view.dart';

/// The live job: travel, check in with the customer's code, work, finish.
class JobScreen extends ConsumerStatefulWidget {
  const JobScreen({super.key});

  /// Demo start code the customer reads out.
  /// TODO(jobs): verify the code with the backend.
  static const demoStartCode = '1234';

  @override
  ConsumerState<JobScreen> createState() => _JobScreenState();
}

class _JobScreenState extends ConsumerState<JobScreen> {
  final _code = TextEditingController();
  Timer? _clock;
  bool _wrongCode = false;

  @override
  void initState() {
    super.initState();
    _code.addListener(() => setState(() => _wrongCode = false));
    if (ref.read(workProvider).stage == JobStage.working) _startClock();
  }

  void _startClock() {
    _clock?.cancel();
    _clock = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _clock?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _checkIn() {
    if (_code.text != JobScreen.demoStartCode) {
      HapticFeedback.heavyImpact();
      _code.clear();
      setState(() => _wrongCode = true);
      return;
    }
    FocusScope.of(context).unfocus();
    ref.read(workProvider.notifier).start();
    _startClock();
  }

  void _finish() {
    _clock?.cancel();
    HapticFeedback.heavyImpact();
    ref.read(workProvider.notifier).complete();
  }

  @override
  Widget build(BuildContext context) {
    final work = ref.watch(workProvider);
    final job = work.active;
    if (job == null) {
      return const AppPage(
        title: 'Job',
        children: [
          EmptyState(
            icon: Icons.work_off_rounded,
            title: 'No active job',
            message: 'New requests appear on Home.',
          ),
        ],
      );
    }
    final stage = work.stage;
    if (stage == JobStage.completed) {
      return JobDoneView(
        job: job,
        onDone: () {
          ref.read(workProvider.notifier).clearJob();
          context.canPop() ? context.pop() : context.go(Routes.home);
        },
      );
    }

    return AppPage(
      title: job.service,
      actions: [
        IconButton(
          tooltip: 'Help',
          onPressed: () => context.push(Routes.help),
          icon: const Icon(
            Icons.headset_mic_rounded,
            color: AppColors.lavender,
          ),
        ),
        IconButton(
          tooltip: 'Emergency SOS',
          onPressed: () => showSosSheet(context),
          icon: const Icon(Icons.sos_rounded, color: AppColors.danger),
        ),
      ],
      bottom: switch (stage) {
        JobStage.onTheWay => FilledButton(
          onPressed: ref.read(workProvider.notifier).arrive,
          child: const Text("I've arrived"),
        ),
        JobStage.arrived => FilledButton(
          onPressed: _code.text.length == 4 && work.beforePhoto
              ? _checkIn
              : null,
          child: const Text('Start job'),
        ),
        _ => FilledButton(
          onPressed:
              work.doneTasks.length == job.tasks.length && work.afterPhoto
              ? _finish
              : null,
          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          child: const Text('Finish job'),
        ),
      },
      children: [
        _Steps(stage: stage),
        const SizedBox(height: 16),
        ...switch (stage) {
          JobStage.onTheWay => _travel(job),
          JobStage.arrived => _arrived(job, work),
          _ => _working(job, work),
        },
      ],
    );
  }

  List<Widget> _travel(Job job) => [
    ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 240,
        child: Semantics(
          label: 'Map of the route to ${job.area}',
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 0.82),
            duration: const Duration(seconds: 9),
            builder: (context, v, _) => CustomPaint(
              size: Size.infinite,
              painter: MapPainter(route: true, progress: v),
            ),
          ),
        ),
      ),
    ),
    const SizedBox(height: 14),
    _CustomerCard(job: job),
    const SizedBox(height: 12),
    FilledButton.icon(
      // TODO(jobs): hand off to the maps app.
      onPressed: () => toast(context, 'Opens maps navigation (demo)'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.softLavender,
        foregroundColor: AppColors.lavenderDeep,
      ),
      icon: const Icon(Icons.navigation_rounded),
      label: Text('Navigate · ${job.etaMinutes} min'),
    ),
  ];

  List<Widget> _arrived(Job job, WorkState work) => [
    AppCard(
      child: Column(
        children: [
          const Text(
            'Ask for the start code',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            '${job.customer} has a 4 digit code in her app',
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          CodeField(
            controller: _code,
            label: 'Customer start code',
            error: _wrongCode,
            autofocus: false,
          ),
          const SizedBox(height: 10),
          Text(
            _wrongCode
                ? 'That code does not match'
                : 'Demo code: ${JobScreen.demoStartCode}',
            style: TextStyle(
              fontSize: 12.5,
              color: _wrongCode ? AppColors.danger : AppColors.textMuted,
            ),
          ),
        ],
      ),
    ),
    const SizedBox(height: 12),
    _PhotoTile(
      label: 'Before photo',
      taken: work.beforePhoto,
      onTap: ref.read(workProvider.notifier).addBeforePhoto,
    ),
    const SizedBox(height: 12),
    _CustomerCard(job: job),
  ];

  List<Widget> _working(Job job, WorkState work) {
    final ticked = work.doneTasks;
    final seconds = DateTime.now()
        .difference(work.startedAt ?? DateTime.now())
        .inSeconds;
    final left = job.durationMinutes * 60 - seconds;
    String two(int v) => v.toString().padLeft(2, '0');
    return [
      Center(
        child: SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: (seconds / (job.durationMinutes * 60)).clamp(0, 1),
                strokeWidth: 12,
                strokeCap: StrokeCap.round,
                backgroundColor: AppColors.softLavender,
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${two(left.abs() ~/ 60)}:${two(left.abs() % 60)}',
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      left >= 0 ? 'time left' : 'extra time',
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SectionTitle('Tick off each task'),
      MenuCard(
        children: [
          for (final t in job.tasks)
            Pressable(
              onTap: () => ref.read(workProvider.notifier).toggleTask(t),
              label: t.label,
              selected: ticked.contains(t),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    TaskArt(t, size: 44),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        t.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Icon(
                      ticked.contains(t)
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: ticked.contains(t)
                          ? AppColors.success
                          : AppColors.lavenderLight,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 12),
      _PhotoTile(
        label: 'After photo',
        taken: work.afterPhoto,
        onTap: ref.read(workProvider.notifier).addAfterPhoto,
      ),
    ];
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.stage});

  final JobStage stage;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final s in JobStage.values.take(3))
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 6,
                  decoration: BoxDecoration(
                    color: s.index <= stage.index
                        ? AppColors.lavender
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: s == stage ? FontWeight.w700 : FontWeight.w500,
                    color: s == stage
                        ? AppColors.lavender
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ExpertAvatar(size: 44, seed: 1, label: 'Customer picture'),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                job.customer,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // TODO(jobs): call and chat through a masked number.
            IconButton.filledTonal(
              tooltip: 'Call customer',
              onPressed: () => toast(context, 'Calls are masked (demo)'),
              icon: const Icon(Icons.call_rounded),
            ),
            IconButton.filledTonal(
              tooltip: 'Message customer',
              onPressed: () => toast(context, 'Chat is not built yet'),
              icon: const Icon(Icons.chat_bubble_rounded),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(job.address),
        const SizedBox(height: 8),
        Pill(
          job.note,
          icon: Icons.sticky_note_2_rounded,
          color: AppColors.warning,
          fill: AppColors.warningSoft,
        ),
      ],
    ),
  );
}

/// TODO(jobs): capture and upload a real photo; the demo only marks it done.
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.label,
    required this.taken,
    required this.onTap,
  });

  final String label;
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppCard(
    color: taken ? AppColors.successSoft : AppColors.card,
    onTap: taken ? null : onTap,
    child: Row(
      children: [
        IconTile(
          taken ? Icons.check_rounded : Icons.photo_camera_rounded,
          color: taken ? AppColors.success : AppColors.lavender,
          fill: taken ? AppColors.card : AppColors.softLavender,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            taken ? '$label added' : 'Take ${label.toLowerCase()}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
