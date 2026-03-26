import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'nested_scroll_activity.dart';
import 'utils.dart';

/// The basic interface class for all [NestedScrollablePosition] objects.
// Not necessary but added for consistency with the SDK classes structure.
abstract interface class NestedScrollActivityDelegate
    implements ScrollActivityDelegate {
  // ignore: unused_element
  NestedScrollablePosition? Function(Axis axis)? get _requireParent;
  
  /// Called whenever a [NestedScrollActivityDelegate] receives a drag event
  /// via [applyUserOffset].
  /// Handles the scrolling normally and propagates the scrolling to a parent
  /// if needed.
  /// 
  /// This delegate will "consume" as much of [delta] as it can and propagates
  /// the excess to a parent or back to a child.
  /// Any unconsumed delta is processed as regular overscroll by the origin of
  /// the call chain.
  double applyNestedOffset(double delta);
  
  /// Called whenever a [NestedScrollActivityDelegate] receives a drag event
  /// via [applyUserOffset].
  /// Since a drag event called on a child stops any scrolling of the whole
  /// stack of scrollables, a parent delegate which extent contains snap
  /// points (ie, pages) and currently rests at an "unstable" position (in
  /// between two snap points) takes priority over the child for scrolling,
  /// to return to a "stable" state.
  /// 
  /// This delegate will "consume" as much of [delta] as it needs and
  /// returns the excess, if any, that will be processed by the child (or
  /// itself) with [applyNestedOffset].
  double stabilize(double delta);
}

/// The base of every nested [ScrollPositionWithSingleContext].
mixin NestedScrollablePosition on ScrollPositionWithSingleContext
    implements NestedScrollActivityDelegate {
  
  /// The nearest lower snap point.
  /// Returns [minScrollExtent] if this [NestedScrollablePosition] does not
  /// contain any.
  double get minRelativeScrollExtent => minScrollExtent;
  
  /// The nearest upper snap point.
  /// Returns [maxScrollExtent] if this [NestedScrollablePosition] does not
  /// contain any.
  double get maxRelativeScrollExtent => maxScrollExtent;
  
  /// Whether this position is at a snap point or an edge.
  bool get _atRelativeEdge => pixels == minRelativeScrollExtent || pixels == maxRelativeScrollExtent;
  
  /// Whether this position snaps at various points along its extent.
  /// If set to `true` and if [_atRelativeEdge] is false, this position
  /// will try to absorb any scroll event from its children to return to a
  /// stable position before they can scroll normally.
  bool get scrollExtentContainsSnapPoint => false;
  
  /// The remaining extent before this position is [atEdge].
  double get _distanceToEdge {
    switch (userScrollDirection) {
      case ScrollDirection.idle:
        return 0.0;
      case ScrollDirection.forward:
        return pixels - minScrollExtent;
      case ScrollDirection.reverse:
        return pixels - maxScrollExtent;
    }
  }
  
  /// The remaining extent before this position is [_atRelativeEdge].
  double get _distanceToRelativeEdge {
    switch (userScrollDirection) {
      case ScrollDirection.idle:
        return 0.0;
      case ScrollDirection.forward:
        return pixels - minRelativeScrollExtent;
      case ScrollDirection.reverse:
        return pixels - maxRelativeScrollExtent;
    }
  }
  
  /// Sets the search function that aims to find a suitable parent to
  /// defer scrolling to.
  void setParentGetter(NestedScrollablePosition? Function(Axis axis) require) {
    _requireParent = require;
  }
  
  
  /// Called when this position tries to scroll, to find a suitable parent
  /// position to defer to when overscrolling, or to stabilize when scrolling.
  /// The callback is set by the controller of this position when it is attached.
  @override
  NestedScrollablePosition? Function(Axis axis)? _requireParent;
  
  /// See [NestedScrollActivityDelegate.applyNestedOffset]
  /// 
  /// When [nested] is `true`, the position begins a [NestedScrollActivity] if
  /// it is scrolled.
  @override
  double applyNestedOffset(double delta, {
    bool nested = false,
  }) {
    if (delta == 0.0) return 0.0;
    
    updateUserScrollDirection(delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);
    
    // The offset consumed by this position, clamped to the nearest edge
    final consumedDelta = absMin(delta, _distanceToEdge);
    
    final parent = _requireParent?.call(axis);
    
    // Attempt to scroll a parent with the excess delta
    // The parent returns unconsumed delta
    final residualDelta = parent?.applyNestedOffset(delta - consumedDelta, nested: true)
        ?? delta - consumedDelta;
    
    if (!nested) {
      // If this position is the origin of the scroll, it consumes the total residual delta
      // and may overscroll as a result, so we include the physics calculation
      setPixels(pixels - physics.applyPhysicsToUserOffset(this, consumedDelta + residualDelta));
      
      // The totality of the delta has been consumed by this position and its parents
      return 0.0;
    } else {
      if (activity is! NestedScrollActivity) beginActivity(NestedScrollActivity(this));
      // If this position is not the origin of the scroll, it consumes only what's needed
      // and returns the residual delta up to the defering position
      setPixels(pixels - consumedDelta);
      return residualDelta;
    }
  }
  
  /// See [NestedScrollActivityDelegate.stabilize]
  /// 
  /// When [nested] is `true`, the position begins a [NestedScrollActivity] if
  /// it is scrolled.
  @override
  double stabilize(double delta, {
    bool nested = false,
  }) {
    if (delta == 0.0) return 0.0;
    
    final parent = _requireParent?.call(axis);
    
    // The stabilization attempt goes from furthest parent to nearest
    // The parent returns unconsumed delta
    delta = parent?.stabilize(delta, nested: true) ?? delta;
    
    // This position does not need to stabilize, the delta is returned
    // unmodified
    if (!scrollExtentContainsSnapPoint || _atRelativeEdge) return delta;
    
    if (nested && activity is! NestedScrollActivity) beginActivity(NestedScrollActivity(this));
    
    updateUserScrollDirection(delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);
    
    // The offset consumed by this position, clamped to the nearest
    // relative edge (snap point)
    final consumedDelta = absMin(delta, _distanceToRelativeEdge);
    
    // Sets the new pixels and returns the residual delta
    setPixels(pixels - consumedDelta);
    return delta - consumedDelta;
  }
  
  @override
  void applyUserOffset(double delta) {
    // First attempts to stabilize parents
    delta = stabilize(delta);
    // Processes the user offset
    applyNestedOffset(delta);
  }
  
  @override
  void goBallistic(double velocity) {
    final parent = _requireParent?.call(axis);
    if (parent != null &&
        parent.activity is NestedScrollActivity &&
        atEdge) {
      // Defer to a parent if it is better suited
      // to receive the fling
      parent.goBallistic(velocity);
    } else {
      return super.goBallistic(velocity);
    }
    
    return super.goBallistic(0);
  }
}