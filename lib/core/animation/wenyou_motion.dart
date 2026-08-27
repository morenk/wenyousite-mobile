import 'package:flutter/material.dart';

/// Foundation motion curves shared by route and in-page state transitions.
const wenyouStandardMotionCurve = Cubic(0.2, 0.8, 0.2, 1);
const wenyouExitMotionCurve = Cubic(0.4, 0, 1, 1);

bool wenyouAnimationsDisabled(BuildContext context) {
  return (MediaQuery.maybeOf(context)?.disableAnimations ?? false) ||
      WidgetsBinding
          .instance
          .platformDispatcher
          .accessibilityFeatures
          .disableAnimations;
}
