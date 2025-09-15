import 'package:collection/collection.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/net/contract/linked_account_vm.dart';
import 'package:qpay/providers/account_selection_listener.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/account_router.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/static_data/cached_data_holder.dart';
import 'package:qpay/utils/utils.dart';
import 'package:qpay/views/home/accounts/account_statement/account_statement_page.dart';
import 'package:qpay/views/home/accounts/account_transaction_quota/account_transaction_quota_page.dart';
import 'package:qpay/views/home/accounts/accounts_iview.dart';
import 'package:qpay/views/home/accounts/accounts_page_presenter.dart';
import 'package:qpay/widgets/account_custom_container.dart';
import 'package:qpay/widgets/beneficiaries_account_container.dart';
import 'package:qpay/widgets/my_dialog.dart';

import 'account_balance/account_balance_page.dart';

class AccountsPage extends StatefulWidget {
  @override
  _AccountsPageState createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage>
    with
        BasePageMixin<AccountsPage, AccountsPagePresenter>,
        AutomaticKeepAliveClientMixin<AccountsPage>
    implements AccountsIMvpView {
  List<LinkedAccountViewModel> _beneficiaries =
      <LinkedAccountViewModel>[];
  List<LinkedAccountViewModel> _cards = <LinkedAccountViewModel>[];
  final accountListLoader = CachedAllLinkedAccounts();

  @override
  void initState() {
    super.initState();
    accountListLoader.addListener(_reloadAccount);
  }

  @override
  void dispose() {
    accountListLoader.removeListener(_reloadAccount);
    super.dispose();
  }

  void _reloadAccount(){
    presenter.listLoad();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: DefaultTabController(
          length: 2,
          child: SafeArea(
            child: Scaffold(
                appBar: AppBar(
                  flexibleSpace: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TabBar(
                        labelColor: Colours.app_main,
                        indicatorColor:Colours.app_main,
                        indicatorSize: TabBarIndicatorSize.tab,
                        unselectedLabelColor: Colours.text_gray,
                        tabs: [
                          Tab(
                            text: AppLocalizations.of(context)!.ownCards,
                          ),
                          Tab(
                            text: AppLocalizations.of(context)!.beneficiaries,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                body: TabBarView(children: [
                  BeneficiariesAccountContainer(groupBy(_cards, (LinkedAccountViewModel x)=> x.status??'' ),groupBy(_cards, (LinkedAccountViewModel x)=> x.status??'').keys.toList(),_showOptions),
                  BeneficiariesAccountContainer( groupBy(_beneficiaries, (LinkedAccountViewModel x)=> x.financialAccountType??''),groupBy(_beneficiaries, (LinkedAccountViewModel x)=> x.financialAccountType??'').keys.toList(),_showBeneficiaryOptions),
                ])),
          ),
        ),
      ),
    );
  }

  @override
  AccountsPagePresenter createPresenter() {
    return AccountsPagePresenter();
  }

  @override
  bool get wantKeepAlive => false;

  @override
  void setAccounts(List<LinkedAccountViewModel> accounts) {
    if(mounted) {
      setState(() {
        _beneficiaries =
            accounts.where((element) => element.ownershipType == "Beneficiary")
                .toList();
        _cards = accounts.where((element) => element.isCard() && element.id !=-100 &&
            element.ownershipType == "Personal").toList();
      });
    }
  }

  _showOptions(LinkedAccountViewModel account) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return account.status?.toLowerCase()=='active'?
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:[
                Gaps.vGap8,
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    AppLocalizations.of(context)!.menuOptions.toUpperCase(),
                    style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                  ),
                ),
                Gaps.vGap8,
                Gaps.line,
                ListTile(
                   leading: new Icon(Icons.account_balance_wallet,color: Colours.app_main,),
                   title: new Text(
                     AppLocalizations.of(context)!.checkBalance.toUpperCase(),
                     style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                   ),
                   onTap: () => {
                     _accountBalance(account)

                   }),
                Column(
                  children: [
                    Gaps.vGap8,
                    ListTile(
                        leading: new Icon(Icons.account_balance_wallet,color: Colours.app_main,),
                        title: new Text(
                          AppLocalizations.of(context)!.transactionStatementHistory.toUpperCase(),
                          style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                        ),
                        onTap: () => {
                          _accountStatement(account)

                        }),
                  ],
                ),
                Visibility(
                  visible: account.productType == 'CreditCard' ,
                  child: Column(
                    children: [
                      Gaps.vGap8,
                      ListTile(
                          leading: new Icon(Icons.account_box,color: Colours.app_main,),
                          title: new Text(
                            AppLocalizations.of(context)!.statementDetails.toUpperCase(),
                            style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                          ),
                          onTap: () => {
                            _accountDetail(account)

                          }),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Gaps.vGap8,
                    ListTile(
                       leading: new Icon(Icons.assistant,color: Colours.app_main,),
                       title: new Text(
                         AppLocalizations.of(context)!.transactionControl.toUpperCase(),
                         style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                       ),
                       onTap: () => {
                         _accountTxnQuota(account)

                       }),
                  ],
                ),
                Gaps.vGap8,
                ListTile(
                    leading: new Icon(Icons.remove_circle_outline,color: Colours.app_main,),
                    title: new Text(
                      AppLocalizations.of(context)!.unlinkAccount.toUpperCase(),
                      style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                    ),
                    onTap: () => {
                      _unlinkAccount(account)
                    }),
              ],
            ),
          ):
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gaps.vGap8,
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    AppLocalizations.of(context)!.menuOptions.toUpperCase(),
                    style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                  ),
                ),
                Gaps.vGap8,
                Gaps.line,
                ListTile(
                    leading: new Icon(Icons.remove_circle_outline,color: Colours.app_main,),
                    title: new Text(
                      AppLocalizations.of(context)?.deleteAccount.toUpperCase()??'',
                      style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                    ),
                    onTap: () => {
                      _deleteInactiveAccount(account)
                    }),
              ],
            ),
          );
        });
  }

  _showBeneficiaryOptions(LinkedAccountViewModel account) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Gaps.vGap8,
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    AppLocalizations.of(context)!.menuOptions.toUpperCase(),
                    style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                  ),
                ),
                Gaps.vGap8,
                Gaps.line,
                new ListTile(
                    leading: Icon(Icons.remove_circle_outline,color: Colours.app_main,),
                    title: Text(
                      AppLocalizations.of(context)?.deleteAccount.toUpperCase()??'',
                      style: TextStyle(color: Colours.text,fontFamily: 'Inter',fontSize: 12,fontWeight: FontWeight.bold),
                    ),
                    onTap: () => {
                      _deleteBeneficiaryAccount(account)
                    }),
              ],
            ),
          );
        });
  }

  _unlinkAccount(LinkedAccountViewModel account) {
     NavigatorUtils.goBack(context);
     String accountType = account.financialAccountType!.toLowerCase()=='card'?'Card':account.financialAccountType!.toLowerCase()=='bankaccount'?'Account':'Beneficiary MFS';

     showElasticDialog(context: context,
        builder: (BuildContext context) {
          return MyDialog(
            actionText: AppLocalizations.of(context)!.confirm,
            cancelText: AppLocalizations.of(context)!.cancel,
            hiddenTitle: false,
            title: AppLocalizations.of(context)!.unlinkAccount.toUpperCase(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Are you sure you want to unlink this ${accountType.toLowerCase()}?",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter'),),
            ),
            onPressed: () async {
              NavigatorUtils.goBack(context);
             var response = await presenter.unlinkAccount(account);
             if(response!.isSuccess!) {

          _showAlert(
          'Congratulation', '$accountType unlinked successfully');
             }else{
               NavigatorUtils.goBack(context);
               _showAlert('Sorry', '$accountType unlinking was unsuccessful');
             }
            },
            onBackPressed:() {
              NavigatorUtils.goBack(context);
            },
          );
        });
  }

  _deleteInactiveAccount(LinkedAccountViewModel account) {
     NavigatorUtils.goBack(context);
     String accountType = account.financialAccountType!.toLowerCase()=='card'?'Card':account.financialAccountType!.toLowerCase()=='bankaccount'?'Account':'Beneficiary MFS';
    showElasticDialog(context: context,
        builder: (BuildContext context) {
          return MyDialog(
            actionText: AppLocalizations.of(context)!.confirm,
            cancelText: AppLocalizations.of(context)!.cancel,
            hiddenTitle: false,
            title: AppLocalizations.of(context)?.deleteAccount.toUpperCase(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Are you sure you want to delete this ${accountType.toLowerCase()}?",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter'),),
            ),
            onPressed: () async {
              NavigatorUtils.goBack(context);
             var response = await presenter.deleteAccount(account);
             if(response!.isSuccess!) {

          _showAlert(
          'Congratulation', '$accountType deleted successfully');
             }else{
               NavigatorUtils.goBack(context);
               _showAlert('Sorry', '$accountType deletion was unsuccessful');
             }
            },
            onBackPressed:() {
              NavigatorUtils.goBack(context);
            },
          );
        });
  }

  _deleteBeneficiaryAccount(LinkedAccountViewModel account) {
     NavigatorUtils.goBack(context);
     String accountType = account.financialAccountType?.toLowerCase()=='card'?'card':account.financialAccountType?.toLowerCase()=='bankaccount'?'account':'MFS';
    showElasticDialog(context: context,
        builder: (BuildContext context) {
          return MyDialog(
            actionText: AppLocalizations.of(context)!.confirm,
            cancelText: AppLocalizations.of(context)!.cancel,
            hiddenTitle: false,
            title: AppLocalizations.of(context)?.deleteAccount.toUpperCase(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Are you sure you want to delete this $accountType?",
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Inter'),),
            ),
            onPressed: () async {
              NavigatorUtils.goBack(context);
             var response = await presenter.deleteAccount(account);
             if(response!.isSuccess!) {

          _showAlert(
          'Congratulation', 'Beneficiary $accountType deleted successfully');
             }else{
               NavigatorUtils.goBack(context);
               _showAlert('Sorry', 'Beneficiary $accountType deletion was unsuccessful');
             }
            },
            onBackPressed:() {
              NavigatorUtils.goBack(context);
            },
          );
        });
  }

   _showAlert(String title,String message){
    showElasticDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return MyDialog(
            actionText: 'Okay',
            cancelText: '',
            title:title,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(message, textAlign: TextAlign.center,),
            ),
            onPressed: (){
              accountListLoader.reload();
              NavigatorUtils.goBack(context);
            },
          );
        });
  }

  _accountBalance(LinkedAccountViewModel account) {
    AccountSelectionListener().setAccount(account);
    NavigatorUtils.push(context, AccountRouters.accountBalance);
    }

  _accountStatement(LinkedAccountViewModel account) {
    StatementAccountSelectionListener().setAccount(account);
    NavigatorUtils.push(context, AccountRouters.accountStatement);
    }

  _accountDetail(LinkedAccountViewModel account) {
    AccountSelectionListener().setAccount(account);
    NavigatorUtils.push(context, AccountRouters.accountDetail);
    }


  _accountTxnQuota(LinkedAccountViewModel account) {
    AccountSelectionListener().setAccount(account);
    NavigatorUtils.push(context, AccountRouters.accountTxnQuota);
    }
}
