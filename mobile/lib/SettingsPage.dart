import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_fluid_slider/flutter_fluid_slider.dart';

class SettingsPage extends StatefulWidget {
  final List<String> powerValues;
  const SettingsPage({this.powerValues});

  @override
  _SettingsPage createState() => new _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        left: screen.width * .1,
        top: screen.height * .1,    
      ),
      child: Column(children: [
        Expanded(
          child: Row(children: [
            Image.asset("assets/dot.png", width: screen.width * 0.3),
            Container(
              margin: EdgeInsets.only(left: screen.width * .05),
              child: FluidSlider(
                min: 0,
                max: 180,
                value: double.parse(widget.powerValues[3]),
                sliderColor: Color(0xFFFA0833),
                valueTextStyle: textStyle,
                labelsTextStyle: textStyle,
                thumbColor: Colors.black,
                thumbDiameter: 80,
                onChanged: (x) {
                  setState(() {
                    widget.powerValues[3] = x.toInt().toString();
                  });
                },
              ),
            ),
          ]),
          flex: 20,
        ),
        Expanded(
          child: Row(children: [
            Image.asset("assets/dot.png", width: screen.width * 0.2),
            Container(
              margin: EdgeInsets.only(left: screen.width * .15),
              child: FluidSlider(
                min: 0,
                max: 180,
                value: double.parse(widget.powerValues[2]),
                sliderColor: Color(0xFFFA0833),
                valueTextStyle: textStyle,
                labelsTextStyle: textStyle,
                thumbColor: Colors.black,
                thumbDiameter: 80,
                onChanged: (x) {
                  setState(() {
                    widget.powerValues[2] = x.toInt().toString();
                  });
                },
              ),
            ),
          ]),
          flex: 20,
        ),
        Expanded(
          child: Row(children: [
            Image.asset("assets/dot.png", width: screen.width * 0.1),
            Container(
              margin: EdgeInsets.only(left: screen.width * .25),
              child: FluidSlider(
                min: 0,
                max: 180,
                value: double.parse(widget.powerValues[1]),
                sliderColor: Color(0xFFFA0833),
                valueTextStyle: textStyle,
                labelsTextStyle: textStyle,
                thumbColor: Colors.black,
                thumbDiameter: 80,
                onChanged: (x) {
                  setState(() {
                    widget.powerValues[1] = x.toInt().toString();
                  });
                },
              ),
            ),
          ]),
          flex: 20,
        ),
        Expanded(
          child: Row(children: [
            Text(
              "idle",
              style: textStyle,
            ),
            Container(
              margin: EdgeInsets.only(left: screen.width * .2),
              child: FluidSlider(
                min: 0,
                max: 180,
                value: double.parse(widget.powerValues[0]),
                sliderColor: Color(0xFFFA0833),
                valueTextStyle: textStyle,
                labelsTextStyle: textStyle,
                thumbColor: Colors.black,
                thumbDiameter: 80,
                onChanged: (x) {
                  setState(() {
                    widget.powerValues[0] = x.toInt().toString();
                  });
                },
              ),
            ),
          ]),
          flex: 20,
        ),
      ]),
    );
  }

  final textStyle =  GoogleFonts.permanentMarker(
    textStyle: TextStyle(
      fontSize: 30,
      color: Colors.white,
      decoration: TextDecoration.none,
  ));
}