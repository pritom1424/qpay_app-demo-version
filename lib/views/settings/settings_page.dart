import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/providers/dashboard_provider.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/routers/home_router.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/my_scroll_view.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final provider = DashboardProvider();
    _deleteAccount() {
      NavigatorUtils.push(context, HomeRouter.deleteAccount);
    }

    _cancelDeleteAccount() async {
      await NavigatorUtils.push(context, HomeRouter.cancelDeleteAccount);
    }

    void _resetPassword() {
      NavigatorUtils.push(context, HomeRouter.resetPasswordPage);
    }

    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          centerTitle: AppLocalizations.of(context)!.settings,
        ),
        body: MyScrollView(
          padding: EdgeInsets.all(12),
          children: [
            settings_menu_tile(
                title: "Change your PIN",
                description:
                    "To change your PIN. you will need to provide old PIN and confirm new PIN",
                buttonText: AppLocalizations.of(context)!.resetPIN,
                onPressed: _resetPassword),
            /*  settings_menu_tile(
                title: "Sign out from all devices",
                description: "End all sessions by signing out all devices",
                buttonText: "Sign out from all devices",
                onPressed: () {}), */
            if (!provider.user!.isPendingClosure!)
              settings_menu_tile(
                  title: "Delete your account",
                  description:
                      "By deleting your account, you'll no longer be able to access any of your infos",
                  buttonText: "Delete account",
                  onPressed: _deleteAccount),
            if (provider.user!.isPendingClosure!)
              settings_menu_tile(
                  title: "Restore your account",
                  description:
                      "Account deletion is in progress! Do you want to cancel the account deletion request?",
                  buttonText: "Restore account",
                  onPressed: _cancelDeleteAccount),
          ],
        ),
      ),
    );
  }

  Widget settings_menu_tile(
      {String title = "",
      String description = "",
      String buttonText = "",
      void Function()? onPressed}) {
    return Container(
      padding: EdgeInsets.only(bottom: 15, top: 15),
      /*  decoration: BoxDecoration(
          border: BoxBorder.fromLTRB(
              bottom: BorderSide(width: 0.4, color: Colors.grey))), */
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: TextStyles.textBold26,
          ),
          Gaps.vGap10,
          Text(description),
          Gaps.vGap15,
          Gaps.vGap24,
          MyButton(
            onPressed: onPressed,
            text: buttonText,
          ),
          /* ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5))),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                      color: Colours.text),
                )), */
        ],
      ),
    );
  }
}
