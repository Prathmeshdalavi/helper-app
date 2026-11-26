/// Route paths in one place so screens never hard-code strings.
abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const otp = '/otp';
  static const language = '/language';
  static const profileSetup = '/profile-setup';
  static const documents = '/documents';
  static const home = '/home';
  static const job = '/job';
  static const payouts = '/payouts';
  static const earlyPayout = '/early-payout';
  static const rateCard = '/rate-card';
  static const bank = '/bank';
  static const level = '/level';
  static const performance = '/performance';
  static const attendance = '/attendance';
  static const leave = '/leave';
  static const emergencyLogout = '/emergency-logout';
  static const overtime = '/overtime';
  static const insurance = '/insurance/:kind';
  static const coins = '/coins';
  static const store = '/store';
  static const training = '/training';
  static const help = '/help';

  static String insuranceFor(String kind) => '/insurance/$kind';
}
