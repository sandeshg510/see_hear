import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/global_variables.dart';
import '../../../../core/common/widgets/custom_text_field.dart';
import '../../../../utils/assets_paths.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_event.dart';
import '../blocs/sign_in_bloc/sign_in_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const String routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<SignInBloc, SignInState>(
        listener: (context, state) {
          if (state is SignInLoading) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signing In...')),
            );
          } else if (state is SignInSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Welcome, ${state.user.name}!')),
            );
            // Inform AuthBloc that user is logged in
            BlocProvider.of<AuthBloc>(context).add(AuthLoggedIn(state.user));
            // **No explicit navigation needed here! GoRouter's redirect will handle it.**
            // The AuthBloc state change will trigger the GoRouter's refreshListenable
            // and its redirect logic will automatically send the user to AppRoutes.home.
          } else if (state is SignInFailure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign In Failed: ${state.error}')),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    alignment: Alignment.bottomCenter,
                    ImagePaths.instance.brandNameLogoPath,
                    height: 250,
                  ),
                ),
                const Text('Enter email address',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                CustomTextField(
                    controller: emailController, hintText: 'abc@mail.com'),
                const SizedBox(height: 22),
                const Text('Enter password',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                CustomTextField(
                    controller: passwordController, hintText: '34sgg#at5DFwj'),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    context.read<SignInBloc>().add(
                          SignInButtonPressed(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor:
                          GlobalVariables.orangeColor.withOpacity(0.5),
                      elevation: 0),
                  child: const Text('Sign in',
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w600,
                        color: GlobalVariables.purpleColor,
                      )),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
