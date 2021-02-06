import 'package:annaistore/utils/universal_variables.dart';
import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double leftSpacing;
  final double rightSpacing;
  CustomDivider({@required this.leftSpacing, @required this.rightSpacing});

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: leftSpacing,
      endIndent: rightSpacing,
      color: Variables.primaryColor,
    );
  }
}
