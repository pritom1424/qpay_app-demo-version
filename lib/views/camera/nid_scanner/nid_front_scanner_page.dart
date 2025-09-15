import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/providers/nid_update_status_provider.dart';
import 'package:qpay/res/gaps.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/auth_router.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/routers/home_router.dart';
import 'package:qpay/routers/routers.dart';
import 'package:qpay/utils/smart_card_parser.dart';
import 'package:qpay/utils/toast.dart';
import 'package:qpay/utils/utils.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/load_image.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/my_dialog.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/progress_dialog.dart';

class NationalIdFrontScannerPage extends StatefulWidget {
  const NationalIdFrontScannerPage({Key? key}) : super(key: key);

  @override
  NationalIdFrontScannerPageState createState() =>
      NationalIdFrontScannerPageState();
}

class NationalIdFrontScannerPageState extends State<NationalIdFrontScannerPage>
    with AutomaticKeepAliveClientMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void logError(String code, String message) =>
      print('Error: $code\nError Message: $message');

  @override
  bool get wantKeepAlive => true;

  Future _analyzeImage(String filePath) async {
    setState(() {});
  }

  /*void checkTexts(List<TextBlock> list) {
    if (list == null || list.isEmpty) {
      return;
    }
    var parser = SmartCardParser();
    var results = parser.parse(list);

    if (results.containsKey(Constant.nidKey)
    ) {

      _isNidNumberFound = true;
    }
  }

  void checkFace(Face face) {
    if (face == null) {
      return;
    }
    _isFaceFound = true;
  }*/
}
