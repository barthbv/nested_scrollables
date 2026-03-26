import 'package:flutter/widgets.dart';

import 'nested_scrollable_position.dart';

/// Provides a [ScrollController] with scroll nesting capabilities.
mixin NestedScrollableController<T extends NestedScrollablePosition>
    on ScrollController {
  
  /// Used to explicitly set this controller as the primary controller of a
  /// nesting tree.
  /// If set to `true`, overscrolling the attached [position] will never scroll a
  /// parent [NestedScrollableController] upon overscrolling its attached
  /// [NestedScrollablePosition].
  /// 
  /// Any non-root controller, unless linked manually with another, will look for
  /// a parent in the tree to possibly defer any overscrolling to.
  /// 
  /// Any root controller, be it explicitly set or because no parent exists ahead
  /// in the tree, will behave like a regular [ScrollController].
  bool? get nestRoot;
  
  /// The attached parent that this controller will defer its overscrolling offset
  /// to, if any.
  NestedScrollableController? _parent;
  
  bool get _hasParent => _parent != null;
  
  /// Whether this controller should act as a root or not.
  /// Unless set explicitly by [nestRoot], a [NestedScrollableController] will
  /// always look to defer overscrolling to a parent.
  bool get _effectiveRoot => _hasParent
      ? _explicitRoot
      : true;
  
  /// Whether this controller is explicitly set as a root.
  bool get _explicitRoot => nestRoot ?? false;
  
  /// The scroll [Axis] of the attached [position].
  /// 
  /// When looking for a [_parent] to defer scrolling to, the [_axis] of the two
  /// controllers must match, otherwise the parent controller is ignored and the
  /// search moves to the next nearest parent.
  /// If no parent controller shares the same [_axis], this controller will act
  /// as a root.
  Axis? get _axis => hasClients ? position.axis : null;
  
  @override
  T get position => super.position as T;
  
  /// Attach a [parent] to this controller.
  /// The 
  void attachParent(NestedScrollableController? parent) {
    if (_explicitRoot) return;
    _parent = parent;
    
    if (hasClients) {
      position
          ..goIdle()
          ..setParentGetter(_requireParent);
    }
  }
  
  @override
  T createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  );
  
  /// Searches for the nearest valid [_parent] to defer a scrolling action to.
  /// The parent must have a [position] attached and both must share the same
  /// scroll [_axis].
  /// If the search returns a candidate, the scrolling action is defered to
  /// that candidate, otherwise the [position] behaves as normal.
  NestedScrollablePosition? _requireParent(Axis axis) {
    if ((_effectiveRoot && axis == _axis) || !hasClients) return null;
    
    if (!_parent!.hasClients || _parent!._axis != axis) {
      return _parent!._requireParent(axis);
    } else {
      return _parent!.position;
    }
  }
  
  @override
  void attach(ScrollPosition position) {
    assert(position is T);
    super.attach(position);
    
    this.position.setParentGetter(_requireParent);
  }
}