/*
*
* Contains information for the theme
*
 */

import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:flutter/material.dart';

ThemeData _getLightTheme(Brightness brightness){
  return ThemeData.light().copyWith(
    brightness: brightness,
    accentColor: kBlueColor,
    primaryColor: Colors.white,
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Color(0xFFFAFAFA),
    unselectedWidgetColor: Colors.grey,
    primaryColorLight: Colors.white,
    iconTheme: IconThemeData().copyWith(
      color: Colors.black,
    ),
    tabBarTheme: TabBarTheme().copyWith(
      labelColor: Colors.black,
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: kQuickSand,
      ),
      unselectedLabelStyle:TextStyle(
        fontFamily: kQuickSand,
      ),
    ),
    appBarTheme: AppBarTheme().copyWith(
      brightness: brightness,
      color: Colors.white,
      elevation: 2,
      iconTheme: IconThemeData().copyWith(
        color: Colors.black,
      ),
    )
  );
}

ThemeData _getDarkTheme(Brightness brightness){
  return ThemeData(
    brightness: brightness,
    primaryColor: kPrimaryColor,
    primaryColorDark: kPrimaryColor,
    primaryColorLight: Colors.grey[800],
    accentColor: kAccentColor,
    unselectedWidgetColor: kCaptionColor,
    scaffoldBackgroundColor: kPrimaryColor,
    backgroundColor: kBackgroundColor,
    tabBarTheme: TabBarTheme().copyWith(
      labelStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontFamily: kQuickSand,
      ),
      unselectedLabelStyle:TextStyle(
        fontFamily: kQuickSand,
      ),
    ),
    iconTheme: IconThemeData().copyWith(
      color: Colors.white,
    ),
  );
}

ThemeData getTheme(Brightness brightness){
  return brightness == Brightness.light?_getLightTheme(brightness):_getDarkTheme(brightness);
}