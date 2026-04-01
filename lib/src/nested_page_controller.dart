import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'nested_scrollable_controller.dart';
import 'nested_scrollable_position.dart';

// This code is for the most part dupilcated from the Flutter
// libraries, as the PageController creates the private _PagePosition,
// and the page scrolling behavior sits in private members and methods
// in both classes.
// 
// Extending the PageController to use a custom NestedPagePosition would
// break that behavior, but since none of it is directly altered by this
// package, it didn't make sense to reimplement all of it.
// 
// The duplicated classes are kept separate and their content unmodified
// for clarity and to maintain proper ownership of the code contained in
// this page.

/// The [NestedScrollableController] behaves like a [PageController]
/// with nestable capabilities.
/// See [NestedScrollableController] for details on the nesting behavior.
class NestedPageController
    extends _DuplicatedPageController
    with NestedScrollableController<NestedPagePosition> {
  
  NestedPageController({
    super.initialPage,
    super.keepPage,
    super.viewportFraction,
    super.onAttach,
    super.onDetach,
    bool? primary,
  })  : nestRoot = primary;
  
  /// See [NestedScrollableController.nestRoot]
  @override
  final bool? nestRoot;

  @override
  NestedPagePosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => NestedPagePosition(
      physics: physics,
      context: context,
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
      oldPosition: oldPosition,
    );
}

/// The [ScrollPosition] used by a [NestedPageController].
class NestedPagePosition
    extends _DuplicatedPagePosition
    with NestedScrollablePosition {
  NestedPagePosition({
    required super.physics,
    required super.context,
    super.initialPage,
    super.keepPage,
    super.viewportFraction,
    super.oldPosition,
  });
  
  /// See [NestedScrollablePosition.minRelativeScrollExtent]
  @override
  double get minRelativeScrollExtent => getPixelsFromPage(page!.floorToDouble());
  /// See [NestedScrollablePosition.maxRelativeScrollExtent]
  @override
  double get maxRelativeScrollExtent => getPixelsFromPage(page!.ceilToDouble());
  
  /// See [NestedScrollablePosition.scrollExtentContainsSnapPoint]
  @override
  bool get scrollExtentContainsSnapPoint => true;
}


/// The following classes are directly duplicated from the Flutter SDK.
/// Page scrolling behavior is left untouched in the [NestedPageController]
/// and [NestedPagePosition] classes.
/// 
/// See the [PageController] and its associated `_PagePosition` in the
/// official libraries.

// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the Flutter SDK's LICENSE file.

/// A controller for [PageView].
///
/// A page controller lets you manipulate which page is visible in a [PageView].
/// In addition to being able to control the pixel offset of the content inside
/// the [PageView], a [PageController] also lets you control the offset in terms
/// of pages, which are increments of the viewport size.
///
/// See also:
///
///  * [PageView], which is the widget this object controls.
///
/// {@tool snippet}
///
/// This widget introduces a [MaterialApp], [Scaffold] and [PageView] with two pages
/// using the default constructor. Both pages contain an [ElevatedButton] allowing you
/// to animate the [PageView] using a [PageController].
///
/// ```dart
/// class MyPageView extends StatefulWidget {
///   const MyPageView({super.key});
///
///   @override
///   State<MyPageView> createState() => _MyPageViewState();
/// }
///
/// class _MyPageViewState extends State<MyPageView> {
///   final PageController _pageController = PageController();
///
///   @override
///   void dispose() {
///     _pageController.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: Scaffold(
///         body: PageView(
///           controller: _pageController,
///           children: <Widget>[
///             ColoredBox(
///               color: Colors.red,
///               child: Center(
///                 child: ElevatedButton(
///                   onPressed: () {
///                     if (_pageController.hasClients) {
///                       _pageController.animateToPage(
///                         1,
///                         duration: const Duration(milliseconds: 400),
///                         curve: Curves.easeInOut,
///                       );
///                     }
///                   },
///                   child: const Text('Next'),
///                 ),
///               ),
///             ),
///             ColoredBox(
///               color: Colors.blue,
///               child: Center(
///                 child: ElevatedButton(
///                   onPressed: () {
///                     if (_pageController.hasClients) {
///                       _pageController.animateToPage(
///                         0,
///                         duration: const Duration(milliseconds: 400),
///                         curve: Curves.easeInOut,
///                       );
///                     }
///                   },
///                   child: const Text('Previous'),
///                 ),
///               ),
///             ),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```
/// {@end-tool}
class _DuplicatedPageController
    extends ScrollController
    implements PageController {
  /// Creates a page controller.
  _DuplicatedPageController({
    this.initialPage = 0,
    this.keepPage = true,
    this.viewportFraction = 1.0,
    super.onAttach,
    super.onDetach,
  }) : assert(viewportFraction > 0.0);

  /// The page to show when first creating the [PageView].
  @override
  final int initialPage;

  /// Save the current [page] with [PageStorage] and restore it if
  /// this controller's scrollable is recreated.
  ///
  /// If this property is set to false, the current [page] is never saved
  /// and [initialPage] is always used to initialize the scroll offset.
  /// If true (the default), the initial page is used the first time the
  /// controller's scrollable is created, since there's isn't a page to
  /// restore yet. Subsequently the saved page is restored and
  /// [initialPage] is ignored.
  ///
  /// See also:
  ///
  ///  * [PageStorageKey], which should be used when more than one
  ///    scrollable appears in the same route, to distinguish the [PageStorage]
  ///    locations used to save scroll offsets.
  @override
  final bool keepPage;

  /// {@template flutter.widgets.pageview.viewportFraction}
  /// The fraction of the viewport that each page should occupy.
  ///
  /// Defaults to 1.0, which means each page fills the viewport in the scrolling
  /// direction.
  /// {@endtemplate}
  @override
  final double viewportFraction;

  /// The current page displayed in the controlled [PageView].
  ///
  /// There are circumstances that this [_DuplicatedPageController] can't know the current
  /// page. Reading [page] will throw an [AssertionError] in the following cases:
  ///
  /// 1. No [PageView] is currently using this [_DuplicatedPageController]. Once a
  /// [PageView] starts using this [_DuplicatedPageController], the new [page]
  /// position will be derived:
  ///
  ///   * First, based on the attached [PageView]'s [BuildContext] and the
  ///     position saved at that context's [PageStorage] if [keepPage] is true.
  ///   * Second, from the [_DuplicatedPageController]'s [initialPage].
  ///
  /// 2. More than one [PageView] using the same [_DuplicatedPageController].
  ///
  /// The [hasClients] property can be used to check if a [PageView] is attached
  /// prior to accessing [page].
  @override
  double? get page {
    assert(
      positions.isNotEmpty,
      'PageController.page cannot be accessed before a PageView is built with it.',
    );
    assert(
      positions.length == 1,
      'The page property cannot be read when multiple PageViews are attached to '
      'the same PageController.',
    );
    final position = this.position as _DuplicatedPagePosition;
    return position.page;
  }

  bool _debugCheckPageControllerAttached() {
    assert(positions.isNotEmpty, 'PageController is not attached to a PageView.');
    assert(
      positions.length == 1,
      'Multiple PageViews are attached to '
      'the same PageController.',
    );
    return true;
  }

  /// Animates the controlled [PageView] from the current page to the given page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  @override
  Future<void> animateToPage(int page, {required Duration duration, required Curve curve}) {
    assert(_debugCheckPageControllerAttached());
    final position = this.position as _DuplicatedPagePosition;
    if (position._cachedPage != null) {
      position._cachedPage = page.toDouble();
      return Future<void>.value();
    }

    if (!position.hasViewportDimension) {
      position._pageToUseOnStartup = page.toDouble();
      return Future<void>.value();
    }

    return position.animateTo(
      position.getPixelsFromPage(page.toDouble()),
      duration: duration,
      curve: curve,
    );
  }

  /// Changes which page is displayed in the controlled [PageView].
  ///
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  @override
  void jumpToPage(int page) {
    assert(_debugCheckPageControllerAttached());
    final position = this.position as _DuplicatedPagePosition;
    if (position._cachedPage != null) {
      position._cachedPage = page.toDouble();
      return;
    }

    if (!position.hasViewportDimension) {
      position._pageToUseOnStartup = page.toDouble();
      return;
    }

    position.jumpTo(position.getPixelsFromPage(page.toDouble()));
  }

  /// Animates the controlled [PageView] to the next page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  @override
  Future<void> nextPage({required Duration duration, required Curve curve}) {
    return animateToPage(page!.round() + 1, duration: duration, curve: curve);
  }

  /// Animates the controlled [PageView] to the previous page.
  ///
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  @override
  Future<void> previousPage({required Duration duration, required Curve curve}) {
    return animateToPage(page!.round() - 1, duration: duration, curve: curve);
  }

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _DuplicatedPagePosition(
      physics: physics,
      context: context,
      initialPage: initialPage,
      keepPage: keepPage,
      viewportFraction: viewportFraction,
      oldPosition: oldPosition,
    );
  }

  @override
  void attach(ScrollPosition position) {
    super.attach(position);
    final pagePosition = position as _DuplicatedPagePosition;
    pagePosition.viewportFraction = viewportFraction;
  }
}

/// Duplicate of the [_PagePosition] class.
class _DuplicatedPagePosition
    extends ScrollPositionWithSingleContext
    implements PageMetrics {
  _DuplicatedPagePosition({
    required super.physics,
    required super.context,
    this.initialPage = 0,
    bool keepPage = true,
    double viewportFraction = 1.0,
    super.oldPosition,
  }) : assert(viewportFraction > 0.0),
       _viewportFraction = viewportFraction,
       _pageToUseOnStartup = initialPage.toDouble(),
       super(initialPixels: null, keepScrollOffset: keepPage);

  final int initialPage;
  double _pageToUseOnStartup;

  // When the viewport has a zero-size, the `page` can not
  // be retrieved by `getPageFromPixels`, so we need to cache the page
  // for use when resizing the viewport to non-zero next time.
  double? _cachedPage;

  @override
  Future<void> ensureVisible(
    RenderObject object, {
    double alignment = 0.0,
    Duration duration = Duration.zero,
    Curve curve = Curves.ease,
    ScrollPositionAlignmentPolicy alignmentPolicy = ScrollPositionAlignmentPolicy.explicit,
    RenderObject? targetRenderObject,
  }) {
    // Since the _PagePosition is intended to cover the available space within
    // its viewport, stop trying to move the target render object to the center
    // - otherwise, could end up changing which page is visible and moving the
    // targetRenderObject out of the viewport.
    return super.ensureVisible(
      object,
      alignment: alignment,
      duration: duration,
      curve: curve,
      alignmentPolicy: alignmentPolicy,
    );
  }

  @override
  double get viewportFraction => _viewportFraction;
  double _viewportFraction;

  set viewportFraction(double value) {
    if (_viewportFraction == value) {
      return;
    }
    final double? oldPage = page;
    _viewportFraction = value;
    if (oldPage != null) {
      forcePixels(getPixelsFromPage(oldPage));
    }
  }

  // The amount of offset that will be added to [minScrollExtent] and subtracted
  // from [maxScrollExtent], such that every page will properly snap to the center
  // of the viewport when viewportFraction is greater than 1.
  //
  // The value is 0 if viewportFraction is less than or equal to 1, larger than 0
  // otherwise.
  double get _initialPageOffset => math.max(0, viewportDimension * (viewportFraction - 1) / 2);

  double getPageFromPixels(double pixels, double viewportDimension) {
    assert(viewportDimension > 0.0);
    final double actual =
        math.max(0.0, pixels - _initialPageOffset) / (viewportDimension * viewportFraction);
    final double round = actual.roundToDouble();
    if ((actual - round).abs() < precisionErrorTolerance) {
      return round;
    }
    return actual;
  }

  double getPixelsFromPage(double page) {
    return page * viewportDimension * viewportFraction + _initialPageOffset;
  }

  @override
  double? get page {
    if (!hasPixels) {
      return null;
    }
    assert(
      hasContentDimensions || !haveDimensions,
      'Page value is only available after content dimensions are established.',
    );
    return hasContentDimensions || haveDimensions
        ? _cachedPage ??
              getPageFromPixels(
                clampDouble(pixels, minScrollExtent, maxScrollExtent),
                viewportDimension,
              )
        : null;
  }

  @override
  void saveScrollOffset() {
    PageStorage.maybeOf(context.storageContext)?.writeState(
      context.storageContext,
      _cachedPage ?? getPageFromPixels(pixels, viewportDimension),
    );
  }

  @override
  void restoreScrollOffset() {
    if (!hasPixels) {
      final value =
          PageStorage.maybeOf(context.storageContext)?.readState(context.storageContext) as double?;
      if (value != null) {
        _pageToUseOnStartup = value;
      }
    }
  }

  @override
  void saveOffset() {
    context.saveOffset(_cachedPage ?? getPageFromPixels(pixels, viewportDimension));
  }

  @override
  void restoreOffset(double offset, {bool initialRestore = false}) {
    if (initialRestore) {
      _pageToUseOnStartup = offset;
    } else {
      jumpTo(getPixelsFromPage(offset));
    }
  }

  @override
  bool applyViewportDimension(double viewportDimension) {
    final double? oldViewportDimensions = hasViewportDimension ? this.viewportDimension : null;
    if (viewportDimension == oldViewportDimensions) {
      return true;
    }
    final bool result = super.applyViewportDimension(viewportDimension);
    final double? oldPixels = hasPixels ? pixels : null;
    double page;
    if (oldPixels == null) {
      page = _pageToUseOnStartup;
    } else if (oldViewportDimensions == 0.0) {
      // If resize from zero, we should use the _cachedPage to recover the state.
      page = _cachedPage!;
    } else {
      page = getPageFromPixels(oldPixels, oldViewportDimensions!);
    }
    final double newPixels = getPixelsFromPage(page);

    // If the viewportDimension is zero, cache the page
    // in case the viewport is resized to be non-zero.
    _cachedPage = (viewportDimension == 0.0) ? page : null;

    if (newPixels != oldPixels) {
      correctPixels(newPixels);
      return false;
    }
    return result;
  }

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);
    assert(_cachedPage == null);

    if (other is! _DuplicatedPagePosition) {
      return;
    }

    if (other._cachedPage != null) {
      _cachedPage = other._cachedPage;
    }
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    final double newMinScrollExtent = minScrollExtent + _initialPageOffset;
    return super.applyContentDimensions(
      newMinScrollExtent,
      math.max(newMinScrollExtent, maxScrollExtent - _initialPageOffset),
    );
  }

  @override
  PageMetrics copyWith({
    double? minScrollExtent,
    double? maxScrollExtent,
    double? pixels,
    double? viewportDimension,
    AxisDirection? axisDirection,
    double? viewportFraction,
    double? devicePixelRatio,
  }) {
    return PageMetrics(
      minScrollExtent: minScrollExtent ?? (hasContentDimensions ? this.minScrollExtent : null),
      maxScrollExtent: maxScrollExtent ?? (hasContentDimensions ? this.maxScrollExtent : null),
      pixels: pixels ?? (hasPixels ? this.pixels : null),
      viewportDimension:
          viewportDimension ?? (hasViewportDimension ? this.viewportDimension : null),
      axisDirection: axisDirection ?? this.axisDirection,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      devicePixelRatio: devicePixelRatio ?? this.devicePixelRatio,
    );
  }
}