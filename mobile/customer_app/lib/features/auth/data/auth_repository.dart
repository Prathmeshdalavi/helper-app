import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Talks to the auth endpoints. Everything here is a demo stand-in until the
/// backend auth module exists.
class AuthRepository {
  /// Demo only: numbers that count as already registered.
  static const _demoRegistered = {'9876543210'};

  /// TODO(auth): replace with POST /auth/check-phone.
  Future<bool> isRegistered(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _demoRegistered.contains(phone);
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);
