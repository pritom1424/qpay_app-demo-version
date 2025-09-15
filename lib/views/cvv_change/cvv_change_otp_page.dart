import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pinput/pinput.dart';
import 'package:qpay/net/contract/transactions_category_vm.dart';

import '../../localization/app_localizations.dart';
import '../../mvp/base_page.dart';
import '../../net/contract/transaction_vm.dart';
import '../../res/colors.dart';
import '../../res/gaps.dart';
import '../../routers/fluro_navigator.dart';
import '../../utils/utils.dart';
import '../../widgets/app_bar.dart';
import '../../widgets/my_dialog.dart';
import '../../widgets/my_scroll_view.dart';
import '../../widgets/transaction_description_widget.dart';
import 'cvv_change_iview.dart';
import 'cvv_change_presenter.dart';

class Cvv2ChangeOtpPage extends StatefulWidget{
  final TransactionViewModel? _transaction;
  final TransactionAmountDescriptionWidget header;


  Cvv2ChangeOtpPage(this._transaction, this.header);

  @override
  _Cvv2ChangeOtpPageState createState() => _Cvv2ChangeOtpPageState(_transaction,header);

}

class _Cvv2ChangeOtpPageState extends State<Cvv2ChangeOtpPage>
    with
        BasePageMixin<Cvv2ChangeOtpPage, Cvv2ChangePresenter>,
        AutomaticKeepAliveClientMixin<Cvv2ChangeOtpPage>
    implements Cvv2ChangeIMvpView{
  TransactionViewModel? _transaction;
  TransactionAmountDescriptionWidget header;

  _Cvv2ChangeOtpPageState(this._transaction, this.header);

  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  static const focusedBorderColor = Colours.app_main;//Color.fromRGBO(23, 171, 144, 1);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          centerTitle: AppLocalizations.of(context)!.changeCvv2,
        ),
        body:MyScrollView(
          children: _buildBody(),
        ),
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
                          height:MediaQuery.of(context).size.height*.15,
                          width: MediaQuery.of(context).size.width*.2,
                        ),
                      ),
                      Gaps.vGap8,
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          AppLocalizations.of(context)!.insertOtp,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0,fontFamily: 'Inter'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gaps.vGap8,
            widget.header ?? Container(),
            Gaps.vGap16,
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
    )
  ];

  void _onPinInserted(String pin) async {
    if (pin == null || pin.isEmpty || pin.length < 6) {
      return;
    }
    var response =
    await presenter.confirmTransaction(_transaction?.transactionId??'', pin);

    _transaction = response!;
    if (_transaction?.transactionStatus == 'Declined') {
      _pinPutController.text = '';
      _pinPutFocusNode.requestFocus();
      _showErrorDialog(_transaction);
    } else {
      _onSuccess(_transaction);
    }
    }

  void _onSuccess(TransactionViewModel? transaction) {
    NavigatorUtils.goBackWithParams(context,transaction);
  }

  void _showErrorDialog(TransactionViewModel? transaction) {
    showElasticDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return MyDialog(
            actionText: "",
            cancelText: AppLocalizations.of(context)!.tryAgain,
            title:transaction?.transactionStatus,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(transaction?.transactionDetails??AppLocalizations.of(context)!.notAvailable, textAlign: TextAlign.center,),
            ),
            onBackPressed:() {
              NavigatorUtils.goBack(context);
              NavigatorUtils.goBackWithParams(context,transaction);
            },
          );
        });
  }

  @override
  Cvv2ChangePresenter createPresenter() => Cvv2ChangePresenter();

  @override
  void setTransactionsCategory(List<TransactionCategoryViewModel> transactionCategoryViewModel) {}

  @override
  bool get wantKeepAlive => true;

}