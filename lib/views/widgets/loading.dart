import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 96,
      width: MediaQuery.of(context).size.width,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
