import 'package:annaistore/utils/universal_variables.dart';
import 'package:flutter/material.dart';

RaisedButton buildRaisedButton(
    String text, Color buttonColor, Color color, GestureTapCallback onPressed) {
  return RaisedButton(
    elevation: 0,
    onPressed: onPressed,
    color: buttonColor,
    child: Text(
      text,
      style: TextStyle(color: color),
    ),
  );
}

SnackBar customSnackBar(String text, Color textColor) {
  return SnackBar(
    content: Text(
      text,
      style: TextStyle(color: textColor),
    ),
    duration: Duration(seconds: 2),
    backgroundColor: Colors.yellow[100],
  );
}
