import 'package:flutter/material.dart';
import 'package:stock_q/styles/custom.dart';

class PrimaryButton extends StatelessWidget {
  final GestureTapCallback _onPressed;
  final String buttonText;
  PrimaryButton(this.buttonText, this._onPressed);
  @override
  Widget build(BuildContext context) {
    return FlatButton(color: Color(0xff333333), onPressed: _onPressed, child: Text(buttonText, style:Custom().buttonTextStyle,));
  }
}