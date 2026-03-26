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
    return MaterialApp(
      title: 'NestedScrollables Example',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: const RootPageView(),
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
        children: [
          const FirstPage(),
          const SecondPage(),
          const ThirdPage(),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({
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
        
        ScrollableNester.scrollView(
          builder: (context, controller) {
            final size = MediaQuery.of(context).size;
            
            return ListView.builder(
              key: const PageStorageKey('firstPageListView'),
              itemCount: 40,
              shrinkWrap: true,
              controller: controller,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.2),
                    child: Text('- $i'),
                  ),
                );
              }
            );
          },
        ),
      ],
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({
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
            final size = MediaQuery.of(context).size;
            
            return ListView.builder(
              key: const PageStorageKey('secondPageListView'),
              itemCount: 70,
              shrinkWrap: true,
              controller: controller,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.2),
                    child: Text('- $i'),
                  ),
                );
              }
            );
          },
        ),
      ],
    );
  }
}

class ThirdPage extends StatefulWidget {
  const ThirdPage({super.key});

  @override
  State<ThirdPage> createState() => _ThirdPageState();
}

class _ThirdPageState extends State<ThirdPage> {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        PageBackground(
          sleeveColor: Colors.amberAccent,
          text: '- Page 3 -',
          child: Column(
            children: [
              Container(
                color: Colors.amber,
                height: size.height * 0.7,
                width: size.width * 0.8,
              ),
              Container(
                color: Colors.amber.shade600,
                height: size.height * 0.3,
                width: size.width * 0.8,
              ),
            ],
          ),
        ),
        
        /// This page contains two scrollables that each occupy
        /// a separate part of the screen, yet are still linked via
        /// a NestedScrollableController.
        Column(
          children: [
            SizedBox(
              width: size.width,
              height: size.height * 0.7,
              
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
                  key: const PageStorageKey('thirdPageTopScrollView'),
                  controller: controller,
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: size.width * 0.2 + 16.0,
                      top: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: Text(
                      MockTextGenerator.generate(
                        type: MockTextType.paragraphs,
                        length: 20,
                      ),
                      style: TextStyle(
                        fontSize: 7.0,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(
              width: size.width,
              height: size.height * 0.3,
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
                key: const PageStorageKey('thirdPageBottomScrollView'),
                controller: _bottomScrollViewController,
                clipBehavior: Clip.hardEdge,
                child: Padding(
                  padding: EdgeInsets.only(left: size.width * 0.2),
                  child: Column(
                    children: [
                      ColoredBox(
                        color: Colors.deepPurpleAccent,
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('The top ScrollView was manually attached as a '
                              'to this one as a parent.'),
                        ),
                      ),
                      ColoredBox(
                        color: Colors.deepPurple,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            MockTextGenerator.generate(
                              type: MockTextType.paragraphs,
                              length: 5,
                            ),
                            style: TextStyle(
                              fontSize: 7.0,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}