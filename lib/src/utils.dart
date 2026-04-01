import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Returns the regular value of which the absolute is the
/// smallest of the two.
T absMin<T extends num>(T a, T b) {
  if (a.sign == -b.sign) return math.min(a, b);
  return a.abs() <= b.abs() ? a : b;
}

/// Returns `0.0` if the [value] is smaller or equal to
/// the [precisionErrorTolerance].
double roundPrecisionError(double value) {
  if (value.abs() <= precisionErrorTolerance) return 0.0;
  return value;
}