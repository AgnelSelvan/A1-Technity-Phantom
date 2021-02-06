import 'package:flutter/material.dart';

class AnimatedBottomBar extends StatefulWidget {
  final List<IconData> barItems;
  final Duration duration;
  final Function onBarTap;
  AnimatedBottomBar(
      {this.barItems,
      this.duration = const Duration(milliseconds: 500),
      this.onBarTap});
  @override
  _AnimatedBottomBarState createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildBarItems()),
      ),
    );
  }

  List<Widget> _buildBarItems() {
    List<Widget> _barItems = List<Widget>();

    for (int i = 0; i < widget.barItems.length; i++) {
      var item = widget.barItems.elementAt(i);
      bool isSelected = selectedIndex == i;

      _barItems.add(GestureDetector(
        child: Container(
          width: 48,
          height: 36,
          child: Icon(
            item,
            size: isSelected ? 28 : 24,
            color: isSelected ? Colors.black87 : Colors.grey,
          ),
        ),
        onTap: () {
          setState(() {
            selectedIndex = i;
            widget.onBarTap(i);
          });
        },
      ));
    }

    return _barItems;
  }
}
