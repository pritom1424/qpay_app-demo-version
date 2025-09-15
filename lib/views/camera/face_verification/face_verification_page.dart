import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/providers/dashboard_provider.dart';
import 'package:qpay/providers/face_expression_provider.dart';
import 'package:qpay/providers/user_registration_state_provider.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/auth_router.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/utils/camera_utils.dart';
import 'package:qpay/utils/face_expression_utils.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/instruction_container.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/progress_dialog.dart';

class FaceVerificationPage extends StatefulWidget {
  @override
  _FaceVerificationPageState createState() => _FaceVerificationPageState();
}

class _FaceVerificationPageState extends State<FaceVerificationPage>
    with TickerProviderStateMixin {
  void _captureImage() async {
    if (_controller!.value.isInitialized) {
      try {
        await _controller?.stopImageStream();
        await takePictureAndExit();
      } on CameraException catch (e) {
        await takePictureAndExit();
        return null;
      }
    }
  }

  Future takePictureAndExit() async {
    if (provider.user?.imageUrl != '' && provider.user?.imageUrl != null) {
      await _controller?.takePicture().then((XFile file) {
        if (mounted) {
          setState(() {
            filePath = file.path;
          });
        }
      });
      NavigatorUtils.goBackWithParams(context, filePath);
    } else {
      await _controller?.takePicture().then((XFile file) {
        if (mounted) {
          setState(() {
            filePath = file.path;
          });
        }
      });
      registrationDataHolder.setProfileImagePath(filePath);
      NavigatorUtils.push(context, AuthRouter.registerNIDVerificationPage);
    }
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initCamera() async {
    _controller = new CameraController(
      await getCamera(CameraLensDirection.front),
      ResolutionPreset.medium,
    );
    await _controller?.initialize();
    if (mounted) setState(() {});
  }
}
