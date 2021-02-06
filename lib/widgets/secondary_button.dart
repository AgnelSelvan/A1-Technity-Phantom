import 'package:flutter/material.dart';
import 'package:stock_q/styles/custom.dart';

class SecondaryButton extends StatelessWidget {
  final GestureTapCallback _onPressed;
  final String buttonText;
  SecondaryButton(this.buttonText, this._onPressed);
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        color: Colors.grey[200],
        onPressed: _onPressed,
        child: Text(
          buttonText,
          style: TextStyle(
              fontSize: 16,
              color: Color(0xff555555),
              fontWeight: FontWeight.bold),
        ));
  }
}
