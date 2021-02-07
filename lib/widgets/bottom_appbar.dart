import 'package:flutter/material.dart';
import 'package:stock_q/utils/universal_variables.dart';

class BarItem {
  String title;
  IconData iconData;
  BarItem({this.title, this.iconData});
}

class AnimatedBottomBar extends StatefulWidget {
  final List<BarItem> barItems;
  final Duration duration;
  final Function onBarTap;
  AnimatedBottomBar(
      {this.barItems,
      this.duration = const Duration(milliseconds: 500),
      this.onBarTap});
  @override
  _AnimatedBottomBarState createState() => _AnimatedBottomBarState();
}

class _AnimatedBottomBarState extends State<AnimatedBottomBar>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
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
      _barItems.add(InkWell(
        hoverColor: Colors.grey[200],
        splashColor: Colors.grey[200],
        onTap: () {
          setState(() {
            selectedIndex = i;
            widget.onBarTap(i);
          });
        },
        child: AnimatedContainer(
          padding: EdgeInsets.all(8.0),
          duration: widget.duration,
          decoration: BoxDecoration(
              color: isSelected ? Colors.grey[200] : Colors.transparent,
              borderRadius: BorderRadius.circular(24.0)),
          child: Row(
            children: <Widget>[
              Icon(
                item.iconData,
                color: isSelected ? Variables.primaryColor : Colors.black,
              ),
              SizedBox(
                width: 4.0,
              ),
              AnimatedSize(
                curve: Curves.easeInOut,
                child: Text(
                  isSelected ? item.title : "",
                  style: TextStyle(
                      color: Variables.primaryColor,
                      fontSize: 14,
                      letterSpacing: 1.25,
                      fontWeight: FontWeight.w600),
                ),
                duration: widget.duration,
                vsync: this,
              ),
            ],
          ),
        ),
      ));
    }

    return _barItems;
  }
}
