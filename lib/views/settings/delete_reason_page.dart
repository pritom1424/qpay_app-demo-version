import 'package:flutter/material.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/res/styles.dart';
import 'package:qpay/views/settings/delete_account_page.dart';
import 'package:qpay/widgets/app_bar.dart';
import 'package:qpay/widgets/my_button.dart';
import 'package:qpay/widgets/text_field.dart';

class DeleteReasonPage extends StatefulWidget {
  @override
  _DeleteReasonPageState createState() => _DeleteReasonPageState();
}

class _DeleteReasonPageState extends State<DeleteReasonPage> {
  String? _selectedReason;
  final TextEditingController _otherController = TextEditingController();
  final FocusNode _node = FocusNode();
  bool clickable = true;

  final List<String> reasons = [
    "Found a better app",
    "Privacy concerns",
    "Not useful anymore",
    "Other",
  ];

  void _next() async {
    String finalReason = _selectedReason == "Other"
        ? _otherController.text.trim()
        : _selectedReason!;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (ctx) => DeleteAccountPage(reason: finalReason),
      ),
    );
  }

  void _verify() {
    bool state = false;
    if (_selectedReason == "Other") {
      if (_otherController.text.trim().isEmpty) {
        state = false;
      } else {
        state = true;
      }
    } else {
      state = true;
    }

    setState(() {
      clickable = state;
    });
  }

  @override
  void initState() {
    super.initState();
    _otherController.addListener(_verify);
  }

  @override
  void dispose() {
    _node.dispose();
    _otherController.removeListener(_verify);
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(centerTitle: "Why are you leaving?"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "It's unfortunate that you have decided to delete your account with Qpay. "
                        "Your feedback is important to us, and we hope to improve and serve you better in the future.",
                        style: TextStyles.text16.copyWith(
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              Text(
                "Please select a reason for deleting your account:",
                style: TextStyles.textBold14,
              ),
              SizedBox(height: 20),

              ...reasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: _selectedReason,
                  onChanged: (val) {
                    setState(() {
                      if (val == "Other") {
                        clickable = false;
                      } else {
                        clickable = true;
                      }
                      _selectedReason = val;
                    });
                  },
                );
              }).toList(),

              if (_selectedReason == "Other") ...[
                MyTextField(
                  iconName: null,
                  isInputPwd: false,
                  isIconShow: false,
                  controller: _otherController,
                  focusNode: _node,
                  labelText: "Please specify",
                ),
                SizedBox(height: 20),
              ],

              MyButton(
                onPressed: (_selectedReason != null && clickable)
                    ? _next
                    : null,
                text: AppLocalizations.of(context)!.nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
