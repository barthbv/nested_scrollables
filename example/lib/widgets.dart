import 'package:flutter/material.dart';

class PageBackground extends StatelessWidget {
  const PageBackground({
    super.key,
    this.backgroundColor = Colors.transparent,
    this.sleeveColor = Colors.transparent,
    this.text = '',
    this.sleeveWidthRatio = 0.2,
    this.child,
  });
  
  final Color backgroundColor;
  final Color sleeveColor;
  final String text;
  final double sleeveWidthRatio;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      color: backgroundColor,
      width: size.width,
      height: size.height,
      alignment: Alignment.topLeft,
      child: Row(
        children: [
          Container(
            color: sleeveColor,
            width: size.width * sleeveWidthRatio,
            height: size.height,
            child: Center(
              child: RotatedBox(
                quarterTurns: -1,
                child: Text(text),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}

class Sleeve extends StatelessWidget {
  const Sleeve({
    super.key,
    this.color = Colors.transparent,
    this.text = '',
    this.widthRatio = 0.2,
  });
  
  final Color color;
  final String text;
  final double widthRatio;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      color: color,
      width: size.width * widthRatio,
      height: size.height,
      child: Center(
        child: RotatedBox(
          quarterTurns: -1,
          child: Text(text),
        ),
      ),
    );
  }
}