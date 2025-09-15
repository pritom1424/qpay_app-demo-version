import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/net/contract/account_balance_vm.dart';
import 'package:qpay/net/contract/linked_account_vm.dart';
import 'package:qpay/net/contract/transaction_fee_vm.dart';
import 'package:qpay/net/contract/transaction_vm.dart';
import 'package:qpay/net/contract/transactions_category_vm.dart';
import 'package:qpay/providers/account_selection_listener.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/static_data/transaction_type.dart';
import 'package:qpay/utils/utils.dart';
import 'package:qpay/views/fund_transfer/fund_transfer_iview.dart';
import 'package:qpay/views/fund_transfer/fund_transfer_otp_page.dart';
import 'package:qpay/views/fund_transfer/fund_transfer_presenter.dart';
import 'package:qpay/views/home/accounts/all_account_selector_page.dart';
import 'package:qpay/views/home/accounts/card_selector_page.dart';
import 'package:qpay/views/shared/transaction_complete_page.dart';
import 'package:qpay/widgets/account_selector.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/my_dialog.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/number_formatter_two_decimal.dart';
import 'package:qpay/widgets/pin_input_dialog.dart';
import 'package:qpay/widgets/text_field.dart';
import 'package:qpay/widgets/transaction_description_widget.dart';

import 'fund_transfer_confirmation_page.dart';

class FundTransferPage extends StatefulWidget {
  @override
  _FundTransferPageState createState() => _FundTransferPageState();
}

class _FundTransferPageState extends State<FundTransferPage>
    with
        BasePageMixin<FundTransferPage, FundTransferPresenter>,
        AutomaticKeepAliveClientMixin<FundTransferPage>
    implements FundTransferIMvpView {
  var accountSelectionListener = TransactionAccountSelectionListener();
  LinkedAccountViewModel? _debitAccount;
  LinkedAccountViewModel? _creditAccount;
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  bool _clickable = false;
  bool _newEnable = false;
  TransactionViewModel? _transaction;
  String? _selectIntent;
  List<TransactionCategoryViewModel> _categoiesList =
      <TransactionCategoryViewModel>[];
  List<TransactionFeeViewModel> txnFees = <TransactionFeeViewModel>[];
  String feeAmount = '';
  String vatAmount = '';
  bool isOtpRequired = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_verify);
    _purposeController.addListener(_verify);
    accountSelectionListener.addListener(_onAccountSelected);
  }

  @override
  void dispose() {
    accountSelectionListener.removeListener(_onAccountSelected);
    _amountController.removeListener(_verify);
    _amountController.dispose();
    _purposeController.removeListener(_verify);
    _purposeController.dispose();
          if (clickable != _clickable) {
        setState(() {
          _clickable = clickable;
          _nodeText2.unfocus();
          _nodeText3.unfocus();
        });
      }
    }
  }

  void _onAccountSelected() {
    var account = accountSelectionListener.selectedAccount;
    if (mounted && account != null) {
      setState(() {
        if (_selectIntent == "debit") {
          _debitAccount = accountSelectionListener.selectedAccount;
        } else {
          _creditAccount = accountSelectionListener.selectedAccount;
        }
        _verify();
      });
    }
  }

  @override
  void setTransactionsCategory(
    List<TransactionCategoryViewModel> transactionCategoryViewModel,
  ) {
    if (mounted) {
      setState(() {
        _categoiesList = transactionCategoryViewModel;
      });
    }
  }

  void showBalanceDialoge(List<AccountBalanceViewModel> balanceResponse) {
    showElasticDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MyDialog(
          actionText: AppLocalizations.of(context)!.okay,
          cancelText: "",
          title: AppLocalizations.of(context)!.availBalance,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: balanceResponse.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gaps.vGap8,
                      Text(
                        "Available Balance:",
                        style: TextStyle(
                          color: Colours.text,
                          fontSize: 12.0,
                          fontFamily: 'SF',
                        ),
                      ),
                      Gaps.vGap8,
                      Text(
                        balanceResponse[index].currency! +
                            " " +
                            balanceResponse[index].balance!,
                        style: TextStyle(
                          color: Colours.app_main,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF',
                        ),
                      ),
                      Gaps.vGap8,
                    ],
                  ),
                );
              },
            ),
          ),
          onPressed: () {
            NavigatorUtils.goBack(context);
          },
        );
      },
    );
  }
}
