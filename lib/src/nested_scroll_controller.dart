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
    bool? primary,
    this.keepNestedScrollOrigin = true,
  })  : nestRoot = primary;
  
  @override
  final bool? nestRoot;
  
  /// Used to set the [NestedScrollPositionWithSingleContext.keepNestedScrollOrigin]
  /// value.
  final bool keepNestedScrollOrigin;
  
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
      keepNestedScrollOrigin: keepNestedScrollOrigin,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
}

/// The [NestedScrollPositionWithSingleContext] just mixes in
/// the [NestedScrollablePosition] and [ScrollNestingOriginTracker]
/// mixins, so custom controllers using custom scroll positions are
/// easy to implement.
class NestedScrollPositionWithSingleContext
    extends ScrollPositionWithSingleContext
    with NestedScrollablePosition, ScrollNestingOriginTracker {
  NestedScrollPositionWithSingleContext({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    this.keepNestedScrollOrigin = true,
    super.oldPosition,
    super.debugLabel,
  });
  
  /// Here, the [keepNestedScrollOrigin] is set as a final member
  /// but can be set dynamically if needed.
  /// See the [ScrollNestingOriginTracker] mixin.
  @override
  final bool keepNestedScrollOrigin;
}