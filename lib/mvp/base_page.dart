import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:qpay/res/colors.dart';
import 'package:qpay/res/gaps.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/services/flushbar_manager.dart';
import 'package:qpay/utils/log_utils.dart';
import 'package:qpay/utils/toast.dart';
import 'package:qpay/utils/utils.dart';
import 'package:qpay/widgets/my_dialog.dart';
import 'package:qpay/widgets/progress_dialog.dart';
import '../localization/app_localizations.dart';
import 'base_presenter.dart';
import 'mvps.dart';

mixin BasePageMixin<T extends StatefulWidget, P extends BasePresenter>
    on State<T> implements IMvpView {
  late P presenter;

  P createPresenter();

  @override
  BuildContext getContext() {
    return context;
  }

  @override
  void closeProgress() {
    if (mounted && _isShowDialog) {
      _isShowDialog = false;
      NavigatorUtils.goBack(context);
    }
  }

  bool _isShowDialog = false;

  @override
  void showProgress() {
    if (mounted && !_isShowDialog) {
      _isShowDialog = true;
      try {
        showTransparentDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return WillPopScope(
              onWillPop: () async {
                _isShowDialog = false;
                return Future.value(true);
              },
              child: buildProgress(),
            );
          },
        );
      } catch (e) {}
    }
  }

  @override
  void showToast(String? string, {int duration = 4}) {
    Toast.show(string ?? '', duration: duration * 1000);
  }

  /*  @override
  void showSnackBar(String? msg, {bool isDismissable = true}) {
    final message =
        msg?.trim().isEmpty ?? true ? 'Something went wrong' : msg!.trim();

    final flushbar = Flushbar(
      message: message,
      duration: Duration(seconds: 5),
      isDismissible: isDismissable,
      showProgressIndicator: false,
      flushbarPosition: FlushbarPosition.TOP,
      progressIndicatorBackgroundColor: Colors.red[100],
      mainButton: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IconButton(
          onPressed: () {
            FlushbarManager.dismiss(); // Dismiss via manager
          },
          icon: Icon(
            Icons.cancel,
            size: 32,
            color: Colours.app_main,
          ),
        ),
      ),
      userInputForm: Form(
        canPop: false,
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Gaps.hGap4,
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: IconButton(
                  onPressed: () {
                    FlushbarManager.dismiss();
                  },
                  icon: Icon(
                    Icons.cancel,
                    size: 30,
                    color: Colours.app_main,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    FlushbarManager.showFlushbar(flushbar, context);
  } */
  @override
  void showSnackBar(String? msg, {bool isDismissable = true}) {
    Flushbar(
      message: msg ?? 'There is something goes wrong',
      duration: Duration(seconds: 5),
      isDismissible: isDismissable,
      showProgressIndicator: false,
      flushbarPosition: FlushbarPosition.TOP,
      progressIndicatorBackgroundColor: Colors.red[100],
      mainButton: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IconButton(
          onPressed: () {
            NavigatorUtils.goBack(context);
          },
          icon: Icon(
            Icons.cancel,
            size: 32,
            color: Colours.app_main,
          ),
        ),
      ),
      userInputForm: Form(
        child: Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(
              msg?.trim().isEmpty ?? true
                  ? 'Something went wrong'
                  : msg!.trim(),
              style: TextStyle(color: Colors.white),
            )),
            Gaps.hGap4,
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: IconButton(
                onPressed: () {
                  NavigatorUtils.goBack(context);
                },
                icon: Icon(
                  Icons.cancel,
                  size: 30,
                  color: Colours.app_main,
                ),
              ),
            ),
          ],
        )),
        canPop: false,
      ),
    )..show(context);
  }

  @override
  void showErrorDialog(String? msg) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)!.error,
            style: TextStyle(color: Colours.app_main),
          ),
          content: SingleChildScrollView(
            child: Text(msg ?? ''),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.okay,
                style: TextStyle(color: Colours.app_main),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void showSuccessDialog(String? msg) {
    showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Success',
            style: TextStyle(color: Colours.app_main),
          ),
          content: SingleChildScrollView(
            child: Text(msg ?? ''),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.okay,
                style: TextStyle(color: Colours.app_main),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildProgress() => ProgressDialog(hintText: 'Loading');

  @override
  void didChangeDependencies() {
    presenter.didChangeDependencies();
    Log.d('$T ==> didChangeDependencies');
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    presenter.dispose();
    Log.d('$T ==> dispose');
    super.dispose();
  }

  @override
  void deactivate() {
    presenter.deactivate();
    Log.d('$T ==> deactivate');
    super.deactivate();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    presenter.didUpdateWidgets<T>(oldWidget);
    Log.d('$T ==> didUpdateWidgets');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    Log.d('$T ==> initState');
    presenter = createPresenter();
    presenter.view = this;
    presenter.initState();
    super.initState();
  }
}
