import 'package:flutter/widgets.dart';

import 'nested_scrollable_controller.dart';
import 'nested_scrollable_position.dart';

/// The [NestedScrollController] behaves like a [ScrollController]
/// with nestable capabilities.
/// See [NestedScrollableController] for details on the nesting behavior.
class NestedScrollController
    extends ScrollController
    with NestedScrollableController<NestedScrollPositionWithSingleContext> {
  NestedScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset = true,
    super.debugLabel,
    super.onAttach,
    super.onDetach,
    this.nestRoot,
  });
  
  @override
  final bool? nestRoot;
  
  @override
  NestedScrollPositionWithSingleContext createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => NestedScrollPositionWithSingleContext(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
}

/// The [NestedScrollPositionWithSingleContext] just mixes in
/// the [NestedScrollablePosition] mixin, so custom controllers
/// using custom scroll positions are easy to implement.
class NestedScrollPositionWithSingleContext
    extends ScrollPositionWithSingleContext
    with NestedScrollablePosition {
  NestedScrollPositionWithSingleContext({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });
}