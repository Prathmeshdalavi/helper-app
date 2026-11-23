/// What the auth screens pass to each other as the user moves through
/// login -> (sign up) -> OTP -> success.
class AuthArgs {
  const AuthArgs({
    required this.phone,
    this.name,
    this.email,
    this.isNewUser = false,
  });

  /// 10 digit number without the country code.
  final String phone;
  final String? name;
  final String? email;
  final bool isNewUser;

  String get firstName => (name ?? '').trim().split(RegExp(r'\s+')).first;
}
