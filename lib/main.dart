import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:fluro/fluro.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:qpay/providers/theme_provider.dart';
import 'package:qpay/routers/application.dart';
import 'package:qpay/routers/routers.dart';
import 'package:qpay/utils/bad_certificate.dart';
import 'package:qpay/widgets/global_navigator.dart';

import 'localization/app_localizations.dart';
import 'locator.dart';
import 'net/dio_utils.dart';
import 'net/intercept.dart';
import 'net/push_notification_service.dart';
import 'views/home/splash_page.dart';

final RsaSecurityInterceptor rsaInterceptor = RsaSecurityInterceptor();

Future<void> main() async {
  await runZonedGuarded(
    () async {
      HttpOverrides.global = new MyHttpOverrides();
      WidgetsFlutterBinding.ensureInitialized();
      await SpUtil.getInstance();
      await Firebase.initializeApp();
      await rsaInterceptor.init();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      setupLocator();
      runApp(MyApp());
    },
    (Object error, StackTrace stackTrace) async {
      await FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}

class MyApp extends StatelessWidget {
  final Widget? home;
  final ThemeData? theme;
  final PushNotificationService _pushNotificationService =
      locator<PushNotificationService>();
  MyApp({this.home, this.theme}) {
    _pushNotificationService.initialise();
    initDio();
    final FluroRouter router = FluroRouter();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  void initDio() {
    final List<Interceptor> interceptors = [];
    interceptors.add(TokenInterceptor());
    interceptors.add(LoggingInterceptor());
    interceptors.add(AuthInterceptor());
    interceptors.add(AdapterInterceptor());
    interceptors.add(rsaInterceptor);

    setInitDio(interceptors: interceptors);
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider(),
        child: Consumer<ThemeProvider>(
          builder: (_, provider, __) {
            return OverlaySupport(
              child: MaterialApp(
                navigatorKey: GlobalVariable.navState,
                title: "",
                debugShowCheckedModeBanner: false,
                locale: provider.getLocale(),
                theme: theme ?? provider.getTheme(),
                darkTheme: provider.getTheme(isDarkMode: false),
                themeMode: provider.getThemeMode(),
                home: home ?? SplashPage(),
                onGenerateRoute: Application.router?.generator,
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const <Locale>[
                  Locale('bn', 'BD'),
                  Locale('en', 'US'),
                ],
                builder: (context, child) {
                  final MediaQueryData data = MediaQuery.of(context);
                  return MediaQuery(
                    data: data.copyWith(textScaler: TextScaler.linear(1.0)),
                    child: child ?? Container(),
                  );
                },
              ),
            );
          },
        ),
      ),
      backgroundColor: Colors.white,
      textPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      radius: 20.0,
      position: ToastPosition.bottom,
    );
  }
}
