import 'dart:ui';

import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:qpay/common/appconstants.dart';
import 'package:qpay/res/resources.dart';

class ThemeProvider extends ChangeNotifier {
  static const Map<ThemeMode, String> themes = {
    ThemeMode.dark: 'Dark',
    ThemeMode.light: 'Light',
    ThemeMode.system: 'System',
  };

  void syncTheme() {
    final String? theme = SpUtil.getString(Constant.theme);
    if (theme!.isNotEmpty && theme != themes[ThemeMode.system]) {
      notifyListeners();
    }
  }

  void setTheme(ThemeMode themeMode) {
    SpUtil.putString(Constant.theme, themes[themeMode]!);
    notifyListeners();
  }

  ThemeMode getThemeMode() {
    final String? theme = SpUtil.getString(Constant.theme);
    switch (theme) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  void toggleLanguage() {
    var isBengali = SpUtil.getBool(Constant.isBengaliLocale);
    SpUtil.putBool(Constant.isBengaliLocale, !isBengali!);
    notifyListeners();
  }

  Locale getLocale() {
    var isBengali = SpUtil.getBool(Constant.isBengaliLocale);
    if (isBengali!)
      return new Locale(
        Constant.bengaliLanguageCode,
        Constant.bangladeshCountryCode,
      );
    return new Locale(
      Constant.englishLanguageCode,
      Constant.englishCountryCode,
    );
  }

  ThemeData getTheme({bool isDarkMode = false}) {
    Map<int, Color> colorMap = {
      50: Color.fromRGBO(255, 255, 255, .1),
      100: Color.fromRGBO(255, 255, 255, .2),
      200: Color.fromRGBO(255, 255, 255, .3),
      300: Color.fromRGBO(255, 255, 255, .4),
      400: Color.fromRGBO(255, 255, 255, .5),
      500: Color.fromRGBO(255, 255, 255, .6),
      600: Color.fromRGBO(255, 255, 255, .7),
      700: Color.fromRGBO(255, 255, 255, .8),
      800: Color.fromRGBO(255, 255, 255, .9),
      900: Color.fromRGBO(255, 255, 255, 1),
    };
    return ThemeData(
      useMaterial3: true,
      primaryColor: isDarkMode ? Colours.dark_app_main : Colours.app_main,
      textTheme: TextTheme().copyWith(
        displayLarge: isDarkMode
            ? TextStyles.textDarkGray14
            : TextStyles.text14,
        displayMedium: isDarkMode
            ? TextStyles.textDarkGray14
            : TextStyles.text14,
        displaySmall: isDarkMode
            ? TextStyles.textDarkGray12
            : TextStyles.text12,
        headlineLarge: isDarkMode
            ? TextStyles.textDarkGray14
            : TextStyles.text14,
        headlineMedium: isDarkMode
            ? TextStyles.textDarkGray14
            : TextStyles.text14,
        headlineSmall: isDarkMode
            ? TextStyles.textDarkGray12
            : TextStyles.text12,
        titleLarge: isDarkMode ? TextStyles.textDarkGray14 : TextStyles.text14,
        titleMedium: isDarkMode ? TextStyles.textDarkGray14 : TextStyles.text14,
        titleSmall: isDarkMode ? TextStyles.textDarkGray12 : TextStyles.text12,
        bodyLarge: isDarkMode ? TextStyles.textDarkGray14 : TextStyles.text14,
        bodyMedium: isDarkMode ? TextStyles.textDarkGray14 : TextStyles.text14,
        bodySmall: isDarkMode ? TextStyles.textDarkGray12 : TextStyles.text12,
        labelLarge: isDarkMode ? TextStyles.textDarkGray14 : TextStyles.text14,
        labelMedium: isDarkMode ? TextStyles.textDarkGray14 : TextStyles.text14,
        labelSmall: isDarkMode ? TextStyles.textDarkGray12 : TextStyles.text12,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: isDarkMode ? TextStyles.textDarkGray14 : TextStyles.text14,
        hintStyle: isDarkMode
            ? TextStyles.textHint14
            : TextStyles.textDarkGray14,
      ),
      popupMenuTheme: PopupMenuThemeData(
        labelTextStyle: MaterialStateProperty.all<TextStyle>(
          isDarkMode
              ? TextStyle(color: Colours.dark_bg_color)
              : TextStyle(color: Colours.dark_bg_color),
        ),
        textStyle: isDarkMode
            ? TextStyle(color: Colours.dark_bg_color)
            : TextStyle(color: Colours.dark_bg_color),
        color: isDarkMode ? Colours.dark_bg_color : Colours.dark_bg_color,
      ),

      appBarTheme: AppBarTheme(
        elevation: 0.0,
        color: isDarkMode ? Colours.dark_bg_color : Colors.white,
        titleTextStyle: isDarkMode
            ? TextStyle(color: Colours.dark_bg_color)
            : TextStyle(color: Colours.dark_bg_color),
        toolbarTextStyle: isDarkMode
            ? TextStyle(color: Colours.dark_bg_color)
            : TextStyle(color: Colours.dark_bg_color),
      ),
      dividerTheme: DividerThemeData(
        color: isDarkMode ? Colours.dark_line : Colours.line,
        space: 0.6,
        thickness: 0.6,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      colorScheme: ColorScheme.light(),
      bottomSheetTheme: BottomSheetThemeData(
        surfaceTintColor: isDarkMode ? Colours.dark_bg_color : Colors.white,
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: isDarkMode ? Colours.dark_bg_color : Colors.white,
        surfaceTintColor: isDarkMode ? Colours.dark_bg_color : Colors.white,
        shape: CircularNotchedRectangle(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData().copyWith(
        selectedItemColor: isDarkMode
            ? Colours.dark_app_main
            : Colours.app_main,
        selectedIconTheme: IconThemeData(
          color: isDarkMode ? Colours.dark_app_main : Colours.app_main,
        ),
      ),
      cardTheme: CardThemeData(
        color: isDarkMode ? Colours.dark_bg_color : Colors.white,
        surfaceTintColor: isDarkMode ? Colours.dark_bg_color : Colors.white,
      ),
      brightness: Brightness.light,
      primarySwatch: MaterialColor(0xFFffffff, colorMap),
      canvasColor: Colors.white,
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: Colours.app_main,
        selectionHandleColor: Colours.app_main,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colours.app_main,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: TextStyle(),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
