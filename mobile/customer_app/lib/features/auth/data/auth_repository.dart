import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Talks to the auth endpoints. Everything here is a demo stand-in until the
/// backend auth module exists.
class AuthRepository {
  /// Demo only: registered numbers and the name on each account.
  static const _demoUsers = {'9876543210': 'Anita Rao'};

  /// Returns the account name if [phone] is registered, otherwise null (a new
  /// user who must sign up first).
  /// TODO(auth): replace with POST /auth/check-phone.
  Future<String?> lookupName(String phone) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return _demoUsers[phone];
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);
