import 'dart:ui';

import 'package:flutter/material.dart';

Widget listItemBuilder(BuildContext context, int index) {
  return ListTile(
    title: Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Spacer(flex: 1),
        Flexible(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('- $index'),
          ),
        ),
      ],
    ),
  );
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  const CustomScrollBehavior();
  
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}