import 'dart:async';

import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/res/colors.dart';
import 'package:qpay/res/dimens.dart';
import 'package:qpay/views/login/login_page_presenter.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/res/gaps.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/routers/routers.dart';
import 'package:qpay/utils/device_utils.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:timer_count_down/timer_controller.dart';
import '../../net/error_handler.dart';
import 'login_iview.dart';

class DeviceChangePage extends StatefulWidget {
  @override
  _DeviceChangeViewState createState() => _DeviceChangeViewState();
}

class _DeviceChangeViewState extends State<DeviceChangePage>
    with
        BasePageMixin<DeviceChangePage, LoginPagePresenter>,
        AutomaticKeepAliveClientMixin<DeviceChangePage>
    implements LoginIMvpView {
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool _clickable = false;
  final _deviceInfoProvider = DeviceInfoProvider();
  Map<String, dynamic>? _deviceData;
  String? _countDown;
  CountdownController? _otpCountDown;
  int _otpTimeInMS = 180;
  bool _resendButtonEnable = false;
  late Timer? _timer;
  int _currentTimerValue = 180;
  @override
  void initState() {
    _startCountDown();
    super.initState();
    _deviceInfoProvider.addListener(() {
      _deviceData = _deviceInfoProvider.deviceData;
    });
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _deviceInfoProvider.dispose();
    super.dispose();
  }

  static const focusedBorderColor =
      Colours.app_main; //Color.fromRGBO(23, 171, 144, 1);
  static const fillColor = Color.fromRGBO(243, 246, 249, 0);
  static const borderColor = Color.fromRGBO(0, 0, 0, 1);

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: borderColor),
    ),
  );
  void _startCountDown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentTimerValue > 0) {
          _currentTimerValue--;
        } else {
          _timer!.cancel();
          _resendButtonEnable = true;
        }
      });
    });
  }

  void _resetTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    setState(() {
      _currentTimerValue = _otpTimeInMS;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          centerTitle: AppLocalizations.of(context)!.insertOtp.toUpperCase(),
        ),
        body: MyScrollView(
          crossAxisAlignment: CrossAxisAlignment.center,
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0),
          children: _buildBody(),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    return <Widget>[
      Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flex(
                direction: Axis.horizontal,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image(
                            image: AssetImage('assets/images/otp_icon.png'),
                            height: MediaQuery.of(context).size.height * .15,
                            width: MediaQuery.of(context).size.width * .2,
                          ),
                        ),
                        Gaps.vGap8,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Enter your OTP code",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Gaps.vGap8,
              Container(
                color: Colors.white,
                margin: const EdgeInsets.all(10.0),
                padding: const EdgeInsets.all(20.0),
                child: Pinput(
                  length: 6,
                  autofocus: true,
                  onCompleted: (String pin) => _changeDevice(pin),
                  focusNode: _pinPutFocusNode,
                  controller: _pinPutController,
                  androidSmsAutofillMethod:
                      AndroidSmsAutofillMethod.smsUserConsentApi,
                  listenForMultipleSmsOnAndroid: true,
                  defaultPinTheme: defaultPinTheme,
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration?.copyWith(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration?.copyWith(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Your OTP validation will end in ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                    children: [
                      TextSpan(
                        text: '${_currentTimerValue}',
                        style: TextStyle(
                          color: Colours.app_main,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' seconds',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Gaps.vGap50,
              Gaps.vGap50,
              InkWell(
                child: Text(
                  AppLocalizations.of(context)?.resendOTP ?? '',
                  style: TextStyle(
                    color: _resendButtonEnable ? Colours.app_main : Colors.grey,
                    fontSize: Dimens.font_sp22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: _resendButtonEnable
                    ? () {
                        Future.delayed(Duration(seconds: 1), () {
                          _activeResendButton();
                          _resetTimer();
                        });
                        setState(() {
                          _resendButtonEnable = false;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _activeResendButton() async {
    var phoneNumber = SpUtil.getString(Constant.phone);
    var password = SpUtil.getString(Constant.password);
    var deviceId =
        (SpUtil.getString(Constant.fcmDeviceId) != '' &&
            SpUtil.getString(Constant.fcmDeviceId) != null)
        ? SpUtil.getString(Constant.fcmDeviceId)
        : _deviceData![DeviceInfoProvider.deviceId];
    var ip = SpUtil.getString(Constant.ipAddress);
    var lat = SpUtil.getString(Constant.latitute);
    var lon = SpUtil.getString(Constant.longititue);
    var result = await presenter.userLogin(
      phoneNumber ?? '',
      password ?? '',
      deviceId,
      _deviceData?[DeviceInfoProvider.deviceName] ?? '',
      _deviceData?[DeviceInfoProvider.deviceVersion] ?? '',
      ip ?? '',
      lat ?? '',
      lon ?? '',
      (code, msg) {
        if (code == ExceptionHandler.device_changed) {
          _startCountDown();
        }
      },
    );
  }

  void _changeDevice(String pin) async {
    var phoneNumber = SpUtil.getString(Constant.phone);
    var password = SpUtil.getString(Constant.password);
    var ip = SpUtil.getString(Constant.ipAddress);
    var lat = SpUtil.getString(Constant.latitute);
    var lon = SpUtil.getString(Constant.longititue);
    var deviceId =
        (SpUtil.getString(Constant.fcmDeviceId) != '' &&
            SpUtil.getString(Constant.fcmDeviceId) != null)
        ? SpUtil.getString(Constant.fcmDeviceId)
        : _deviceData![DeviceInfoProvider.deviceId];
    var deviceChangeResponse = await presenter.changeDevice(
      phoneNumber!,
      pin,
      deviceId,
      _deviceData![DeviceInfoProvider.deviceName],
    );

    if (deviceChangeResponse != null) {
      var loginResponse = await presenter.userLogin(
        phoneNumber,
        password!,
        deviceId,
        _deviceData![DeviceInfoProvider.deviceName],
        _deviceData![DeviceInfoProvider.deviceVersion],
        ip ?? '',
        lat ?? '',
        lon ?? '',
        (code, msg) {},
      );

      if (loginResponse != null) {
        SpUtil.putString(Constant.accessToken, loginResponse.token!);
        SpUtil.putString(Constant.refreshToken, loginResponse.refreshToken!);
        NavigatorUtils.push(
          context,
          Routes.home,
          replace: true,
          clearStack: true,
        );
      }
    }
  }

  @override
  LoginPagePresenter createPresenter() {
    return LoginPagePresenter();
  }

  @override
  bool get wantKeepAlive => true;
}
