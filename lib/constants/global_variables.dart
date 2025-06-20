import 'package:flutter/material.dart';

class GlobalVariables {
  // Colors
  static const orangeColor = Color(0xFFFF9100);
  static const turquoiseColor = Color(0xFF00E5FF);
  static const magentaColor = Color(0xFFFF4081);
  static const purpleColor = Color(0xFF7C4DFF);

  // Gradient
  static const LinearGradient seeHearGradient = LinearGradient(
    colors: [
      Color(0xFF00E5FF),
      Color(0xFFFF9100),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
