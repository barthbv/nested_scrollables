import 'package:flutter/widgets.dart';

/// The [ScrollActivity] used when a nested scrollable
/// defers its scrolling to a parent.
class NestedScrollActivity extends ScrollActivity {
  NestedScrollActivity(super.delegate);

  @override
  bool get isScrolling => true;

  @override
  bool get shouldIgnorePointer => false;

  @override
  double get velocity => 0.0;
}