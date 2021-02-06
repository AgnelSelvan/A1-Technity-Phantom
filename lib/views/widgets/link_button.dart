import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stock_q/views/styles/custom.dart';

class LinkButton extends StatelessWidget {
  final GestureTapCallback _onPressed;
  final String buttonText;
  LinkButton(this.buttonText, this._onPressed);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: _onPressed, child: Text(buttonText, style:Custom().linkButtonTextStyle,));
  }
}