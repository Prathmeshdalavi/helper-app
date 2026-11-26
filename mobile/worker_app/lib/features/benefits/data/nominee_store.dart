import 'package:flutter_riverpod/flutter_riverpod.dart';

class Nominee {
  const Nominee(this.name, this.relation);

  final String name;
  final String relation;
}

/// One nominee covers both policies.
class NomineeNotifier extends Notifier<Nominee?> {
  @override
  Nominee? build() => null;

  void save(String name, String relation) => state = Nominee(name, relation);
}

final nomineeProvider = NotifierProvider<NomineeNotifier, Nominee?>(
  NomineeNotifier.new,
);
