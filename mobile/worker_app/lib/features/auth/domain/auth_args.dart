/// What the sign-in screens pass to each other.
class AuthArgs {
  const AuthArgs({required this.phone});

  /// 10 digit number without the country code.
  final String phone;

  String get pretty => phone.length == 10
      ? '+91 ${phone.substring(0, 5)} ${phone.substring(5)}'
      : '+91 $phone';
}
