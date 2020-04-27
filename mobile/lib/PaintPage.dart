import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';

class PaintPage extends StatefulWidget {
  final BluetoothDevice server;
  final Animation<double> ani;

  const PaintPage({this.server, this.ani});

  @override
  _PaintPage createState() => new _PaintPage();
}

class _PaintPage extends State<PaintPage> {
  double paintPower = 0;
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
          onWillPop: () async {
            print("NOPE");
            Future.value(false); //return a `Future` with false value so this route cant be popped or closed.
          },
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
        Container(
          margin: EdgeInsets.only(
            top: screen.height * (1.3 - initAnimation)
          ),
          width: screen.width,
          child: OverflowBox(
              child: Image.asset(
              "assets/spray.png",
              height: screen.height * 0.7,
              // fit: BoxFit.fitHeight,
            ),
            maxHeight: screen.height * 0.7,
          ),
        ),
        Container(
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
        Container(
          // alignment: Alignment.topCenter,
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
      ],)
    );
  }

  _startPainting() {
    setState(() {
      paintPower = 1;
    });
    _sendMessage("1");
  }

  _stopPainting() {
    setState(() {
      paintPower = 0;
    });
    _sendMessage("0");
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
      print("FOO: " + x + " KETA");
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
