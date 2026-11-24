/// Route paths in one place so screens never hard-code strings.
abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const success = '/success';
  static const home = '/home';
  static const schedule = '/schedule';
  static const search = '/search';
  static const explore = '/explore';
  static const wallet = '/wallet';
  static const help = '/help';
  static const support = '/support';
  static const experts = '/experts';
  static const favourites = '/favourites';
  static const manageAccount = '/manage-account';
  static const checkout = '/checkout';
  static const payment = '/payment';
  static const paymentStatus = '/payment-status';
  static const paymentFailed = '/payment-failed';
  static const booking = '/booking/:id';
  static const instant = '/instant';
  static const service = '/service/:id';

  /// Path for one service's detail screen.
  static String serviceDetail(String id) => '/service/$id';

  /// Path for one booking's live screen.
  static String bookingDetail(String id) => '/booking/$id';
}
