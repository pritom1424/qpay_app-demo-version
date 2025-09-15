import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:qpay/utils/theme_utils.dart';
import 'package:qpay/views/login/login_page.dart';
import 'package:qpay/widgets/load_image.dart';
import 'package:page_transition/page_transition.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: ThemeUtils.getBackgroundColor(context),
      child: Stack(
        children: [
          Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                heightFactor: 0.55,
                widthFactor: 0.55,
                alignment: Alignment.center,
                child: AnimatedSplashScreen(
                  backgroundColor: Colors.transparent,
                  duration: 1000,
                  splashTransition: SplashTransition.sizeTransition,
                  pageTransitionType: PageTransitionType.rightToLeft,
                  splash: LoadAssetImage(ThemeUtils.getLogo(context)),
                  nextScreen: LoginPage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
