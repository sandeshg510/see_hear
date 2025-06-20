import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart'; // Add this import for generating unique IDs

import '../../../../features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc/auth_event.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc/auth_state.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../blocs/users_bloc/users_bloc.dart';
import '../blocs/users_bloc/users_state.dart';
import 'call_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    // Instantiate dependencies here or retrieve from a DI solution.
    // In a production app, it's better to provide these higher up (e.g., with get_it or Provider)
    // and retrieve them using context.read<T>() or GetIt.I<T>().
    // final AgoraRemoteDataSource remoteDataSource = AgoraRemoteDataSourceImpl();
    // final CallRepository callRepository =
    //     CallRepositoryImpl(remoteDataSource: remoteDataSource);
    const Uuid uuid = Uuid(); // Instantiate Uuid for channelId generation

    // Get the current user from the AuthBloc
    return BlocSelector<AuthBloc, AuthState, UserEntity?>(
      selector: (state) {
        if (state is Authenticated) {
          return state.user;
        }
        return null;
      },
      builder: (context, currentUser) {
        if (currentUser == null) {
          return const Scaffold(
            body: Center(
              child: Text('User data not available. Please log in.'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Messages',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            actions: const [], // Removed commented out code for brevity
          ),
          body: BlocBuilder<UsersBloc, UsersState>(
            builder: (context, state) {
              return switch (state) {
                UsersInitial() || UsersLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                UsersLoaded(users: final allUsers) => Column(
                  children: [
                    const SizedBox(height: 25),

                    Flexible(
                      child: Builder(
                        builder: (context) {
                          final List<UserEntity> otherUsers = allUsers
                              .where((user) => user.uid != currentUser.uid)
                              .toList();

                          if (otherUsers.isEmpty) {
                            return const Center(
                              child: Text('No other users found.'),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            itemCount: otherUsers.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final UserEntity otherUser = otherUsers[index];
                              return ListTile(
                                // Removed commented out code for brevity
                                title: Text(
                                  otherUser.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onTap: () {
                                  // 1. Generate a unique channel ID for the call
                                  final String channelId = uuid.v4();

                                  // 2. Generate a local UID (integer)
                                  // Use hashCode to convert String UID to int. Ensure it's positive.
                                  final int localUid = currentUser.uid.hashCode
                                      .abs();

                                  // 3. Define if it's a video call.
                                  // For a real app, you might have separate buttons for video/audio.
                                  const bool isVideo =
                                      true; // Example: Defaulting to video call

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CallScreen(otherUser: otherUser),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    // SIGN OUT BUTTON
                    InkWell(
                      onTap: () {
                        context.read<AuthBloc>().add(AuthLoggedOut());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        width: double.infinity,
                        child: const Row(
                          children: [
                            Icon(Icons.logout_rounded, color: Colors.redAccent),
                            SizedBox(width: 12),
                            Text(
                              'Sign out',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                UsersError(message: final msg) => Center(
                  child: Text('Error loading users: $msg'),
                ),
              };
            },
          ),
        );
      },
    );
  }
}
