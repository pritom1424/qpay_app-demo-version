import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/auth_router.dart';
import 'package:qpay/utils/toast.dart';
import 'package:qpay/views/settings/settings_iview.dart';
import 'package:qpay/views/settings/settings_page_presenter.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/text_field.dart';

class DeleteAccountPage extends StatefulWidget {
  final String reason;
  const DeleteAccountPage({super.key, required this.reason});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage>
    with BasePageMixin<DeleteAccountPage, SettingsPagePresenter>
    implements SettingsIMvpView {
  final FocusNode _nodeText1 = FocusNode();
  final _textcontroller = TextEditingController();

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
          "No. Once deleted, your account can't be restored. You'll need to create a new account to use QPay app again.",
    },
  ];

  List<String> pointTexts = [
    "• Identity details",
    "• Contact information",
    "• Account credentials",
    "• Verification documents",
    "• Transaction history",
    "• Device data",
    "• App usage logs",
    "• Location information",
  ];
  String deleteText = 'delete my account';
  bool _clickable = false;
  @override
  void dispose() {
    _textcontroller.dispose();
    _nodeText1.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _textcontroller.addListener(_verify);
    print("entered next page");
    print(widget.reason);

    super.initState();
  }

  void _verify() {
    final String inputText = _textcontroller.text.trim().toLowerCase();
    final String selectedText = deleteText.trim().toLowerCase();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(centerTitle: "Delete Qpay Account"),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            alignment: Alignment.center,
            /*     decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5))), */
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      CupertinoIcons.delete,
                      size: 35,
                      color: Colours.app_main,
                    ),
                  ),
                ),
                /*  Image.asset(
                "assets/images/logo.png",
                scale: 8,
              ), */
                Gaps.vGap24,
                Text(
                  "Are you sure you want to delete your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimens.font_sp20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Gaps.vGap24,
                Text(
                  "This action is permanent and cannot be undone",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimens.font_sp18,
                    color: Colors.grey,
                  ),
                ),
                Gaps.vGap16,
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colours.app_main.withAlpha((0.2 * 255).round()),
                    border: Border.all(color: Colours.app_main, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Gaps.vGap8,
                      ListTile(
                        leading: Icon(Icons.warning_amber),
                        title: Text("Here's what will happen:"),
                        iconColor: const Color.fromARGB(255, 228, 136, 8),
                        horizontalTitleGap: 10,
                        contentPadding: EdgeInsets.all(0),
                        titleTextStyle: TextStyle(
                          color: const Color.fromARGB(255, 141, 55, 4),
                          fontWeight: FontWeight.bold,
                          fontSize: Dimens.font_sp18,
                        ),
                      ),
                      Gaps.vGap5,
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
                        child: Text(
                          "you will permenanently lose access to your account and all associated data, including:",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: Dimens.font_sp14,
                            color: const Color.fromARGB(255, 141, 55, 4),
                          ),
                        ),
                      ),
                      Gaps.vGap16,
                      Container(
                        padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: List.generate(
                            pointTexts.length,
                            (ind) => Text(
                              pointTexts[ind],
                              style: TextStyle(
                                fontSize: Dimens.font_sp14,
                                color: const Color.fromARGB(255, 141, 55, 4),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Gaps.vGap16,
                    ],
                  ),
                ),
                Gaps.vGap24,
                Text(
                  "To confirm, please type 'DELETE MY ACCOUNT'",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: Dimens.font_sp14,
                  ),
                ),
                Gaps.vGap24,
                MyTextField(
                  iconName: null,
                  focusNode: _nodeText1,
                  isInputPwd: false,
                  controller: _textcontroller,
                  isIconShow: false,
                  keyboardType: TextInputType.text,
                  hintText: "DELETE MY ACCOUNT",
                ),

                Gaps.vGap24,
                Container(
                  height: ScreenUtil.getScreenH(context) * 0.07,
                  child: MyButton(
                    onPressed: _clickable ? deleteAccountRequest : null,
                    text: "Delete my account",
                  ),
                ),

                Gaps.vGap15,
                Card(
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Frequently Asked Questions",
                          style: TextStyle(
                            fontSize: Dimens.font_sp20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(faqData.length, (ind) {
                            return ExpansionTile(
                              clipBehavior: Clip.none,
                              backgroundColor: Colors.transparent,
                              collapsedBackgroundColor: Colors.transparent,
                              shape: Border.all(width: 0),
                              collapsedShape: Border.all(
                                width: 0,
                                color: Colors.transparent,
                              ),
                              childrenPadding: EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              expandedAlignment: Alignment.centerLeft,
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.start,
                              title: Text(faqData[ind]['q']!),
                              children: [Text(faqData[ind]['a']!)],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void deleteAccountRequest() async {
    var response = await presenter.accountDeleteRequest();
    if (response) {
      Toast.show(AppLocalizations.of(context)!.accountDeletedSuccessfully);
      _logOut();
    }
  }

  void _logOut() async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AuthRouter.loginPage,
      (Route<dynamic> route) => false,
    );
  }

  @override
  SettingsPagePresenter createPresenter() => SettingsPagePresenter();
}
