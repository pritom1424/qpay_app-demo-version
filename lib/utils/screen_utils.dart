import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';

class Screen {
  static double get _ppi => (Platform.isAndroid || Platform.isIOS) ? 150 : 96;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;
  static Size size(BuildContext context) => MediaQuery.of(context).size;

  static double width(BuildContext context) => size(context).width;

  static double height(BuildContext context) => size(context).height;

  static double diagonal(BuildContext context) {
    Size s = size(context);
    return sqrt((s.width * s.width) + (s.height * s.height));
  }

  static Size inches(BuildContext context) {
    Size pxSize = size(context);
    return Size(pxSize.width / _ppi, pxSize.height / _ppi);
  }

  static double widthInches(BuildContext context) => inches(context).width;

  static double heightInches(BuildContext context) => inches(context).height;

  static double diagonalInches(BuildContext context) =>
      diagonal(context) / _ppi;
}
