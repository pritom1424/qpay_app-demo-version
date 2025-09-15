import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/providers/dashboard_provider.dart';
import 'package:qpay/providers/home_provider.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/auth_router.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/routers/home_router.dart';
import 'package:qpay/static_data/cached_data_holder.dart';
import 'package:qpay/utils/toast.dart';
import 'package:qpay/views/settings/settings_iview.dart';
import 'package:qpay/views/settings/settings_page_presenter.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/text_field.dart';

class RestoreAccountPage extends StatefulWidget {
  const RestoreAccountPage({super.key});

  @override
  State<RestoreAccountPage> createState() => _RestoreAccountPageState();
}

class _RestoreAccountPageState extends State<RestoreAccountPage>
    with
        BasePageMixin<RestoreAccountPage, SettingsPagePresenter>,
        AutomaticKeepAliveClientMixin<RestoreAccountPage>
    implements SettingsIMvpView {
  final provider = DashboardProvider();
  bool isClicked = false;
  final _textcontroller = TextEditingController();
  final FocusNode _nodeText1 = FocusNode();
  String restoreText = 'restore my account';
  bool _clickable = false;
  var faqData = [
    {
      "q": "What happens when my account is deleted?",
      "a":
          "Your account and personal data will be removed from active systems. Some financial records may be kept securely as required by law. You won't be able to log in or use QPay services.",
    },
    {
      "q": "How long does the deletion process take?",
      "a":
          "Up to 48 hours. You can cancel the request anytime before it's completed.",
    },
    {
      "q": "Can I reactivate my account after deletion?",
      "a":
          "No. Once deleted, your account can't be restored. You'll need to create a new one to use QPay again.",
    },
  ];

  @override
  void initState() {
    _textcontroller.addListener(_verify);
    super.initState();
  }

  @override
  void dispose() {
    _textcontroller.dispose();
    _nodeText1.dispose();
    super.dispose();
  }

  void _verify() {
    final String inputText = _textcontroller.text.trim().toLowerCase();
    final String selectedText = restoreText.trim().toLowerCase();
    bool clickable = false;
    if (selectedText == inputText) {
      clickable = true;
    }

    if (mounted && clickable != _clickable) {
      setState(() {
        _clickable = clickable;
      });
    }
  }

  _startLiveChat() {
    NavigatorUtils.push(context, HomeRouter.supportChat);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          isBack: !isClicked,
          centerTitle: "Restore Qpay Account",
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colours.app_main,
          onPressed: () {
            _startLiveChat();
          },
          child: Icon(Icons.chat),
        ),
        body: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Divider(),
                Gaps.vGap24,
                Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colours.app_main.withAlpha(
                      (0.2 * 255).round(),
                    ),
                    child: Icon(
                      Icons.hourglass_empty,
                      size: 35,
                      color: Colours.app_main,
                    ),
                  ),
                ),
                    var response = await presenter.rawApiCancelCall();
    if (response == 200) {
      provider.user!.isPendingClosure = false;
      Toast.show(
        (response == 200)
            ? AppLocalizations.of(context)!.cancelAccountDeletionRequest
            : 'request failed',
      );
      if (response == 200) {
        setState(() {
          isClicked = true;
        });
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      }
    }
  }

    @override
  SettingsPagePresenter createPresenter() => SettingsPagePresenter();

  @override
  bool get wantKeepAlive => true;
}
