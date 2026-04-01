import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PageBackground extends StatelessWidget {
  const PageBackground({
    super.key,
    this.backgroundColor = Colors.transparent,
    this.sleeveColor = Colors.transparent,
    this.text = '',
    this.sleeveWidthRatio = 0.2,
  });
  
  final Color backgroundColor;
  final Color sleeveColor;
  final String text;
  final double sleeveWidthRatio;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: backgroundColor,
        child: FractionallySizedBox(
          alignment: AlignmentGeometry.topLeft,
          widthFactor: sleeveWidthRatio,
          child: ColoredBox(
            color: sleeveColor,
            child: Center(
              child: RotatedBox(
                quarterTurns: -1,
                child: Text(text),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PageColumn extends StatelessWidget {
  const PageColumn({
    super.key,
    this.whiteSpaceRatio = 0.5,
    this.color,
    required this.child,
  });
  
  final double whiteSpaceRatio;
  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Icon(Icons.arrow_drop_up_sharp),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: MediaQuery.sizeOf(context).height * whiteSpaceRatio,
            ),
            child: child,
          ),
          const Icon(Icons.arrow_drop_down_sharp),
        ],
      ),
    );
    
    if (color != null) {
      content = ColoredBox(
        color: color!,
        child: content,
      );
    }
    
    return content;
  }
}

class FlutterWebDeviceFrameConstraints extends StatelessWidget {
  const FlutterWebDeviceFrameConstraints({
    super.key,
    required this.child,
  });
  
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;
    
    return ColoredBox(
      color: Colors.black87,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints.loose(const Size(432, 912)),
          child: AspectRatio(
            aspectRatio: 9/16,
            child: child,
          ),
        ),
      ),
    );
  }
}