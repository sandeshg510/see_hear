import 'package:flutter/material.dart';

import '../../../constants/global_variables.dart';

class CustomButton extends StatelessWidget {
  Color color;
  final String title;
  void Function()? onTap;
  CustomButton({
    super.key,
    this.color = Colors.yellow,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          gradient: GlobalVariables.seeHearGradient,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Container(
          alignment: Alignment.center,
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: GlobalVariables.purpleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
