import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../constants/global_variables.dart';
import '../../../../core/common/widgets/custom_text_field.dart';
import '../../../../utils/assets_paths.dart';
import '../blocs/auth_bloc/auth_bloc.dart'; // Import AuthBloc
import '../blocs/auth_bloc/auth_event.dart';
import '../blocs/sign_up_bloc/sign_up_bloc.dart';
import '../blocs/sign_up_bloc/sign_up_event.dart';
import '../blocs/sign_up_bloc/sign_up_state.dart'; // Import AuthEvent

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const String routeName = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state is SignUpLoading) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Creating Account...')),
            );
          } else if (state is SignUpSuccess) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Account Created! Welcome, ${state.user.name}!')),
            );
            // Instead of direct navigation, inform AuthBloc that user is logged in
            BlocProvider.of<AuthBloc>(context).add(AuthLoggedIn(state.user));
            // REMOVE: Triggering SignInBloc and direct navigation here.
            // context.read<SignInBloc>().add(SignInButtonPressed(...));
            // Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          } else if (state is SignUpFailure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign Up Failed: ${state.error}')),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
                const Text('Enter name',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                CustomTextField(
                    controller: nameController, hintText: 'John Doe'),
                const SizedBox(height: 22),
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
                    try {
                      context.read<SignUpBloc>().add(
                            SignUpButtonPressed(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            ),
                          );
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor:
                          GlobalVariables.orangeColor.withOpacity(0.5),
                      elevation: 0),
                  child: const Text('Create an account',
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
