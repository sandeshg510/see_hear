import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/common/widgets/custom_button.dart';
import '../../../../core/router/app_router.dart';
import '../../../../utils/assets_paths.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String routeName = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(child: Image.asset(ImagePaths.instance.brandNameLogoPath)),
            CustomButton(
              title: 'Already a user? Sign in',
              onTap: () => context.goNamed(AppRoutes.signIn),
            ),
            const SizedBox(height: 20),
            CustomButton(
              onTap: () {
                context.goNamed(AppRoutes.signUp); // Use context.goNamed
              },
              title: 'New to SeeHear? Create an account',
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
