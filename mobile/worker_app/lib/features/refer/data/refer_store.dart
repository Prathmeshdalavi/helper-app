import 'package:flutter_riverpod/flutter_riverpod.dart';

class Referral {
  const Referral(this.name, this.phone, this.status);

  final String name;
  final String phone;
  final String status;
}

/// TODO(refer): create referrals on the backend, which sends the invite.
class ReferNotifier extends Notifier<List<Referral>> {
  @override
  List<Referral> build() => const [];

  bool add(String name, String phone) {
    if (state.any((r) => r.phone == phone)) return false;
    state = [Referral(name, phone, 'Invited'), ...state];
    return true;
  }
}

final referProvider = NotifierProvider<ReferNotifier, List<Referral>>(
  ReferNotifier.new,
);
