import 'package:flutter/material.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/net/contract/linked_account_vm.dart';
import 'package:qpay/providers/dashboard_provider.dart';
import 'package:qpay/utils/card_utils.dart';
import 'package:qpay/widgets/card_background_widget.dart';

class AccountsCustomContainer extends StatelessWidget {
  final List<LinkedAccountViewModel> _accounts;
  final Function(LinkedAccountViewModel) onSelect;
  final provider = DashboardProvider();

  AccountsCustomContainer(this._accounts, this.onSelect);

  @override
  Widget build(BuildContext context) {
    if (_accounts.isNotEmpty) {
      return Container(
        child: ListView.builder(
            itemCount: _accounts.length,
            itemBuilder: (context, index) {
              return Transform.scale(
                scale: .95,
                child: Column(
                  children: [
                    GestureDetector(
                      child: CardBackgroudView(
                          context: context,
                          cardType: CardUtils.getCardTypeFrmNumber(
                              _accounts[index].accountNumberMasked ??
                                  ''.trim()),
                          cardIssuedBankImage: _accounts[index].imageUrl,
                          cardIssuedBank: _accounts[index].instituteName,
                          cardNumber: _accounts[index].accountNumberMasked,
                          cardHolder: _accounts[index].accountHolderName,
                          cardExpiration: _accounts[index].expiryDate),
                      onTap: () {
                        onSelect(_accounts[index]);
                      },
                    ),
                  ],
                ),
              );
            }),
      );
    }
    return Container(
      child: ListView.builder(
          itemCount: _accounts.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(AppLocalizations.of(context)!.noLinkedAccount),
            );
          }),
    );
  }
}
