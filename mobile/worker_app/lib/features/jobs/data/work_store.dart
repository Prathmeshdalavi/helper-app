import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/task_art.dart';
import '../../earnings/data/earnings_store.dart';
import '../../rewards/data/rewards_store.dart';
import '../domain/job.dart';
import 'demo_jobs.dart';

/// How long after going online the demo sends an offer, and how long the
/// expert has to answer it.
class JobTiming {
  const JobTiming({
    this.firstOffer = const Duration(seconds: 4),
    this.answerWithin = const Duration(seconds: 30),
  });

  final Duration firstOffer;
  final Duration answerWithin;
}

final jobTimingProvider = Provider<JobTiming>((ref) => const JobTiming());

class WorkState {
  const WorkState({
    this.online = false,
    this.offer,
    this.active,
    this.stage = JobStage.onTheWay,
    this.offered = 0,
    this.jobsToday = 0,
    this.earnedToday = 0,
    this.minutesToday = 0,
    this.startedAt,
    this.doneTasks = const {},
    this.beforePhoto = false,
    this.afterPhoto = false,
  });

  /// When work began on the active job.
  final DateTime? startedAt;
  final Set<HomeTask> doneTasks;
  final bool beforePhoto;
  final bool afterPhoto;

  final bool online;

  /// A request waiting for accept or decline.
  final Job? offer;

  /// The accepted job.
  final Job? active;
  final JobStage stage;
  final int offered;
  final int jobsToday;
  final int earnedToday;
  final int minutesToday;

  /// Waiting for the next request.
  bool get searching => online && offer == null && active == null;
}

class WorkNotifier extends Notifier<WorkState> {
  @override
  WorkState build() => const WorkState();

  WorkState _with({
    bool? online,
    Job? Function()? offer,
    Job? Function()? active,
    JobStage? stage,
    int? offered,
    int? jobsToday,
    int? earnedToday,
    int? minutesToday,
    DateTime? startedAt,
    Set<HomeTask>? doneTasks,
    bool? beforePhoto,
    bool? afterPhoto,
  }) => WorkState(
    online: online ?? state.online,
    offer: offer != null ? offer() : state.offer,
    active: active != null ? active() : state.active,
    stage: stage ?? state.stage,
    offered: offered ?? state.offered,
    jobsToday: jobsToday ?? state.jobsToday,
    earnedToday: earnedToday ?? state.earnedToday,
    minutesToday: minutesToday ?? state.minutesToday,
    startedAt: startedAt ?? state.startedAt,
    doneTasks: doneTasks ?? state.doneTasks,
    beforePhoto: beforePhoto ?? state.beforePhoto,
    afterPhoto: afterPhoto ?? state.afterPhoto,
  );

  /// TODO(jobs): PUT /experts/me/availability and start location updates.
  void setOnline(bool online) =>
      state = _with(online: online, offer: online ? null : () => null);

  void sendOffer() {
    if (!state.searching) return;
    state = _with(
      offer: () => demoJobs[state.offered % demoJobs.length],
      offered: state.offered + 1,
    );
  }

  void decline() => state = _with(offer: () => null);

  void accept() {
    final job = state.offer;
    if (job == null) return;
    state = _with(
      offer: () => null,
      active: () => job,
      stage: JobStage.onTheWay,
      doneTasks: const {},
      beforePhoto: false,
      afterPhoto: false,
    );
  }

  void arrive() => state = _with(stage: JobStage.arrived);

  void start() =>
      state = _with(stage: JobStage.working, startedAt: DateTime.now());

  void toggleTask(HomeTask task) => state = _with(
    doneTasks: state.doneTasks.contains(task)
        ? ({...state.doneTasks}..remove(task))
        : {...state.doneTasks, task},
  );

  /// TODO(jobs): capture and upload real photos.
  void addBeforePhoto() => state = _with(beforePhoto: true);

  void addAfterPhoto() => state = _with(afterPhoto: true);

  /// Finishes the job and credits pay and coins.
  void complete() {
    final job = state.active;
    if (job == null || state.stage == JobStage.completed) return;
    ref.read(earningsProvider.notifier).addJob(job.pay);
    ref.read(rewardsProvider.notifier).add(job.coins);
    state = _with(
      stage: JobStage.completed,
      jobsToday: state.jobsToday + 1,
      earnedToday: state.earnedToday + job.pay,
      minutesToday: state.minutesToday + job.durationMinutes,
    );
  }

  /// Leaves the finished (or cancelled) job and goes back to searching.
  void clearJob() => state = _with(active: () => null);

  void reset() => state = const WorkState();
}

final workProvider = NotifierProvider<WorkNotifier, WorkState>(
  WorkNotifier.new,
);
