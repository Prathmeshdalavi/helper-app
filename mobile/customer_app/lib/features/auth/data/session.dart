import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Who is signed in. In-memory for now.
/// TODO(auth): hydrate from TokenStorage / GET /users/me on app start.
class Session {
  const Session({this.name, this.phone, this.email, this.gender});

  final String? name;

  /// Optional contact email.
  final String? email;

  /// 'Male', 'Female' or 'Other'; optional.
  final String? gender;

  /// 10 digit number without the country code.
  final String? phone;

  bool get signedIn => phone != null;

  String get firstName {
    final n = (name ?? '').trim();
    return n.isEmpty ? '' : n.split(RegExp(r'\s+')).first;
  }

  String get initial => firstName.isEmpty ? 'H' : firstName[0].toUpperCase();

  String get prettyPhone {
    final p = phone;
    if (p == null || p.length != 10) return '';
    return '+91 ${p.substring(0, 5)} ${p.substring(5)}';
  }
}

class SessionNotifier extends Notifier<Session> {
  @override
  Session build() => const Session();

  void signIn({String? name, required String phone}) =>
      state = Session(name: name, phone: phone);

  void updateProfile({String? name, String? email, String? gender}) =>
      state = Session(
        name: name ?? state.name,
        phone: state.phone,
        email: email ?? state.email,
        gender: gender ?? state.gender,
      );

  void signOut() => state = const Session();
}

final sessionProvider = NotifierProvider<SessionNotifier, Session>(
  SessionNotifier.new,
);
