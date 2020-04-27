import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import './PaintPage.dart';
import 'package:google_fonts/google_fonts.dart';

class BluetoothPage extends StatefulWidget {
  @override
  _BluetoothPage createState() => new _BluetoothPage();
}

class _BluetoothPage extends State<BluetoothPage> {
  final String _btName = "Remote Spry";
  final String _msgConnecting = "Connecting ...";

  bool turningOn = false;
  bool connected = false;
  String msg = "Loading ...";

  @override
  void initState() {
    super.initState();

    // ENABLE BT IF IT'S NOT ENABLED
    FlutterBluetoothSerial.instance.state.then((state) {
      if (!state.isEnabled) {
        setState(() {
          turningOn = true;
        });
        _turnOnBT().then((_) {
          setState(() {
            turningOn = false;
          });
        });
      }
      else {
        setState(() {
          msg = _msgConnecting;
        });
        _connect();
      }
    });

    // ON BT STATE CHANGE
    FlutterBluetoothSerial.instance.onStateChanged().listen((BluetoothState state) {
      if (!state.isEnabled && !turningOn){
        setState(() {
          turningOn = true;
        });
        _turnOnBT().then((_) {
          setState(() {
            turningOn = false;
          });
        });
      }
      if (state.isEnabled) {
        setState(() {
          msg = _msgConnecting;
        });
        _connect();
      }
    });

  }

  // LOOP UNTIL BT IS ENABLED
  Future<void> _turnOnBT() async {
    var state = await FlutterBluetoothSerial.instance.state;
    while (!state.isEnabled) {
      await FlutterBluetoothSerial.instance.requestEnable();
      state = await FlutterBluetoothSerial.instance.state;
    }
  }

  // CONNECT TO BT
  Future<void> _connect() async {
    print("Init discovery!");
    var discovery = FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      if (r.device.name == _btName) {
        setState(() {
          connected = true;
        });
        FlutterBluetoothSerial.instance.cancelDiscovery();
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, ani, _) => PaintPage(
              server: r.device,
              ani: ani,
            ),
            transitionsBuilder: (_, animation, __, child) =>  FadeTransition(
              child: child,
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            transitionDuration: Duration(milliseconds: 1000),
          ),
        ).then((_) {
          _connect();
        });
      }
    });
    discovery.onDone(() {
      print("Done discovering");
      if(!connected) _connect();
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(children: [
        Flexible(
          flex: 15,
          child: Center(
            child: Hero(
              tag: "title",
              child: Text(
                "zTk",
                style: GoogleFonts.permanentMarker(
                  textStyle: TextStyle(
                    fontSize: 100,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 75,
          child: Center(child: Image.asset(
            "assets/radar.webp"
          )),
        ),
        Flexible(
          flex: 10,
          child: Center(child: Text(
            msg,
            style: GoogleFonts.rockSalt(
              textStyle: TextStyle(
                fontSize: 30,
                color: Colors.white,
                decoration: TextDecoration.none,
              ),
            ),
          )),
        ),
      ])
    );
  }
}