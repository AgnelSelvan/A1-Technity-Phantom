import 'dart:math';

import 'package:flutter/material.dart';
import 'package:stock_q/utils/universal_variables.dart';

class CustomCircularLoading extends StatefulWidget {
  @override
  _CustomCircularLoadingState createState() => _CustomCircularLoadingState();
}

class _CustomCircularLoadingState extends State<CustomCircularLoading>
    with SingleTickerProviderStateMixin {
  AnimationController progressController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    animation = Tween<double>(begin: 0, end: 80).animate(progressController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 3,
        backgroundColor: Colors.white,
        valueColor: AlwaysStoppedAnimation<Color>(Variables.primaryColor),
      ),
    );

    // return Center(
    //   child: CustomPaint(
    //     foregroundPainter: CircleProgress(animation.value),
    //     child: Container(
    //       width: 200,
    //       height: 200,
    //       child: Center(child: Text(animation.value.toInt().toString()),),
    //     ),
    //   ),
    // );
  }
}

class CircleProgress extends CustomPainter {
  double currentProgress;

  CircleProgress(this.currentProgress);

  @override
  void paint(Canvas canvas, Size size) {
    Paint outerCircle = Paint()
      ..strokeWidth = 10
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    Paint completeArc = Paint()
      ..strokeWidth = 7
      ..color = Colors.redAccent
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = min(size.width / 2, size.height / 2) - 10;

    canvas.drawCircle(center, radius, outerCircle);

    double angle = 2 * pi * (currentProgress / 100);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        angle, false, completeArc);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return null;
  }
}
