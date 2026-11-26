import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Who is signed in. In memory for now.
/// TODO(auth): hydrate from secure storage / GET /experts/me on app start.
class Session {
  const Session({
    this.phone,
    this.name = '',
    this.area = '',
    this.language = 'English',
  });

  final String? phone;
  final String name;
  final String area;
  final String language;

  bool get signedIn => phone != null;

  String get firstName {
    final n = name.trim();
    return n.isEmpty ? 'there' : n.split(RegExp(r'\s+')).first;
  }

  String get expertId =>
      'HC-${(phone ?? '000000').substring((phone?.length ?? 6) - 6)}';

  Session copyWith({
    String? phone,
    String? name,
    String? area,
    String? language,
  }) => Session(
    phone: phone ?? this.phone,
    name: name ?? this.name,
    area: area ?? this.area,
    language: language ?? this.language,
  );
}

class SessionNotifier extends Notifier<Session> {
  @override
  Session build() => const Session();

  void signIn({required String phone, String name = '', String area = ''}) =>
      state = state.copyWith(phone: phone, name: name, area: area);

  void setProfile({required String name, required String area}) =>
      state = state.copyWith(name: name, area: area);

  void setLanguage(String language) =>
      state = state.copyWith(language: language);

  void signOut() => state = Session(language: state.language);
}

final sessionProvider = NotifierProvider<SessionNotifier, Session>(
  SessionNotifier.new,
);
