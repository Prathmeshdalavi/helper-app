import '../../../shared/widgets/task_art.dart';

class Job {
  const Job({
    required this.id,
    required this.service,
    required this.customer,
    required this.area,
    required this.address,
    required this.distanceKm,
    required this.etaMinutes,
    required this.durationMinutes,
    required this.pay,
    required this.coins,
    required this.tasks,
    required this.note,
  });

  final String id;
  final String service;
  final String customer;
  final String area;

  /// Shown only after the job is accepted.
  final String address;
  final double distanceKm;
  final int etaMinutes;
  final int durationMinutes;
  final int pay;
  final int coins;
  final List<HomeTask> tasks;
  final String note;
}

/// The steps of an accepted job, in order.
enum JobStage {
  onTheWay('On the way'),
  arrived('At the door'),
  working('Working'),
  completed('Done');

  const JobStage(this.label);
  final String label;
}
