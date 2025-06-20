// lib/core/router/app_router.dart
import 'dart:async'; // Required for StreamSubscription

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import '../../features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import '../../features/auth/presentation/views/sign_in_screen.dart';
import '../../features/auth/presentation/views/sign_up_screen.dart';
import '../../features/auth/presentation/views/welcome_screen.dart';
import '../../features/calling/presentation/views/home_screen.dart';

// These are your named routes (paths)
abstract class AppRoutes {
  static const welcome = '/welcome';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const home = '/home';
}

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRoutes.welcome, // <--- ADD THIS LINE
        builder: (BuildContext context, GoRouterState state) {
          return const WelcomeScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: AppRoutes.signIn, // <--- ADD THIS LINE
        builder: (BuildContext context, GoRouterState state) {
          return const SignInScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: AppRoutes.signUp, // <--- ADD THIS LINE
        builder: (BuildContext context, GoRouterState state) {
          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home, // <--- ADD THIS LINE
        builder: (BuildContext context, GoRouterState state) {
          return HomeScreen();
        },
      ),
      // Add other routes here, e.g., for user profile, settings, etc.
    ],
    // Initial location: this is where GoRouter starts
    initialLocation: AppRoutes.welcome,

    // Redirect logic based on AuthBloc state
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final bool isLoggedIn = authState is Authenticated;
      final bool isLoggingIn = state.matchedLocation == AppRoutes.signIn ||
          state.matchedLocation == AppRoutes.signUp;
      final bool isWelcome = state.matchedLocation == AppRoutes.welcome;

      // If not logged in and trying to access a protected route (e.g., home)
      // or not on an auth-related screen, redirect to welcome.
      if (!isLoggedIn && !(isLoggingIn || isWelcome)) {
        return AppRoutes.welcome;
      }
      // If logged in and trying to access an auth-related screen, redirect to home.
      else if (isLoggedIn && (isLoggingIn || isWelcome)) {
        return AppRoutes.home;
      }
      // No redirect needed.
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    debugLogDiagnostics: true,
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Notify immediately for initial state
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
