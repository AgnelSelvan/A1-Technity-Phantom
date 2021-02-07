import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SizeUtils {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double defaultSize;
  static double padding;
  static double appBarHeight;

  static double marginTop;
  static double marginBottom;
  static const double marginHorizontal = 26.0;

  static double blockSizeHorizontal;
  static double blockSizeVertical;

  static void init() {
    _mediaQueryData = Get.mediaQuery;
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    marginTop = window.physicalSize.height > 2088
        ? _mediaQueryData.padding.top
        : _mediaQueryData.padding.top * 2;
    marginBottom = _mediaQueryData.padding.bottom;

    appBarHeight = AppBar().preferredSize.height;
  }
}
