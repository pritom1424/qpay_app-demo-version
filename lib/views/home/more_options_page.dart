import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/net/contract/profile_vm.dart';
import 'package:qpay/providers/dashboard_provider.dart';
import 'package:qpay/routers/auth_router.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/routers/home_router.dart';
import 'package:qpay/static_data/cached_data_holder.dart';
import 'package:qpay/static_data/dashboard_data.dart';
import 'package:qpay/utils/image_utils.dart';
import 'package:qpay/utils/toast.dart';
import 'package:qpay/utils/utils.dart';
import 'package:qpay/views/home/profile/profile_veiw_iview.dart';
import 'package:qpay/views/home/profile/profile_view_presenter.dart';
import 'package:qpay/widgets/line_widget.dart';
import 'package:qpay/widgets/load_image.dart';
import 'package:qpay/widgets/my_dialog.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreOptionsPage extends StatefulWidget {
  @override
  _MoreOptionsPageState createState() => _MoreOptionsPageState();
}

class _MoreOptionsPageState extends State<MoreOptionsPage>
    with
        BasePageMixin<MoreOptionsPage, ProfileViewPresenter>,
        AutomaticKeepAliveClientMixin<MoreOptionsPage>
    implements ProfileViewIMvpView {
  final line = LineWidget();
  final images = DashboardImages();
  final provider = DashboardProvider();
  bool? _isInComplete;
  String _imageUrl = '';
  final ImagePicker _picker = ImagePicker();
  PackageInfo? packageInfo;
  String? appName;
  String? packageName;
  String? version;
  String? buildNumber;
  bool isChangePinEnable = true;
  bool isLimitEnable = true;
  bool isFeeCalEnable = true;
  bool isFaqEnable = true;
  bool isSupportEnable = true;
  bool isPrivacyEnable = true;
  bool isSettingsEnable = true;
  @override
  void initState() {
    super.initState();
    _imageUrl = provider.user?.imageUrl ?? '';
    _getPackageInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo!.appName;
    version = packageInfo!.version;
    buildNumber = packageInfo!.buildNumber;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        body: MyScrollView(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildBody,
        ),
      ),
    );
  }

  List<Widget> get _buildBody => [
    Container(
      width: MediaQuery.of(context).size.width,
      color: Colours.text_gray,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 100.0,
                backgroundImage: _imageUrl != ''
                    ? NetworkImage(_imageUrl)
                    : ImageUtils.getAssetImage(images.placeHolderImages[1]),
                onBackgroundImageError: (dynamic, stacktrace) {},
              ),
              Positioned(
                bottom: 0,
                right: -5,
                child: RawMaterialButton(
                  onPressed: () {
                    _showProminantAlert();
                  },
                  elevation: 2.0,
                  fillColor: Color(0xFFF5F6F9),
                  child: Icon(Icons.camera_alt, color: Colours.app_main),
                  padding: EdgeInsets.all(15.0),
                  shape: CircleBorder(),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.gap_dp12,
              vertical: Dimens.gap_dp12,
            ),
            child: ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(
                      color: Colors.black54,
                      style: BorderStyle.none,
                    ),
                  ),
                ),
                elevation: WidgetStateProperty.all<double>(10.0),
                backgroundColor: WidgetStateProperty.all<Color>(
                  Colours.app_main,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "View profile".toUpperCase(),
                    style: TextStyle(
                      fontSize: Dimens.font_sp14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                _viewProfile();
              },
            ),
          ),
        ],
      ),
    ),
    Gaps.line,
    TextButton(
      child: Row(
        children: [
          Icon(Icons.settings, color: Colours.app_main),
          Gaps.hGap12,
          Text(
            "Settings",
            style: TextStyle(color: Colors.black, fontSize: Dimens.font_sp16),
          ),
        ],
      ),
      onPressed: isSettingsEnable
          ? () {
              if (mounted) {
                setState(() {
                  isSettingsEnable = false;
                  _viewSettings();
                  Future.delayed(const Duration(milliseconds: 500), () {
                    setState(() {
                      isSettingsEnable = true;
                    });
                  });
                });
              }
            }
          : () {},
    ),
    Gaps.vGap8,
      void _viewSettings() {
    NavigatorUtils.push(context, HomeRouter.settings);
  }

  void _txnLimit() {
    NavigatorUtils.push(context, HomeRouter.txnLimit);
  }

  void _txnFees() {
    NavigatorUtils.push(context, HomeRouter.txnFees);
  }

  void _faqs() {
    NavigatorUtils.push(context, HomeRouter.faqs);
  }

  void _support() {
    NavigatorUtils.push(context, HomeRouter.support);
  }

  void _privacy() {
    NavigatorUtils.push(context, HomeRouter.privacy);
  }

  @override
  bool get isAccessibilityTest => false;

  @override
  void setUser(ProfileViewModel user) {
    provider.setUser(user);
    /* setState(() {
      _isInComplete = user.errors.length > 0;
    });*/
  }

  @override
  bool get wantKeepAlive => false;

  void _showPicker(context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                  leading: new Icon(
                    Icons.photo_library,
                    color: Colours.app_main,
                  ),
                  title: new Text(
                    'Photo Library',
                    style: TextStyle(
                      color: Colours.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () async {
                    bool? permission = Platform.isAndroid
                        ? await getPermission()
                        : true;
                    if (permission!) {
                      _imgFromGallery();
                    }
                  },
                ),
                new ListTile(
                  leading: new Icon(
                    Icons.photo_camera,
                    color: Colours.app_main,
                  ),
                  title: new Text(
                    'Camera',
                    style: TextStyle(
                      color: Colours.text,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    _imgFromCamera();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> getPermission() async {
    bool? permissionGranted;
    DeviceInfoPlugin? plugin = DeviceInfoPlugin();
    AndroidDeviceInfo? android = await plugin.androidInfo;
    if (android.version.sdkInt < 33) {
      if (await Permission.storage.request().isGranted) {
        setState(() {
          permissionGranted = true;
        });
      } else if (await Permission.storage.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.audio.request().isDenied) {
        setState(() {
          permissionGranted = false;
        });
      }
    } else {
      if (await Permission.photos.request().isGranted) {
        setState(() {
          permissionGranted = true;
        });
      } else if (await Permission.photos.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.photos.request().isDenied) {
        setState(() {
          permissionGranted = false;
        });
      }
    }

    return permissionGranted;
  }

  _imgFromGallery() async {
    XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      _imageUpload(image.path);
    }
    Navigator.of(context).pop();
  }

  _imgFromCamera() async {
    var result = await NavigatorUtils.pushAwait(
      context,
      AuthRouter.faceVerification,
    );
    if (result != null) {
      _imageUpload(result);
    }
    Navigator.of(context).pop();
  }

  _imageUpload(String imagePath) async {
    var response = await presenter.uploadProfileImage(imagePath);
    if (mounted && response != null) {
      setState(() {
        _imageUrl = response;
        provider.user?.imageUrl = _imageUrl;
      });
    }
  }

  @override
  ProfileViewPresenter createPresenter() => ProfileViewPresenter();

  _showProminantAlert() {
    showElasticDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MyDialog(
          actionText: 'Agree',
          cancelText: 'Decline',
          title: 'Privacy Alert',
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Qpay Bangladesh collects and uploads image data to enable feature to change your profile picture when the app in use.',
              textAlign: TextAlign.center,
            ),
          ),
          onBackPressed: () {
            NavigatorUtils.goBack(context);
          },
          onPressed: () {
            NavigatorUtils.goBack(context);
            _showPicker(context);
          },
        );
      },
    );
  }
}
