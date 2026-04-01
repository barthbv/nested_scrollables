import 'package:flutter/widgets.dart';

abstract class NestedScrollActivity
    extends ScrollActivity {
  NestedScrollActivity(super.delegate);
}

/// The [ScrollActivity] used when a nested scrollable
/// defers its scrolling to a parent.
class DeferredScrollActivity
    extends NestedScrollActivity {
  DeferredScrollActivity(super.delegate);

  @override
  bool get isScrolling => true;

  @override
  bool get shouldIgnorePointer => false;

  @override
  double get velocity => 0.0;
}

/// The [ScrollActivity] used when a parent position
/// is notified that a child has active scroll event but
/// can't or won't react to it.
class IdleNestedScrollActivity
    extends NestedScrollActivity {
  IdleNestedScrollActivity(super.delegate);

  @override
  bool get isScrolling => false;

  @override
  bool get shouldIgnorePointer => false;

  @override
  double get velocity => 0.0;
}