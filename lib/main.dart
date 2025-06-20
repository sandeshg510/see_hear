// main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Make sure this is imported
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// New: Import your AppRouter
import 'core/router/app_router.dart';
// Your existing imports for BLoCs, UseCases, Repositories, etc.
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/check_login_status_usecase.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import 'features/auth/presentation/blocs/sign_in_bloc/sign_in_bloc.dart';
import 'features/auth/presentation/blocs/sign_up_bloc/sign_up_bloc.dart';
import 'features/calling/data/datasources/user_remote_data_source.dart';
import 'features/calling/data/repositories/user_repository_impl.dart';
import 'features/calling/domain/usecases/get_all_users_usecase.dart';
import 'features/calling/presentation/blocs/users_bloc/users_bloc.dart';
import 'features/calling/presentation/blocs/users_bloc/users_event.dart';
import 'firebase_options.dart';

void main() async {
  // should print "hello"

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firebaseAuth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  final authRemoteDataSource = AuthRemoteDataSource(firebaseAuth, firestore);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
  );

  final signUpUsecase = SignUpUsecase(repository: authRepository);
  final signInUsecase = SignInUsecase(repository: authRepository);
  final checkLoginStatusUsecase = CheckLoginStatusUsecase(authRepository);
  final signOutUsecase = SignOutUsecase(authRepository);

  final userRemoteDataSource = UserRemoteDataSourceImpl(firestore: firestore);
  final userRepository = UserRepositoryImpl(
    remoteDataSource: userRemoteDataSource,
  );
  final getAllUsersUsecase = GetAllUsersUsecase(userRepository);

  // Initialize AuthBloc here before AppRouter
  final AuthBloc authBloc = AuthBloc(
    checkLoginStatusUsecase: checkLoginStatusUsecase,
    signOutUser: signOutUsecase,
  )..add(AuthStatusRequested()); // Dispatch initial event

  // Initialize Agora dependencies
  // final AgoraRemoteDataSource agoraRemoteDataSource =
  //     AgoraRemoteDataSourceImpl();
  // final CallRepository callRepository =
  //     CallRepositoryImpl(remoteDataSource: agoraRemoteDataSource);

  // Initialize your AppRouter with the AuthBloc
  final AppRouter appRouter = AppRouter(authBloc);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SignUpBloc(signUpUsecase: signUpUsecase)),
        BlocProvider(create: (_) => SignInBloc(signInUsecase: signInUsecase)),
        // Provide the AuthBloc here, so it's accessible to the router and other widgets
        BlocProvider<AuthBloc>.value(
          value: authBloc,
        ), // Use .value to provide existing instance
        BlocProvider(
          create: (context) =>
              UsersBloc(getAllUsers: getAllUsersUsecase)..add(LoadUsers()),
        ),
        // BlocProvider(
        //   create: (context) => CallBloc(callRepository: callRepository),
        // ),
      ],
      child: MyApp(appRouter: appRouter), // Pass the router to MyApp
    ),
  );
}

class MyApp extends StatelessWidget {
  final AppRouter appRouter;
  const MyApp({super.key, required this.appRouter});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Use MaterialApp.router
      theme: ThemeData(fontFamily: 'Amazon'),
      title: 'SeeHear',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter.router, // Pass the GoRouter configuration here
    );
  }
}
