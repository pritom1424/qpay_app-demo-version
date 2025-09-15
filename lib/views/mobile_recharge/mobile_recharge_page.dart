import 'package:flutter/material.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/net/contract/account_balance_vm.dart';
import 'package:qpay/net/contract/bill_vendor_vm.dart';
import 'package:qpay/net/contract/custom_contact.dart';
import 'package:qpay/net/contract/linked_account_vm.dart';
import 'package:qpay/net/contract/transaction_fee_vm.dart';
import 'package:qpay/net/contract/transaction_vm.dart';
import 'package:qpay/net/contract/transactions_category_vm.dart';
import 'package:qpay/providers/account_selection_listener.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/dashboard_router.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/static_data/transaction_type.dart';
import 'package:qpay/utils/helper_utils.dart';
import 'package:qpay/utils/utils.dart';
import 'package:qpay/views/home/accounts/card_selector_page.dart';
import 'package:qpay/views/mobile_recharge/mobile_recharge_iview.dart';
import 'package:qpay/views/mobile_recharge/mobile_recharge_presenter.dart';
import 'package:qpay/widgets/account_selector.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/my_dialog.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/number_formatter_two_decimal.dart';
import 'package:qpay/widgets/text_field.dart';

import 'mobile_recharge_confirmation_page.dart';

class MobileRechargePage extends StatefulWidget {
  @override
  _MobileRechargePageState createState() => _MobileRechargePageState();
}

class _MobileRechargePageState extends State<MobileRechargePage>
    with
        BasePageMixin<MobileRechargePage, MobileRechargePresenter>,
        AutomaticKeepAliveClientMixin<MobileRechargePage>
    implements MobileRechargeIMvpView {
  var accountSelectionListener = TransactionAccountSelectionListener();
  LinkedAccountViewModel? _selectedAccount;
  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
      if (phone.isNotEmpty && !_isOperatorChangedByUser) {
      var _mobileOperator =
          _billVendorList[HelperUtils.defineOperatorFrom(phone)];
      if (mounted) {
        setState(() {
          if (_mobileOperator != _selectedOperator) {
            _selectedOperator = _mobileOperator;
            onOperatorChange(_mobileOperator);
          }
        });
      }
      if (_mobileOperator.id == 0) {
        clickable = false;
      }
    }
    if (phone.length == 11 && HelperUtils.isInvalidPhoneNumber(phone)) {
      clickable = false;
      _selectedOperator = _billVendorList.first;
      _connectionTypeList = <ConnectionTypes>[];
      _connectionTypeList.add(ConnectionTypes(id: 0, name: "Connection Type"));
      showSnackBar('Please enter a valid mobile number. Thank you.');
    }
    if (simType == 0) {
      clickable = false;
    }
    if (amountString.isEmpty) {
      clickable = false;
      newEnable = false;
    }
    if (amountString.isNotEmpty) {
      var amount = double.parse(amountString);
      if (_selectedSimType!.name == 'Prepaid') {
        if (amount < 20 || amount > 1000) {
          clickable = false;
          newEnable = false;
        }
      }
      if (_selectedSimType!.name == 'PostPaid') {
        if (amount < 20 || amount > 2000) {
          clickable = false;
          newEnable = false;
        }
      }
    }

    if (_selectedAccount!.id == -100) {
      if (remarks.isEmpty) clickable = false;
    }

    if (mounted) {
      if (newEnable != _newEnable) {
        setState(() {
          _newEnable = newEnable;
        });
      }

            if (clickable != _clickable) {
        setState(() {
          _clickable = clickable;
          _nodeText1.unfocus();
          _nodeText3.unfocus();
          _nodeText4.unfocus();
        });
      }
    }
  }

  Future<bool?> showConfirmation(
    String phone,
    double amount,
    int mobileOperator,
    int simType,
    double feeAmount,
    double vatAmount,
    String purpose,
    String cvv,
    bool isOtpRequired,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MobileRechargeConfirmationPage(
            phone,
            amount,
            mobileOperator,
            simType,
            feeAmount,
            vatAmount,
            AccountSelector(
              "From",
              _selectedAccount ?? LinkedAccountViewModel(),
              isEnabled: false,
            ),
            AccountSelector(
              "To",
              LinkedAccountViewModel(
                accountNumberMasked: _phoneController.text,
                accountHolderName:
                    _contactName ?? _selectedOperator?.name ?? '',
                instituteName: _selectedOperator?.name ?? '',
              ),
              isEnabled: false,
            ),
            _selectedAccount ?? LinkedAccountViewModel(),
            purpose,
            _contactName ?? '',
            _selectedOperator?.name ?? '',
            cvv,
            isOtpRequired,
          );
        },
      ),
    );
    _transaction = result != null ? result : null;
    if (_transaction?.transactionStatus != 'Declined') {
      NavigatorUtils.goBack(context);
      return true;
    } else {
      _phoneController.text = '';
      _amountController.text = '';
      _purposeController.text = '';
      _selectedOperator?.id = 0;
      _selectedSimType?.id = 0;
      _selectedAccount = null;
      return false;
    }
  }

  void _selectAccount() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: false,
      builder: (_) => CardsSelectorPage(Constant.transactionAccountSelector),
    );
  }

  onOperatorChange(BillVendorViewModel? operator) {
    if (mounted) {
      setState(() {
        _isOperatorChangedByUser = true;
        _selectedOperator = operator;
        if (_selectedOperator!.id != 0) {
          _connectionTypeList = operator!.connectionTypes!;
          _selectedSimType = _connectionTypeList.first;
        } else {
          _connectionTypeList = <ConnectionTypes>[];
          _connectionTypeList.add(
            ConnectionTypes(id: 0, name: "Connection Type"),
          );
          _selectedSimType = _connectionTypeList.first;
        }
      });
    }
  }

  onSimTypeChange(ConnectionTypes? simType) {
    if (mounted) {
      setState(() {
        _selectedSimType = simType;
      });
    }
  }

  @override
  MobileRechargePresenter createPresenter() => MobileRechargePresenter();

  @override
  bool get wantKeepAlive => true;

  Future<void> _pickContacts() async {
    final result = await NavigatorUtils.pushAwait(
      context,
      DashboardRouter.contactSelectPage,
    );
    CustomContact? _customContact = result;
    _contactName = _customContact?.name;
    _phoneController.text =
        HelperUtils.getPhoneNumberOnly(_customContact?.phone) ?? '';
    if (_phoneController.text != "") {
      var _mobileOperator =
          _billVendorList[HelperUtils.defineOperatorFrom(
            _phoneController.text,
          )];
      if (mounted) {
        setState(() {
          if (_mobileOperator != _selectedOperator) {
            _selectedOperator = _mobileOperator;
            onOperatorChange(_mobileOperator);
          }
        });
      }
      _nodeText1.requestFocus();
    }
  }

  void _onAccountSelected() {
    var account = accountSelectionListener.selectedAccount;
    if (mounted && account != null) {
      setState(() {
        _selectedAccount = accountSelectionListener.selectedAccount;
        _verify();
      });
    }
  }

  @override
  void setVendorList(List<BillVendorViewModel> vendorList) {
    if (mounted) {
      setState(() {
        _billVendorList.addAll(vendorList);
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

  Future<bool> _showProminantAlert() {
    var result = false;
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
              'Qpay Bangladesh collects and stores your contacts data to enable mobile recharge easy when the app in use.',
              textAlign: TextAlign.center,
            ),
          ),
          onBackPressed: () async {
            NavigatorUtils.goBack(context);
            await Future.delayed(Duration(milliseconds: 10));
            result = false;
          },
          onPressed: () async {
            NavigatorUtils.goBack(context);
            _pickContacts();
            await Future.delayed(Duration(milliseconds: 10));
            result = true;
          },
        );
      },
    );
    return Future<bool>.value(result);
  }
}
