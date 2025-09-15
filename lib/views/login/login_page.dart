import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flustars/flustars.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/net/contract/token_vm.dart';
import 'package:qpay/net/error_handler.dart';
import 'package:qpay/net/push_notification_service.dart';
import 'package:qpay/providers/local_authentication_provider.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/auth_router.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/routers/routers.dart';
import 'package:qpay/utils/device_utils.dart';
import 'package:qpay/utils/helper_utils.dart';
import 'package:qpay/utils/utils.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/text_field.dart';
import '../../locator.dart';
import 'login_iview.dart';
import 'login_page_presenter.dart';
import 'login_sign_up_pop_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with
        WidgetsBindingObserver,
        BasePageMixin<LoginPage, LoginPagePresenter>,
        AutomaticKeepAliveClientMixin<LoginPage>
    implements LoginIMvpView {
  String? _connectionStatus;
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  Position? position;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final _deviceInfoProvider = DeviceInfoProvider();
  bool _clickable = false;
  bool _forgetEnable = true;
  bool _canRefreshSession = false;
  Map<String, dynamic>? _deviceData;
  var localAuthProvider;
  final PushNotificationService _pushNotificationService =
      locator<PushNotificationService>();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _initNetworkInfo();
    _getCurrentPosition();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) => _updateConnectionStatus(result),
    );
    WidgetsBinding.instance.addObserver(this);
    _phoneController.addListener(_verify);
    _passwordController.addListener(_verify);
    _phoneController.text = SpUtil.getString(Constant.phone)!;
    _deviceInfoProvider.addListener(() {
      _deviceData = _deviceInfoProvider.deviceData;
    });
    localAuthProvider = LocalAuthenticationProvider(_onError);
    localAuthProvider.addListener(() {
      var isAuthenticated = localAuthProvider.isAuthenticated;
      if (isAuthenticated) {
        _refreshSession();
      }
    });
      @override
  void dispose() {
    if (_timer != null) _timer?.cancel();
    _connectivitySubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _deviceInfoProvider.dispose();
    _phoneController.removeListener(_verify);
    _passwordController.removeListener(_verify);
    _phoneController.dispose();
    _passwordController.dispose();
    _nodeText1.dispose();
    _nodeText2.dispose();
    super.dispose();
  }

  void _verify() {
    final String phone = _phoneController.text;
    final String password = _passwordController.text;
    bool clickable = true;
    if (phone.isEmpty ||
        phone.length < 11 ||
        HelperUtils.isInvalidPhoneNumber(phone)) {
      clickable = false;
    }
    if (phone.length == 11 && HelperUtils.isInvalidPhoneNumber(phone)) {
      clickable = false;
      showSnackBar('Invalid Phone number!!!');
    }

    if (password.isEmpty ||
        password.length <
            6     if (mounted && clickable != _clickable) {
      setState(() {
        _clickable = clickable;
        _nodeText1.unfocus();
        _nodeText2.unfocus();
      });
    }
  }

  void _login() async {
    SpUtil.putString(Constant.phone, _phoneController.text);
    var deviceId =
        (SpUtil.getString(Constant.fcmDeviceId) != '' &&
            SpUtil.getString(Constant.fcmDeviceId) != null)
        ? SpUtil.getString(Constant.fcmDeviceId)
        : _deviceData![DeviceInfoProvider.deviceId];
    var result = await presenter.userLogin(
      _phoneController.text,
      _passwordController.text,
      deviceId,
      _deviceData?[DeviceInfoProvider.deviceName] ?? '',
      _deviceData?[DeviceInfoProvider.deviceVersion] ?? '',
      _connectionStatus ?? '',
      position?.latitude.toString() ?? '',
      position?.longitude.toString() ?? '',
      (code, msg) {
        if (code == ExceptionHandler.device_changed) {
          SpUtil.putString(Constant.password, _passwordController.text);
          NavigatorUtils.push(context, AuthRouter.changeDevice);
        }
      },
    );

    if (result != null) {
      _saveTokens(result);
    }
  }

  void _saveTokens(TokenViewModel result) {
    SpUtil.putString(Constant.accessToken, result.token ?? '');
    SpUtil.putString(Constant.refreshToken, result.refreshToken ?? '');
    SpUtil.putString(Constant.accessTokenExpiry, result.expiryTime.toString());
    NavigatorUtils.push(context, Routes.home, replace: true, clearStack: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: MyScrollView(
          keyboardConfig: Utils.getKeyboardActionsConfig(context, <FocusNode>[
            _nodeText1,
            _nodeText2,
          ]),
          padding: const EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0),
          children: _buildBody,
        ),
      ),
    );
  }

  List<Widget> get _buildBody => [
    Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * .1,
        bottom: MediaQuery.of(context).size.height * .1,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          children: [Image.asset('assets/images/logo.png', scale: 6)],
        ),
      ),
    ),
    Gaps.vGap24,
    Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 32.0),
      child: MyTextField(
        key: const Key('phone'),
        iconName: 'phone',
        focusNode: _nodeText1,
        controller: _phoneController,
        showCursor: _nodeText1.hasFocus,
        maxLength: 11,
        keyboardType: TextInputType.phone,
        hintText: AppLocalizations.of(context)!.inputPhoneHint,
        labelText: AppLocalizations.of(context)!.inputPhoneHint,
      ),
    ),
    Gaps.vGap8,
    Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 32.0),
      child: MyTextField(
        key: const Key('password'),
        keyName: 'password',
        iconName: 'password',
        focusNode: _nodeText2,
        showCursor: _nodeText2.hasFocus,
        isInputPwd: true,
        controller: _passwordController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        hintText: AppLocalizations.of(context)!.inputPINHint,
        labelText: AppLocalizations.of(context)!.inputPINHint,
      ),
    ),
    Gaps.vGap24,
    Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 32.0),
      child: MyButton(
        key: const Key('login'),
        onPressed: _clickable ? _login : null,
        text: AppLocalizations.of(context)!.login,
      ),
    ),
    Gaps.vGap24,
    Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: TextButton(
        key: const Key('touchLogin'),
        onPressed: _authenticateUserLocally,
        child: Text(
          AppLocalizations.of(context)!.touchLogin,
          style: TextStyle(color: Colours.app_main),
        ),
      ),
    ),
    Gaps.vGap16,
    Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 32.0),
      child: Container(
        height: MediaQuery.of(context).size.height * .04,
        alignment: Alignment.centerLeft,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: Colours.app_main.withOpacity(0.5),
          onTap: _forgetEnable
              ? () {
                  setState(() {
                    _forgetEnable = false;
                    NavigatorUtils.push(
                      context,
                      AuthRouter.forgetPasswordConfirmPage,
                    );
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setState(() {
                        _forgetEnable = true;
                      });
                    });
                  });
                }
              : () {},
          child: Text(
            AppLocalizations.of(context)!.forgotPINLink,
            key: const Key('forgotPassword'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
    ),
    Gaps.vGap8,
    Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 32.0),
      child: Container(
        height: MediaQuery.of(context).size.height * .10,
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          splashColor: Colours.app_main.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context)!.noAccountRegister + ' ',
                  key: const Key('noAccountRegister'),
                ),
                Text(
                  AppLocalizations.of(context)!.signUp,
                  key: const Key('signUp'),
                  style: TextStyle(color: Colours.app_main),
                ),
              ],
            ),
          ),
          onTap: () => _showSignUpPopUp(),
        ),
      ),
    ),
  ];

  void _showSignUpPopUp() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: false,
      builder: (_) => LoginSignUpPopPage(),
    );
  }

  @override
  LoginPagePresenter createPresenter() {
    return LoginPagePresenter();
  }

  @override
  bool get wantKeepAlive => true;

  void _refreshSession() async {
    var refreshToken = SpUtil.getString(Constant.refreshToken);
    var deviceId = SpUtil.getString(Constant.fcmDeviceId) != ''
        ? SpUtil.getString(Constant.fcmDeviceId)
        : _deviceData![DeviceInfoProvider.deviceId];
    var refreshSessionResult = await presenter.refreshSession(
      refreshToken!,
      deviceId,
    );
    if (refreshSessionResult != null) {
      _saveTokens(refreshSessionResult);
    }
  }

  void _authenticateUserLocally() {
    String? refreshToken = SpUtil.getString(Constant.refreshToken);
    if (refreshToken?.isNotEmpty ?? false) {
      _canRefreshSession = true;
    }
    if (refreshToken?.isEmpty ?? false) {
      _canRefreshSession = false;
      showSnackBar(
        'For first time login, please use your PIN code. Thank you.',
      );
    }
    if (_canRefreshSession) {
      localAuthProvider.authenticateUser(context);
    }
  }

  void _onError(String message) {
    showToast(AppLocalizations.of(context)!.oneTouchAuthNotEnabled);
  }

  Future<void> _initConnectivity() async {
    ConnectivityResult? result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {}
    if (!mounted) {
      return Future.value(null);
    }
    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult? result) async {
    var newResult = await result;
    switch (newResult) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        break;
      case ConnectivityResult.none:
        newResult = await _connectivity.checkConnectivity();
        if (newResult == ConnectivityResult.none) {
          showSnackBar(
            'Please check your internet connection',
            isDismissable: true,
          );
        }
        break;
      default:
        showSnackBar('Failed to get connectivity', isDismissable: true);
        break;
    }
  }

  Future<void> _initNetworkInfo() async {
    String? wifiIPv4;

        try {
      wifiIPv4 = await _networkInfo.getWifiIP();
    } on PlatformException catch (e) {
      developer.log('Failed to get Wifi IPv4', error: e);
      wifiIPv4 = 'Failed to get Wifi IPv4';
    }

        setState(() {
      _connectionStatus = wifiIPv4 ?? '';
    });
    SpUtil.putString(Constant.ipAddress, _connectionStatus ?? '');
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    position = await _geolocatorPlatform.getCurrentPosition();

    SpUtil.putString(Constant.latitute, position?.latitude.toString() ?? '');
    SpUtil.putString(Constant.longititue, position?.longitude.toString() ?? '');
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }
}
