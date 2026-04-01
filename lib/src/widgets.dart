import 'package:flutter/widgets.dart';

import 'nested_page_controller.dart';
import 'nested_scroll_controller.dart';
import 'nested_scrollable_controller.dart';

/// The factory class for nested scrollable widgets
abstract class ScrollableNester extends StatelessWidget {
  /// The basic constructor.
  /// No subtype is forced, and no controller is provided.
  /// 
  /// The [controller] will attach a parent [NestedScrollableController] to itself
  /// if one is found further up in the tree, unless [primary] is set to `true`.
  const factory ScrollableNester({
    Key? key,
    required NestedScrollableController controller,
    bool? primary,
    required Widget Function(BuildContext context, NestedScrollableController controller) builder,
  }) = _CustomScrollableNester;
  
  /// Used for a [ScrollView] that uses a [ScrollController].
  /// If no [controller] is provided, one is created and will be used by
  /// the [builder].
  /// 
  /// The [controller] will attach a parent [NestedScrollableController] to itself
  /// if one is found further up in the tree, unless [primary] is set to `true`.
  const factory ScrollableNester.scrollView({
    Key? key,
    NestedScrollController? controller,
    bool? primary,
    bool keepNestedScrollOrigin,
    required Widget Function(BuildContext context, NestedScrollController controller) builder,
  }) = _ScrollViewNester;
  
  /// Used for a [ScrollView] that uses a [PageController].
  /// If no [controller] is provided, one is created and will be used by
  /// the [builder].
  /// 
  /// The [controller] will attach a parent [NestedScrollableController] to itself
  /// if one is found further up in the tree, unless [primary] is set to `true`.
  const factory ScrollableNester.pageView({
    Key? key,
    NestedPageController? controller,
    bool? primary,
    required Widget Function(BuildContext context, NestedPageController controller) builder,
  }) = _PageViewNester;
}

/// The [build] method of a [ScrollableNester] widget.
mixin _ScrollableNester<T extends NestedScrollableController> implements StatelessWidget {
  T? get controller;
  bool? get primary;
  Widget Function(BuildContext context, T controller) get builder;
  
  /// Creates a [NestedScrollableController] when [controller] is `null`.
  T _createController();

  @override
  Widget build(BuildContext context) {
    // Search for a parent controller in the tree
    final parentController = _NestedScrollableControllerScope.maybeOf(context)?.controller;
    // Create a controller if none was provided
    final controller = this.controller ?? _createController();
    
    // Attach the parent controller to this controller
    controller.attachParent(parentController);
    
    return _NestedScrollableControllerScope(
      controller: controller,
      child: builder(context, controller),
    );
  }
}

/// Used by the [ScrollableNester]'s unnamed constructor.
class _CustomScrollableNester
    extends StatelessWidget
    with _ScrollableNester
    implements ScrollableNester {
      
  const _CustomScrollableNester({
    super.key,
    required this.controller,
    this.primary,
    required this.builder,
  });
  
  @override
  final NestedScrollableController controller;
  @override
  final bool? primary;
  @override
  final Widget Function(BuildContext context, NestedScrollableController controller) builder;
  
  @override
  NestedScrollableController _createController() => controller;
}

/// Returned by [ScrollableNester.scrollView].
class _ScrollViewNester
    extends StatelessWidget
    with _ScrollableNester<NestedScrollController>
    implements ScrollableNester {
      
  const _ScrollViewNester({
    super.key,
    this.controller,
    this.primary,
    this.keepNestedScrollOrigin = true,
    required this.builder,
  });
  
  @override
  final NestedScrollController? controller;
  @override
  final bool? primary;
  final bool keepNestedScrollOrigin;
  @override
  final Widget Function(BuildContext context, NestedScrollController controller) builder;
  
  @override
  NestedScrollController _createController() => NestedScrollController(
      primary: primary,
      keepNestedScrollOrigin: keepNestedScrollOrigin,
    );
}

/// Returned by [ScrollableNester.pageView].
class _PageViewNester
    extends StatelessWidget
    with _ScrollableNester<NestedPageController>
    implements ScrollableNester {
  
  const _PageViewNester({
    super.key,
    this.controller,
    this.primary,
    required this.builder,
  });
  
  @override
  final NestedPageController? controller;
  @override
  final bool? primary;
  @override
  final Widget Function(BuildContext context, NestedPageController controller) builder;
  
  @override
  NestedPageController _createController() => NestedPageController(primary: primary);
}

/// The controller provider.
/// A [NestedScrollableController] used in a [ScrollableNester] widget
/// will be wrapped in this widget so other controllers can attach to it
/// when their widget is built.
class _NestedScrollableControllerScope extends InheritedWidget {
  const _NestedScrollableControllerScope({
    required this.controller,
    required super.child,
  });
  
  final NestedScrollableController controller;

  @override
  bool updateShouldNotify(_NestedScrollableControllerScope oldWidget) => false;
  
  static _NestedScrollableControllerScope? maybeOf(BuildContext context)
      => context.dependOnInheritedWidgetOfExactType<_NestedScrollableControllerScope>();
}