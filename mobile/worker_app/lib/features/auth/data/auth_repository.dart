import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo stand-in until the backend auth module exists.
class AuthRepository {
  /// Demo login: this number already has a verified expert account.
  static const demoPhone = '9876543210';
  static const demoOtp = '1234';

  /// TODO(auth): replace with POST /auth/send-otp.
  Future<void> sendOtp(String phone) =>
      Future<void>.delayed(const Duration(milliseconds: 500));

  /// TODO(auth): replace with POST /auth/verify-otp and store the tokens in
  /// the keychain.
  Future<bool> verifyOtp(String phone, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return code == demoOtp;
  }

  bool isRegistered(String phone) => phone == demoPhone;
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);
