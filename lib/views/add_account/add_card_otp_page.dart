import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/net/contract/account_linked_vm.dart';
import 'package:qpay/net/contract/api_basic_vm.dart';
import 'package:qpay/net/contract/bank_vm.dart';
import 'package:qpay/res/colors.dart';
import 'package:qpay/res/gaps.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/my_scroll_view.dart';

import 'link_account_iview.dart';
import 'link_account_presenter.dart';

class AddCardOTPPage extends StatefulWidget {
  final AccountLinkedViewModel? _accountLinkResponse;
  AddCardOTPPage(this._accountLinkResponse);

  @override
  _AddCardOTPPageState createState() =>
      _AddCardOTPPageState(_accountLinkResponse);
}

class _AddCardOTPPageState extends State<AddCardOTPPage>
    with
        BasePageMixin<AddCardOTPPage, LinkAccountPresenter>,
        AutomaticKeepAliveClientMixin<AddCardOTPPage>
    implements LinkAccountIMvpView {
  AccountLinkedViewModel? _accountLinkResponse;
  _AddCardOTPPageState(this._accountLinkResponse);
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  static const focusedBorderColor =
      Colours.app_main; //Color.fromRGBO(23, 171, 144, 1);
  static const fillColor = Color.fromRGBO(243, 246, 249, 0);
  static const borderColor = Color.fromRGBO(
    0,
    0,
    0,
    1,
  ); //Color.fromRGBO(23, 171, 144, 0.4);

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(centerTitle: AppLocalizations.of(context)!.addCard),
        body: MyScrollView(children: _buildBody()),
      ),
    );
  }

  List<Widget> _buildBody() => <Widget>[
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
                onCompleted: (String pin) => _onPinInserted(pin),
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
          ],
        ),
      ),
    ),
  ];
  void _onPinInserted(String pin) async {
    if (pin.isEmpty || pin.length < 6) {
      return;
    }
    var response = await presenter.confirmCardLink(
      _accountLinkResponse?.trackingId ?? '',
      pin,
    );

    NavigatorUtils.goBackWithParams(context, response);
  }

  @override
  LinkAccountPresenter createPresenter() {
    return LinkAccountPresenter();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  String getAccountLinkType() => "bank";

  @override
  void setBankList(List<BankViewModel> bankList) {
    if (mounted) {
      setState(() {});
    }
  }
}
