import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qpay/net/contract/notification_count_vm.dart';
import 'package:qpay/net/contract/profile_vm.dart';
import 'package:qpay/routers/auth_router.dart';
import 'package:qpay/routers/home_router.dart';
import 'package:qpay/utils/utils.dart';
import 'package:qpay/views/home/dashboard/dashboard_presenter.dart';
import 'package:qpay/providers/dashboard_provider.dart';
import 'package:qpay/static_data/dashboard_data.dart';
import 'package:qpay/localization/app_localizations.dart';
import 'package:qpay/mvp/base_page.dart';
import 'package:qpay/res/resources.dart';
import 'package:qpay/routers/fluro_navigator.dart';
import 'package:qpay/utils/image_utils.dart';
import 'package:qpay/utils/theme_utils.dart';
import 'package:qpay/widgets/my_dialog.dart';
import 'package:qpay/widgets/my_scroll_view.dart';
import 'package:qpay/widgets/profile_error_widget.dart';
import 'package:qpay/widgets/load_image.dart';
import 'dashboard_iview.dart';
import '../../../routers/dashboard_router.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with
        BasePageMixin<DashboardPage, DashboardPagePresenter>,
        AutomaticKeepAliveClientMixin<DashboardPage>
    implements DashboardIMvpView {
  final titles = DashboardTitles();
  final images = DashboardImages();
  final provider = DashboardProvider();
  int _notificationCount = 0;
  bool? _isInComplete;
  bool scrollVisible = true;
  final List<String> offers = [
    "assets/images/dashboard/stkr_txn_to_bKash.png",
    "assets/images/dashboard/stkr_card_bill.png",
    "assets/images/dashboard/stkr_cash_by_code.png",
  ];
  bool isMainEnable = true;
  bool isOptionEnable = true;
  bool isNotificationEnable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preCacheImage();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _preCacheImage() {
    images.serviceImages.forEach((element) {
      precacheImage(ImageUtils.getAssetImage(element), context);
    });

    images.mainMenuImages.forEach((element) {
      precacheImage(ImageUtils.getAssetImage(element), context);
    });
  }

  void setDialVisible(bool value) {
    setState(() {
      scrollVisible = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colours.dashboard_bg,
        body: MyScrollView(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 135.5,
              decoration: new BoxDecoration(
                color: Colours.dashboard_top_bg,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.elliptical(
                    MediaQuery.of(context).size.width * .5,
                    85.0,
                  ),
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            bottom: 12.0,
                          ),
                          child: Image.asset(
                            "assets/images/logo_white.png",
                            scale: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: MediaQuery.of(context).size.width * .02,
                    child: InkWell(
                      onTap: isNotificationEnable
                          ? () {
                              if (mounted) {
                                setState(() {
                                  isNotificationEnable = false;
                                  NavigatorUtils.push(
                                    context,
                                    HomeRouter.notifications,
                                  );
                                  _notificationCount = 0;
                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () {
                                      setState(() {
                                        isNotificationEnable = true;
                                      });
                                    },
                                  );
                                });
                              }
                            }
                          : () {},
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Stack(
                          children: [
                            Image.asset(
                              "assets/images/dashboard/notification.png",
                              color: Colours.app_main,
                              scale: 3,
                            ),
                            Visibility(
                              visible: _notificationCount != 0 ? true : false,
                              child: Positioned(
                                right: 0,
                                child: new Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: new BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 12,
                                    minHeight: 12,
                                  ),
                                  child: new Text(
                                    '$_notificationCount',
                                    style: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Gaps.vGap8,
            Gaps.line,
            _MenuMainFunctionalModule(
              data: titles.mainMenuTitles,
              image: images.mainMenuImages,
              onItemClick: isMainEnable
                  ? (index) {
                      if (mounted) {
                        setState(() {
                          isMainEnable = false;
                          _performMenuPressedAction(index, context);
                          Future.delayed(const Duration(milliseconds: 500), () {
                            setState(() {
                              isMainEnable = true;
                            });
                          });
                        });
                      }
                    }
                  : (index) {},
            ),
            Gaps.line,
            Gaps.vGap8,
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                elevation: 1.0,
                color: Colors.white,
                child: Column(
                  children: [
                    Gaps.vGap12,
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Recharge & Bill Payments",
                        style: TextStyle(
                          fontSize: Dimens.font_sp16,
                          fontWeight: FontWeight.bold,
                          color: Colours.text   @override
  void setUser(ProfileViewModel user) {
    provider.setUser(user);
    provider.setErrors(user.errors!);
    setState(() {
      _isInComplete = user.errors!.length > 0;
      if (_isInComplete ?? false) _showSuccessDialog(provider.errors);
    });
  }

  @override
  bool get wantKeepAlive => true;

  void _handleProfileError(int code) {
    if (code == 102) {
      NavigatorUtils.push(context, AuthRouter.registerEmailVerificationPage);
    } else if (code == 104) {
      NavigatorUtils.push(context, AuthRouter.registerImageVerificationPage);
    } else if (code == 101) {
      NavigatorUtils.push(context, AuthRouter.registerPage);
    }
  }

    @override
  void setNotificationCount(
    NotificationCountViewModel notificationCountViewModel,
  ) {
    setState(() {
      _notificationCount = notificationCountViewModel.count!;
    });
  }
}

class _MenuOptionsFunctionalModule extends StatelessWidget {
  const _MenuOptionsFunctionalModule({
    Key? key,
    this.onItemClick,
    required this.data,
    required this.image,
  }) : super(key: key);

  final Function(int index)? onItemClick;
  final List<String> data;
  final List<String> image;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(4),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
      ),
      itemCount: data.length,
      itemBuilder: (_, index) {
        return InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              LoadAssetImage('${image[index]}', height: 36.0, width: 36.0),
              Gaps.vGap8,
              Text(
                data[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Helvetica',
                ),
              ),
            ],
          ),
          onTap: () {
            onItemClick!(index);
          },
        );
      },
    );
  }
}

class _MenuMainFunctionalModule extends StatelessWidget {
  const _MenuMainFunctionalModule({
    Key? key,
    this.onItemClick,
    required this.data,
    required this.image,
  }) : super(key: key);

  final Function(int index)? onItemClick;
  final List<String> data;
  final List<String> image;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.all(4),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.18,
      ),
      itemCount: data.length,
      itemBuilder: (_, index) {
        return InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LoadAssetImage(
                  '${image[index]}',
                  height: 36.0,
                  width: 36.0,
                ),
              ),
              Gaps.vGap8,
              Text(
                data[index],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colours.text,
                  fontFamily: 'Helvetica',
                ),
              ),
            ],
          ),
          onTap: () {
            onItemClick!(index);
          },
        );
      },
    );
  }
}
