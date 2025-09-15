import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class FlushbarManager {
  static Flushbar<dynamic>? _activeFlushbar;

  static void showFlushbar(Flushbar<dynamic> flushbar, BuildContext context) {
    _activeFlushbar?.dismiss();
    _activeFlushbar = flushbar;
    _activeFlushbar?.show(context).then((_) {
      _activeFlushbar = null;
    });
  }

  static void dismiss() {
    _activeFlushbar?.dismiss();
    _activeFlushbar = null;
  }
}
