import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_args.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/success_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import 'routes.dart';

/// Central route table. Add each feature's routes here (or compose them from
/// per-feature route lists) so navigation stays in one place.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
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
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
