import 'package:flutter/material.dart';
import 'package:remote_spray/BluetoothPage.dart';

import './BluetoothPage.dart';

void main() => runApp(new ExampleApplication());

class ExampleApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BluetoothPage());
  }
}
