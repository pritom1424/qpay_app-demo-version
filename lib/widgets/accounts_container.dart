import 'package:flutter/material.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/net/contract/api_basic_vm.dart';
import 'package:qpay/net/contract/linked_account_vm.dart';
import 'package:qpay/res/colors.dart';
import 'package:qpay/res/dimens.dart';
import 'package:qpay/res/styles.dart';
import 'package:qpay/routers/dashboard_router.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/utils/card_utils.dart';
import 'package:qpay/utils/toast.dart';

import '../res/gaps.dart';
import '../views/home/accounts/accounts_page_presenter.dart';

class AccountsContainer extends StatelessWidget {
  final List<LinkedAccountViewModel> _accounts;
  final Function(LinkedAccountViewModel) onSelect;
  bool isBeneficiary;
  AccountsContainer(this._accounts, this.onSelect,{this.isBeneficiary = false});
  ApiBasicViewModel? _model;
  @override
  Widget build(BuildContext context) {
    if (_accounts.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(4.0),
        child: Stack(
          children: [
            ListView.builder(
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: getWalletIcon(_accounts[index].imageUrl??''),
                    title: Text(
                        _accounts[index].accountHolderName ?? '',style: TextStyle(color: Colours.text),),
                    dense: true,
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _accounts[index].accountNumberMasked??'',
                          style: TextStyles.textSize10,
                        ),
                        Gaps.hGap4,
                        Text(
                          _accounts[index].status??'',
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: Dimens.font_sp10,color: _accounts[index].status?.toLowerCase()=='active'?Colors.green:Colors.red),

                        ),
                      ],
                    ),
                    trailing: Text(
                      _accounts[index].productType != null
                          ? (_accounts[index].productType! ==
                          'PrepaidCard'
                          ? "Prepaid Card"
                          : _accounts[index].productType! == 'CreditCard'
                          ? "Credit Card"
                          : _accounts[index].productType! == 'DebitCard'
                          ? "Debit Card"
                          : _accounts[index].productType!)
                          :
                      _accounts[index].productType??'',
                      textAlign: TextAlign.end,
                    ),
                    onTap: () {
                      onSelect(_accounts[index]);
                    },
                  ),
                );
              }),
            Visibility(
              visible: isBeneficiary,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton.extended(
                    heroTag: null,
                    backgroundColor: Colours.app_main,
                    icon: Icon(Icons.add),
                    label: Text('Add Beneficiary'),
                    elevation: 5,
                    onPressed: ()async{
                      var result = await NavigatorUtils.pushAwait(context,DashboardRouter.addBeneficiary);
                      _model = result;
                      if(_model?.isSuccess??false){
                        NavigatorUtils.goBack(context);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      child: Stack(
        children: [
          ListView.builder(
              itemCount: _accounts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(AppLocalizations.of(context)!.noLinkedAccount),

                );
              }),
          Visibility(
            visible: isBeneficiary,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton.extended(
                  heroTag: null,
                  backgroundColor: Colours.app_main,
                  icon: Icon(Icons.add),
                  label: Text('Add Beneficiary'),
                  elevation: 5,
                  onPressed: ()async{
                    var result = await NavigatorUtils.pushAwait(context,DashboardRouter.addBeneficiary);
                    _model = result;
                    if(_model?.isSuccess??false){
                      NavigatorUtils.goBack(context);
                    }
                  },
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}

Widget? getWalletIcon(String image) {
  String img = image;
  Widget? widget;
  if (img != null && img.isNotEmpty ) {
    widget = Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        image: DecorationImage(
          image: NetworkImage(img),
          fit: BoxFit.scaleDown,
          scale: 1,
        ),
      ),
    );
  }
  return widget;
}