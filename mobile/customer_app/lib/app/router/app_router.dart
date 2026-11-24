import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_args.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/success_screen.dart';
import '../../features/booking/presentation/booking_detail_screen.dart';
import '../../features/booking/presentation/checkout_screen.dart';
import '../../features/booking/presentation/instant_screen.dart';
import '../../features/booking/presentation/payment_options_screen.dart';
import '../../features/booking/presentation/payment_status_screen.dart';
import '../../features/booking/presentation/schedule_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/services/presentation/service_detail_screen.dart';
import 'routes.dart';

/// Central route table. Add each feature's routes here (or compose them from
/// per-feature route lists) so navigation stays in one place.
final routerProvider = Provider<GoRouter>((ref) => buildRouter());

/// The route table. [initialLocation] lets tests open any screen directly.
GoRouter buildRouter({String initialLocation = Routes.splash}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: Routes.signup,
        builder: (context, state) => SignupScreen(
          args: state.extra as AuthArgs? ?? const AuthArgs(phone: '0000000000'),
        ),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (context, state) => OtpScreen(
          args: state.extra as AuthArgs? ?? const AuthArgs(phone: '0000000000'),
        ),
      ),
      GoRoute(
        path: Routes.success,
        builder: (context, state) =>
            SuccessScreen(args: state.extra as AuthArgs?),
      ),
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const HomeShell(),
      ),
      GoRoute(
        path: Routes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: Routes.payment,
        builder: (context, state) => const PaymentOptionsScreen(),
      ),
      GoRoute(
        path: Routes.paymentStatus,
        builder: (context, state) => const PaymentStatusScreen(),
      ),
      GoRoute(
        path: Routes.paymentFailed,
        builder: (context, state) => const PaymentFailedScreen(),
      ),
      GoRoute(
        path: Routes.booking,
        builder: (context, state) =>
            BookingDetailScreen(bookingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.instant,
        builder: (context, state) => const InstantScreen(),
      ),
      GoRoute(
        path: Routes.schedule,
        builder: (context, state) => const ScheduleScreen(),
      ),
      GoRoute(
        path: Routes.service,
        builder: (context, state) =>
            ServiceDetailScreen(serviceId: state.pathParameters['id']!),
      ),
    ],
  );
}
