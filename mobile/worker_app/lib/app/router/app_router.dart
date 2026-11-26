import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/auth/data/session.dart';
import '../../features/auth/domain/auth_args.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/benefits/presentation/insurance_screen.dart';
import '../../features/earnings/presentation/bank_screen.dart';
import '../../features/earnings/presentation/early_payout_screen.dart';
import '../../features/earnings/presentation/payouts_screen.dart';
import '../../features/earnings/presentation/rate_card_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/jobs/presentation/job_screen.dart';
import '../../features/onboarding/presentation/documents_screen.dart';
import '../../features/onboarding/presentation/language_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/profile/presentation/performance_screen.dart';
import '../../features/rewards/presentation/coins_screen.dart';
import '../../features/rewards/presentation/level_screen.dart';
import '../../features/rewards/presentation/store_screen.dart';
import '../../features/shifts/presentation/attendance_screen.dart';
import '../../features/shifts/presentation/emergency_screen.dart';
import '../../features/shifts/presentation/leave_screen.dart';
import '../../features/shifts/presentation/overtime_screen.dart';
import '../../features/support/presentation/help_screen.dart';
import '../../features/support/presentation/training_screen.dart';
import 'routes.dart';

/// The app's router. Signed-out visitors only reach the sign-in screens.
final routerProvider = Provider<GoRouter>((ref) {
  return buildRouter(isSignedIn: () => ref.read(sessionProvider).signedIn);
});

/// The route table. [initialLocation] lets tests open any screen directly.
GoRouter buildRouter({
  String initialLocation = Routes.splash,
  bool Function()? isSignedIn,
}) {
  const public = {Routes.splash, Routes.login, Routes.otp};

  GoRoute page(String path, Widget Function(GoRouterState state) child) =>
      GoRoute(path: path, builder: (context, state) => child(state));

  return GoRouter(
    initialLocation: initialLocation,
    redirect: (context, state) {
      if (isSignedIn == null || public.contains(state.matchedLocation)) {
        return null;
      }
      return isSignedIn() ? null : Routes.login;
    },
    routes: [
      page(Routes.splash, (_) => const SplashScreen()),
      page(Routes.login, (_) => const LoginScreen()),
      GoRoute(
        path: Routes.otp,
        redirect: (context, state) =>
            state.extra is AuthArgs ? null : Routes.login,
        builder: (context, state) => OtpScreen(args: state.extra! as AuthArgs),
      ),
      // The sign-up flow passes `true` to show its step header and buttons.
      page(
        Routes.language,
        (s) => LanguageScreen(onboarding: s.extra as bool? ?? false),
      ),
      page(Routes.profileSetup, (_) => const ProfileSetupScreen()),
      page(
        Routes.documents,
        (s) => DocumentsScreen(onboarding: s.extra as bool? ?? false),
      ),
      page(Routes.home, (_) => const HomeShell()),
      page(Routes.job, (_) => const JobScreen()),
      page(Routes.payouts, (_) => const PayoutsScreen()),
      page(Routes.earlyPayout, (_) => const EarlyPayoutScreen()),
      page(Routes.rateCard, (_) => const RateCardScreen()),
      page(Routes.bank, (_) => const BankScreen()),
      page(Routes.level, (_) => const LevelScreen()),
      page(Routes.performance, (_) => const PerformanceScreen()),
      page(Routes.attendance, (_) => const AttendanceScreen()),
      page(Routes.leave, (_) => const LeaveScreen()),
      page(Routes.emergencyLogout, (_) => const EmergencyLogoutScreen()),
      page(Routes.overtime, (_) => const OvertimeScreen()),
      page(
        Routes.insurance,
        (s) => InsuranceScreen(kind: s.pathParameters['kind']!),
      ),
      page(Routes.coins, (_) => const CoinsScreen()),
      page(Routes.store, (_) => const StoreScreen()),
      page(Routes.training, (_) => const TrainingScreen()),
      page(Routes.help, (_) => const HelpScreen()),
    ],
  );
}
