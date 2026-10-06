// Copy of packages/tokens/app_tokens.dart for the T1 shell.
// Single source stays design/tokens.json; proper melos/pub workspace wiring is a Stage B task.
import 'package:flutter/material.dart';

class AppTokens {
  static const primary = Color(0xFF1A73E8);
  static const secondary = Color(0xFF5F6368);
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF1F3F4);
  static const textPrimary = Color(0xFF202124);
  static const textSecondary = Color(0xFF5F6368);
  static const error = Color(0xFFD93025);
  static const warning = Color(0xFFF9AB00);
  static const success = Color(0xFF188038);
  static const recordingAlert = Color(0xFFD93025);

  static const double radiusSm = 8, radiusMd = 12, radiusLg = 16;
  static const double minTouch = 48;

  static const String recordingLabel = 'RECORDING';
}
