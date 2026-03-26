# Flutter Nested Scrollables

Seamless scrolling between nested Scrollable widgets.

## Features

Use a `ScrollableNester` widget to wrap your scrollables, to automatically
link their associated controllers, child to parent, or build your own chain of
controllers manually.

## Usage

The package provides some controllers and widgets :
- the `NestedScrollController`, used in place of a `ScrollController`
- the `NestedPageController`, used in place of a `PageController`

- the `ScrollableNester` widget, which creates the relevant controller if none is provided manually

And also mixins to implement custom controllers if needed :
- the `NestedScrollableController` mixin, and its associated
- `NestedScrollablePosition` mixin, used by the position created by the controller


### With the ScrollableNester widget

```dart
final Widget Function(BuildContext context, int index) _itemBuilder;
final Widget _child;
final pageController = NestedPageController();

// The `controller` parameter is optional in both the
// named constructors, and one will be created internally if
// left null.
ScrollableNester.pageView(
    controller: nestedPageController,
    builder: (context, controller) {
        // Use the controller in the scrollable widget
        return PageView(
            controller: controller,
            children: [
                // Both the following scrollables control the
                // parent PageView when they reach the end of
                // their extent
                ScrollableNester.scrollView(
                    builder: (context, controller) {
                        return ListView.builder(
                            controller: controller,
                            itembuilder: _itemBuilder,
                        );
                    },
                ),
                // The unnamed constructor requires a controller
                // to be provided
                ScrollableNester(
                    controller: NestedScrollController(),
                    builder: (context, controller) {
                        return SingleChildScrollView(
                            controller: controller,
                            child: _child,
                        );
                    },
                );
            ],
        )
    }
);
```

The `ScrollableNester` widget will search for a parent nested scrollable and attach it to its controller automatically.
If the controller is set as a "root", the chain ends with that controller.

To force a controller as root, set its `primary` parameter to `true` :
```dart
final controller = NestedScrollController(
    primary: true,
);

ScrollableNester.pageView(
    primary: true,
    builder: ...
);
```


### Manual controller linking

You can manually attach a `NestedScrollableController` to another one, wherever their associated `Scrollable` widget might sit in the tree.

```dart
final parentController = NestedPageController();
final childController = NestedScrollController();

childController.attachParent(parentController);
```

The controller that is attached to another is considered the parent controller, and will be scrolled by the child when the child attempts to scroll past one of its edges.
The link can be reset by calling `childController.attachParent(null)` or changed at will.

*NOTE :* scroll nesting searches for parents that scroll along the same `Axis`.
When a scrollable attempts to defer its movement up the chain, any parent controller using a position that doesn't share its axis will be skipped and will pass along its own parent to the child, until a suitable candidate is found or the end of the chain is reached.