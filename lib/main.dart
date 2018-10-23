import 'package:flutter/material.dart';

import 'main_page.dart';

void main() => runApp(new HedgehogLauncher());

class HedgehogLauncher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hedgehog Launcher',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MainPage(title: 'Hedgehog Launcher'),
    );
  }
}
