import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

import './SettingsPage.dart';

class PaintPage extends StatefulWidget {
  final BluetoothDevice server;
  final Animation<double> ani;

  const PaintPage({this.server, this.ani});

  @override
  _PaintPage createState() => new _PaintPage();
}

class _PaintPage extends State<PaintPage> {
  double paintPower = 0;
  int powerIndex = 1;
  List<String> powerValues = ["0", "60", "120", "180"];
  double initAnimation = 0;

  static final clientID = 0;
  BluetoothConnection connection;

  String _messageBuffer = '';

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    // Initial initAnimation
    widget.ani.addListener((){
      setState(() {
        initAnimation = widget.ani.value;
      });
    });
    BluetoothConnection. toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        if (this.mounted) {
          setState(() {});
        }
        Navigator.of(context).pop();
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
      Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Container(
      color: Colors.black,
      child: Stack(children: [
        WillPopScope(
          onWillPop: () async => Future.value(false), // Disable back button
          child: Container( // PAINT FX
            alignment: Alignment.topCenter,
            child: Stack(children: [
              Image.asset(
                "assets/fx4.webp",
                height: screen.height * 0.65,
                color: Color.fromRGBO(255,255,255, paintPower),
                colorBlendMode: BlendMode.modulate,
              ),
              Image.asset(
                "assets/whiteFilter.gif",
                height: screen.height * 0.65,
                color: Color.fromRGBO(255,255,255, paintPower),
                colorBlendMode: BlendMode.modulate,
              ),
            ])
          ),
        ),
        Container( // SPRAY
          margin: EdgeInsets.only(
            top: screen.height * (1.3 - initAnimation)
          ),
          width: screen.width,
          child: OverflowBox(
              child: Image.asset(
              "assets/spray.png",
              height: screen.height * 0.7,
            ),
            maxHeight: screen.height * 0.7,
          ),
        ),
        Container( // zTk
          margin: EdgeInsets.only(
            top: screen.height * 0.65
          ),
          alignment: Alignment.center,
          child: Hero(
            tag: "title",
            child: Text(
              "zTk",
              style: GoogleFonts.permanentMarker(
                textStyle: TextStyle(
                  fontSize: 100,
                  color: Colors.black,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
        Container( // Paint Button
          width: screen.height * 0.3,
          height: screen.height * 0.3,
          margin: EdgeInsets.only(
            top: screen.height * 0.2,
            left: screen.width * 0.5 - screen.height * 0.15,
          ),
          child: GestureDetector(
            child: Image.asset(
              "assets/circleRed.png",
              color: Color.fromRGBO(255,255,255, initAnimation > 0.7 ?
                1 - paintPower -10*(1-initAnimation) : 0),
              colorBlendMode: BlendMode.modulate,
            ),
            onTapDown: (_) {
              _startPainting();
            },
            onTapUp: (_) {
              _stopPainting();
            },
            onLongPressEnd: (_) {
              _stopPainting();
            },
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          child: Column(children: [
            Container(
              width: screen.width * 0.3,
              margin: EdgeInsets.only(
                top: screen.height * 0.55,
                left: screen.width * 0.05,
              ),
              child: FittedBox(child: FloatingActionButton(
                backgroundColor: powerIndex == 3?
                  Colors.white :
                  Colors.transparent,
                heroTag: "powerButton3",
                onPressed: () { setState(() {
                  powerIndex = 3;
                });},
                child: Image.asset("assets/dot.png"),
              ),),
            ),
            Container(
              width: screen.width * 0.2,
              margin: EdgeInsets.only(
                top: screen.height * 0.05,
                left: screen.width * 0.05,
              ),
              child: FittedBox(child: FloatingActionButton(
                backgroundColor: powerIndex == 2?
                  Colors.white :
                  Colors.transparent,
                heroTag: "powerButton2",
                onPressed: () { setState(() {
                  powerIndex = 2;
                });},
                child: Image.asset("assets/dot.png"),
              ),),
            ),
            Container(
              width: screen.width * 0.1,
              margin: EdgeInsets.only(
                top: screen.height * 0.05,
                left: screen.width * 0.05,
              ),
              child: FittedBox(child: FloatingActionButton(
                backgroundColor: powerIndex == 1?
                  Colors.white :
                  Colors.transparent,
                heroTag: "powerButton1",
                onPressed: () { setState(() {
                  powerIndex = 1;
                });},
                child: Image.asset("assets/dot.png"),
              ),),
            ),
          ]),
        ),
        Container(
          width: screen.width * 0.2,
          margin: EdgeInsets.only(
            top: screen.height * 0.05,
            left: screen.width * 0.75,
          ),
          child: FittedBox(child: FloatingActionButton(
            backgroundColor: Colors.transparent,
            heroTag: "settingButton",
            onPressed: () {
              Navigator.push(context, new MaterialPageRoute(
                builder: (BuildContext context) =>
                    SettingsPage(powerValues: powerValues,)
              ));
            },
            child: Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),),
        ),
      ])
    );
  }

  _startPainting() {
    setState(() {
      paintPower = 1;
    });
    _sendMessage(powerValues[powerIndex]);
  }

  _stopPainting() {
    setState(() {
      paintPower = 0;
    });
    _sendMessage(powerValues[0]);
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      var x = backspacesCounter > 0
              ? _messageBuffer.substring(
                  0, _messageBuffer.length - backspacesCounter)
              : _messageBuffer + dataString.substring(0, index);
      _messageBuffer = dataString.substring(index);
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    if (text.length > 0) {
      connection.output.add(utf8.encode(text + "\r\n"));
      await connection.output.allSent;
    }
  }
}
