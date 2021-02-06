import 'package:flutter/cupertino.dart';
import 'package:stock_q/styles/custom.dart';

class SectionTitle extends StatelessWidget {
  final title;
  final Custom custom = Custom();
  SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: custom.titleTextStyle,
    );
  }
}
