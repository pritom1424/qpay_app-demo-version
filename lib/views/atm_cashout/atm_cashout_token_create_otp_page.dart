import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/net/contract/account_linked_vm.dart';
import 'package:qpay/net/contract/bank_vm.dart';
import 'package:qpay/net/contract/cash_out_token_model.dart';
import 'package:qpay/net/contract/transaction_vm.dart';
import 'package:qpay/net/contract/transactions_category_vm.dart';
import 'package:qpay/providers/account_selection_listener.dart';
import 'package:qpay/res/colors.dart';
import 'package:qpay/res/gaps.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/utils/utils.dart';
import 'package:qpay/views/shared/transaction_complete_page.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/my_dialog.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/transaction_description_widget.dart';

import 'atm_cashout_iview.dart';
import 'atm_cashout_presenter.dart';

class AtmCashOutTokenCreateOtpPage extends StatefulWidget {
  final TransactionViewModel? _transaction;
  final TransactionAmountDescriptionWidget header;
  AtmCashOutTokenCreateOtpPage(this._transaction, this.header);

  @override
  _AtmCashOutTokenCreateOtpPageState createState() =>
      _AtmCashOutTokenCreateOtpPageState(_transaction, header);
}

class _AtmCashOutTokenCreateOtpPageState
    extends State<AtmCashOutTokenCreateOtpPage>
    with
        BasePageMixin<AtmCashOutTokenCreateOtpPage, AtmCashOutPresenter>,
        AutomaticKeepAliveClientMixin<AtmCashOutTokenCreateOtpPage>
    implements AtmCashOutIMvpView {
  TransactionViewModel? _transaction;
  TransactionAmountDescriptionWidget header;
  _AtmCashOutTokenCreateOtpPageState(this._transaction, this.header);
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(centerTitle: AppLocalizations.of(context)!.cashByCode),
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
                          AppLocalizations.of(context)!.insertOtp,
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
    ),
  ];
  void _onPinInserted(String pin) async {
    if (pin.isEmpty || pin.length < 6) {
      return;
    }
    var response = await presenter.confirmTransaction(
      _transaction?.transactionId ?? '',
      pin,
    );

    _transaction = response;
    if (_transaction?.transactionStatus == 'Declined') {
      _pinPutController.text = '';
      _pinPutFocusNode.requestFocus();
      _showErrorDialog(_transaction);
    } else {
      _onSuccess(_transaction);
    }
  }

  void _onSuccess(TransactionViewModel? transaction) {
    NavigatorUtils.goBackWithParams(context, transaction);
  }

  void _showErrorDialog(TransactionViewModel? transaction) {
    showElasticDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MyDialog(
          actionText: "",
          cancelText: AppLocalizations.of(context)!.tryAgain,
          title: transaction?.transactionStatus,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              transaction?.transactionDetails ??
                  AppLocalizations.of(context)!.notAvailable,
              textAlign: TextAlign.center,
            ),
          ),
          onBackPressed: () {
            NavigatorUtils.goBack(context);
            NavigatorUtils.goBackWithParams(context, transaction);
          },
        );
      },
    );
  }

  @override
  AtmCashOutPresenter createPresenter() {
    return AtmCashOutPresenter(false);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  String getAccountLinkType() => "bank";

  @override
  void setTokens(List<CashOutTokenViewModel> tokens) {}

  @override
  void setTransactionsCategory(
    List<TransactionCategoryViewModel> transactionCategoryViewModel,
  ) {}
}
