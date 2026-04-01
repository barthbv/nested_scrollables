import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'nested_scroll_activity.dart';
import 'utils.dart';

/// The basic interface class for all [NestedScrollablePosition] objects.
// Not necessary but added for consistency with the SDK class structure.
abstract interface class NestedScrollActivityDelegate
    implements ScrollActivityDelegate {
  /// Called whenever a [NestedScrollActivityDelegate] receives a drag event
  /// via [applyUserOffset].
  /// Handles the scrolling normally or propagates the scrolling to a parent
  /// if needed.
  /// 
  /// This delegate will "consume" as much of [delta] as it can and passes
  /// the excess to a parent or back to a child.
  /// Any unconsumed delta is processed as regular overscroll by the origin of
  /// the call chain.
  double applyNestedOffset(double delta);
  
  /// Called whenever a [NestedScrollActivityDelegate] receives a drag event
  /// via [applyUserOffset].
  /// Since a drag event called on a child stops any scrolling of the whole
  /// stack of scrollables, a parent delegate which extent contains snap
  /// points (ie, pages) and currently rests at an "unstable" position (not
  /// at a snap point) takes priority over the child for scrolling, to return
  /// to a "stable" state.
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
  
  /// Whether this position snaps at various points along its extent.
  /// If it returs `true`, this position will try to absorb any scroll event
  /// from its children to return to a stable position if needed, before
  /// they can scroll normally.
  bool get scrollExtentContainsSnapPoint => false;
  
  /// Whether this position is currently overscrolling.
  bool _didOverscroll = false;
  
  /// The remaining extent before this position reaches an edge.
  /// The direction of the search depends on the sign of the [offset] or
  /// [velocity].
  /// 
  /// Similar to [updateUserScrollDirection], a positive value implies
  /// a forward scroll direction, so a [velocity] needs to be inverted to
  /// return a correct value.
  double _distanceToEdge({
    double? offset,
    double? velocity,
  }) {
    assert(offset != null || velocity != null);
    final direction = offset ?? -velocity!;
    
    if (direction == 0.0 || !hasContentDimensions) return 0.0;
    
    final edge = direction > 0.0
        ? math.min(pixels, minScrollExtent)
        : math.max(pixels, maxScrollExtent);
    
    return roundPrecisionError(pixels - edge);
  }
  
  /// The remaining extent before this position reaches a snap point or an
  /// edge.
  /// The direction of the search depends on the sign of the [offset] or
  /// [velocity].
  /// 
  /// Similar to [updateUserScrollDirection], a positive value implies a
  /// forward scroll direction, so a [velocity] needs to be inverted to
  /// return a correct value.
  double _distanceToRelativeEdge({
    double? offset,
    double? velocity,
  }) {
    assert(offset != null || velocity != null);
    final direction = offset ?? -velocity!;
    
    if (direction == 0.0 || !hasContentDimensions) return 0.0;
    
    final edge = direction > 0.0
        ? math.min(pixels, minRelativeScrollExtent)
        : math.max(pixels, maxRelativeScrollExtent);
    
    return roundPrecisionError(pixels - edge);
  }
  
  ScrollDirection _getScrollDirectionFromDelta(double delta) {
    if (delta > 0.0) return ScrollDirection.forward;
    
    return delta < 0.0
        ? ScrollDirection.reverse
        : ScrollDirection.idle;
  }
  
  /// Sets the search function that aims to find a suitable parent to maybe
  /// defer scrolling to.
  void setParentGetter(NestedScrollablePosition? Function(Axis axis) require) {
    _requireParent = require;
  }
  
  NestedScrollablePosition? _getParent() => _requireParent?.call(axis);
  
  /// Called when this position tries to scroll, to find a suitable parent
  /// position to defer to when overscrolling, or to stabilize when scrolling.
  /// The callback is set by the controller of this position when it is attached.
  NestedScrollablePosition? Function(Axis axis)? _requireParent;
  
  /// Update the [activity] of this position upon receiving nested scroll
  /// events.
  void _updateScrollActivity({
    required bool didScroll,
  }) {
    NestedScrollActivity? newActivity;
    
    if (activity is! DeferredScrollActivity &&
        didScroll) {
      newActivity = DeferredScrollActivity(this);
    } else if (activity is! IdleNestedScrollActivity &&
        !didScroll) {
      newActivity = IdleNestedScrollActivity(this);
    }
    
    if (newActivity != null) beginActivity(newActivity);
  }
  
  /// See [NestedScrollActivityDelegate.applyNestedOffset]
  /// 
  /// When [nested] is `true`, the position begins a [NestedScrollActivity] if
  /// it is scrolled.
  @override
  double applyNestedOffset(double delta, {
    bool nested = false,
  }) {
    if (delta == 0.0) return 0.0;
    
    // The position consumes offset until it reaches an edge
    double consumedDelta = absMin(delta, _distanceToEdge(offset: delta));
    
    final parent = _getParent();
    
    // Attempt to scroll a parent with the excess offset
    // The parent returns the unconsumed offset
    double residualDelta = parent?.applyNestedOffset(delta - consumedDelta, nested: true)
        ?? delta - consumedDelta;
    
    updateUserScrollDirection(_getScrollDirectionFromDelta(delta));
    
    if (nested) {
      _updateScrollActivity(didScroll: consumedDelta != 0.0);
      
      // Set the new pixels only if the activity is scrolling
      if (consumedDelta != 0.0) {
        setPixels(pixels - consumedDelta);
      }
      
      // Whatever is left of the scroll offset is returned to the direct child
      // of this position.
      return residualDelta;
    }
    
    // If any residual scroll offset is returned by the parents, the source of the
    // scroll event may overscroll as it has no child to report the excess offset to
    consumedDelta += residualDelta;
    
    // Set the new pixels only if the activity is scrolling
    if (consumedDelta != 0.0) {
      setPixels(pixels - physics.applyPhysicsToUserOffset(this, consumedDelta));
    }
    
    // The totality of the offset has been consumed by this position and its parents
    return 0.0;
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
    
    final parent = _getParent();
    
    // The stabilization attempt goes from furthest parent to nearest
    // The parent returns unconsumed scroll offset
    delta = parent?.stabilize(delta, nested: true) ?? delta;
    
    // The offset consumed by this position, equals 0.0 if this position
    // doesn't contain snap points
    double consumedDelta = 0.0;
    
    final distanceToRelativeEdge = _distanceToRelativeEdge(offset: delta);
    
    if (!scrollExtentContainsSnapPoint || distanceToRelativeEdge == 0.0) {
      // This position doesn't need to stabilize
      return delta;
    }
        
    // If it does, it consumes the maximum offset possible until reaching a
    // snap point.
    consumedDelta = absMin(delta, distanceToRelativeEdge);
    
    // The position that receives the original scroll event keeps its regular
    // ScrollActivity, but if it triggers a parent to scroll, the parent
    // begins a NestedScrollActivity
    if (nested) _updateScrollActivity(didScroll: consumedDelta != 0.0);
    
    updateUserScrollDirection(_getScrollDirectionFromDelta(consumedDelta));
    
    if (consumedDelta != 0.0) {
      setPixels(pixels - consumedDelta);
    }
    
    // Returns the residual offset
    return delta - consumedDelta;
  }
  
  /// Keep track of overscrolling so we can reset the effect
  /// even when the overscrolled position defers all the scrolling
  /// to a parent position.
  @override
  void didOverscrollBy(double value) {
    // Mark this position as currently being overscrolled
    _didOverscroll = true;
    return super.didOverscrollBy(value);
  }
  
  /// If the position did overscroll, reset the overscroll effect
  /// before possibly affecting parent positions
  void _maybeCancelOverscrollingEffect(double delta) {
    if (_didOverscroll && _distanceToEdge(offset: delta) != 0.0) {
      // Resets the visual effect of the overscroll
      // (For example, the ClampingScrollPhysics stretches the content
      // of the scrollable)
      didUpdateScrollPositionBy(0.0);
    }
    _didOverscroll = false;
  }
  
  void _resetOverscrollStatus() => _didOverscroll = false;
  
  /// The main entry to nested scrolling behavior.
  @override
  void applyUserOffset(double delta) {
    _maybeCancelOverscrollingEffect(delta);
    
    // First attempts to stabilize parents
    delta = stabilize(delta);
    
    // Processes the user offset
    applyNestedOffset(delta);
  }
  
  /// Propagates the [goBallistic] call to all parents. If a parent is a
  /// better candidate to receiving the ballistic event (the parent is
  /// currently receiving deferred scrolling from this position), the
  /// parent steals the event and this position goes ballistic with a `0.0`
  /// velocity.
  double _propagateBallisticAttempt(double velocity) {
    velocity = _getParent()?._propagateBallisticAttempt(velocity) ?? velocity;
    
    if (!hasContentDimensions) return velocity;
    
    double returnedVelocity = 0.0;
    
    if (activity is! DeferredScrollActivity ||
        _distanceToRelativeEdge(velocity: velocity) == 0.0) {
      returnedVelocity = velocity;
      velocity = 0.0;
    }
    
    if (activity is! IdleScrollActivity &&
        activity is! BallisticScrollActivity) {
      super.goBallistic(velocity);
    }
    
    return returnedVelocity;
  }
  
  @override
  void goBallistic(double velocity) {
    if (activity is BallisticScrollActivity) return;
    _resetOverscrollStatus();
    
    velocity = _getParent()?._propagateBallisticAttempt(velocity) ?? velocity;
    return super.goBallistic(velocity);
  }
  
  /// Propagates an [IdleScrollActivity] to every parent that isn't
  /// currently going ballistic.
  void _propagateIdleActivity() {
    _getParent()?._propagateIdleActivity();
    
    if (hasPixels &&
        hasContentDimensions &&
        activity is! BallisticScrollActivity) {
      return super.goBallistic(0.0);
    }
  }
  
  /// Propagates the [goIdle] call to the parent of this position.
  @override
  void goIdle() {
    if (activity is IdleScrollActivity) return;
    
    _resetOverscrollStatus();
    _getParent()?._propagateIdleActivity();
    super.goIdle();
  }
}

/// Provides a [NestedScrollablePosition] with the ability to track the
/// origin of a nested scroll event, and possibly consuming a scrolling
/// offset via [stabilize] when a defering child scrolls towards that
/// origin point.
mixin ScrollNestingOriginTracker
    on NestedScrollablePosition {
  
  /// Whether this [NestedScrollablePosition] should record the origin
  /// of a nested scroll event.
  /// Classes mixing in [ScrollNestingOriginTracker] can set this value
  /// dynamically if needed.
  bool get keepNestedScrollOrigin;
  
  /// The origin point when the position receives a nested scroll
  /// event.
  double? _temporarySnapPoint;
  
  /// The [minRelativeScrollExtent] will return the nested scroll
  /// origin point [_temporarySnapPoint] if any and if it is smaller than
  /// the current [pixels] value, or the [minScrollExtent] otherwise.
  @override
  double get minRelativeScrollExtent =>
      _temporarySnapPoint == null ||
      pixels < _temporarySnapPoint!
          ? minScrollExtent
          : _temporarySnapPoint!;
  
  /// The [maxRelativeScrollExtent] will return the nested scroll
  /// origin point [_temporarySnapPoint] if any and if it is greater than
  /// the current [pixels] value, or the [maxScrollExtent] otherwise.
  @override
  double get maxRelativeScrollExtent =>
      _temporarySnapPoint == null ||
      pixels > _temporarySnapPoint!
          ? maxScrollExtent
          : _temporarySnapPoint!;
  
  /// Returns `true` when a nested scroll event has recorded an origin
  /// point.
  @override
  bool get scrollExtentContainsSnapPoint => _temporarySnapPoint != null;
  
  /// Records the current [pixels] as the origin point of a nested scroll
  /// event when [keepNestedScrollOrigin] is set to `true`.
  /// 
  /// The origin is tracked by [minRelativeScrollExtent] or
  /// [maxRelativeScrollExtent] depending on the current [pixels] value.
  void recordTemporarySnapPoint() {
    _temporarySnapPoint = pixels;
  }
  
  /// Clears the nested scroll origin point, called when a nested scroll
  /// event ends.
  void resetTemporarySnapPoints() {
    _temporarySnapPoint = null;
  }
  
  /// Records a nested scroll origin point upon beginning a new
  /// [DeferredScrollActivity], which is applied when a position is scrolled
  /// by one of its children.
  /// Any non-nested activity resets the [_temporarySnapPoint].
  @override
  void beginActivity(ScrollActivity? newActivity) {
    if (keepNestedScrollOrigin &&
        newActivity is DeferredScrollActivity) {
      if (!scrollExtentContainsSnapPoint) recordTemporarySnapPoint();
    } else if (newActivity is! NestedScrollActivity) {
      resetTemporarySnapPoints();
    }
    
    super.beginActivity(newActivity);
  }
}