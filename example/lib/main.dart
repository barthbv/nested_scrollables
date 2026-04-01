import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nested_scrollables/nested_scrollables.dart';

import 'utils.dart';
import 'widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
  runApp(const NestedScrollablesExample());
}

class NestedScrollablesExample extends StatelessWidget {
  const NestedScrollablesExample({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NestedScrollables Example',
      scrollBehavior: CustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      home: FlutterWebDeviceFrameConstraints(
        child: Scaffold(
          body: RootPageView(),
        ),
      ),
    );
  }
}

class RootPageView extends StatelessWidget {
  const RootPageView({super.key});

  @override
  Widget build(BuildContext context) {
    /// This PageView has some children scrollable widgets in its pages,
    /// and is the topmost scrollable of this example (the "root" of
    /// all descendent nested scrollables of this tree).
    /// 
    /// To manually set a NestedScrollableController as a root and stop
    /// further propagation of a scrollable chain, set `primary: true` in
    /// the controller's constructor, or if you're using an automatically
    /// provided controller, in the ScrollableNester constructor.
    return ScrollableNester.pageView(
      primary: true,
      builder: (context, controller) => PageView(
        scrollDirection: Axis.vertical,
        controller: controller,
        physics: ClampingScrollPhysics(),
        children: const [
          NestedFirstPage(),
          NestedSecondPage(),
          NestedThirdPage(),
        ],
      ),
    );
  }
}

class NestedFirstPage extends StatelessWidget {
  const NestedFirstPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageBackground(
          backgroundColor: Colors.lightBlue,
          sleeveColor: Colors.lightBlueAccent,
          text: '- Page 1 -',
        ),
        
        /// This ListView occupies the first page of the
        /// PageView.
        /// The controller is provided by the ScrollableNester widget and will
        /// automatically find the controller used by the PageView and set it
        /// as its parent.
        ScrollableNester.scrollView(
          builder: (context, controller) {
            return ListView.builder(
              key: const PageStorageKey('firstPageListView'),
              itemCount: 25,
              shrinkWrap: true,
              controller: controller,
              itemBuilder: listItemBuilder,
            );
          },
        ),
      ],
    );
  }
}

class NestedSecondPage extends StatelessWidget {
  const NestedSecondPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageBackground(
          backgroundColor: Colors.lightGreen,
          sleeveColor: Colors.lightGreenAccent,
          text: '- Page 2 -',
        ),
        
        /// This ListView occupies the second page of the
        /// PageView.
        /// The controller is provided by the ScrollableNester widget and will
        /// automatically find the controller used by the PageView and set it
        /// as its parent.
        ScrollableNester.scrollView(
          builder: (context, controller) {
            return ListView.builder(
              key: const PageStorageKey('secondPageListView'),
              itemCount: 30,
              shrinkWrap: true,
              controller: controller,
              itemBuilder: listItemBuilder,
            );
          },
        ),
      ],
    );
  }
}

class NestedThirdPage extends StatefulWidget {
  const NestedThirdPage({super.key});

  @override
  State<NestedThirdPage> createState() => _NestedThirdPageState();
}

class _NestedThirdPageState extends State<NestedThirdPage> {
  final _topScrollViewController = NestedScrollController();
  final _bottomScrollViewController = NestedScrollController();
  
  @override
  void initState() {
    super.initState();
    
    /// Build custom nested behaviors by manually attaching two controllers.
    /// The controller calling [attachParent] will be considered a child of
    /// the other.
    /// Providing a controller to a ScrollableNester widget will override
    /// any manual linking of two controllers.
    _bottomScrollViewController.attachParent(_topScrollViewController);
  }
  
  static Widget _renderFirstColumn() {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(flex: 1),
        Flexible(
          flex: 2,
          child: PageColumn(
            child: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'This ',
                  ),
                  TextSpan(
                    text: 'ScrollView',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  TextSpan(
                    text: ' can be scrolled by its neighbour '
                        'despite not being its ancestor.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
  
  static Widget _renderSecondColumn() {
    return PageColumn(
      color: Colors.amber.shade600,
      child: const Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'The left ',
            ),
            TextSpan(
              text: 'ScrollView',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(
              text: ' was manually attached to this '
                  'one as its parent.',
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const PageBackground(
          backgroundColor: Colors.amber,
          sleeveColor: Colors.amberAccent,
          text: '- Page 3 -',
        ),
        
        /// This page contains two scrollables that each occupy
        /// a separate part of the screen, yet are still linked via
        /// a NestedScrollableController.
        Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 3,
              
              /// This SingleChildScrollView is manually set as a parent to
              /// the SingleChildScrollView below, despite it not being
              /// a child of one of its elements.
              /// 
              /// Since it is still wrapped in a ScrollableNester, both
              /// are still part of the same chain of scrollables, and
              /// scrolling the bottom SingleChildScrollView will
              /// ultimately scroll the topmost PageView.
              child: ScrollableNester(
                controller: _topScrollViewController,
                builder: (context, controller) => SingleChildScrollView(
                  key: const PageStorageKey('thirdPageLeftColumn'),
                  controller: controller,
                  clipBehavior: Clip.hardEdge,
                  child: _renderFirstColumn(),
                ),
              ),
            ),
            
            Expanded(
              flex: 2,
              
              /// This SingleChildScrollView doesn't use a
              /// SrollableNester widget as a wrapper, so its controller
              /// will not automatically search for a parent to attach.
              /// 
              /// Since it is not a child of the above SingleChildScrollView,
              /// the nearest controller it would have found would be the
              /// one used by the PageView.
              /// 
              /// We want this scrollable to defer to the one above, so we
              /// set the link manually in the initState() function.
              child: SingleChildScrollView(
                key: const PageStorageKey('thirdPageRightColumn'),
                controller: _bottomScrollViewController,
                clipBehavior: Clip.hardEdge,
                child: _renderSecondColumn(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}