import 'dart:math';

T absMin<T extends num>(T a, T b) {
  if (a.sign == -b.sign) return min(a, b);
  return a.abs() <= b.abs() ? a : b;
}