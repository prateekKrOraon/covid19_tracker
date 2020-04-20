import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/data/theme_data.dart';
import 'package:covid19_tracker/screens/about_screen.dart';
import 'package:covid19_tracker/screens/charts_screen.dart';
import 'package:covid19_tracker/screens/dashboard.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/screens/splash_screen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => getTheme(brightness),
      themedWidgetBuilder: (context,theme){
        return MaterialApp(
          title: 'Covid-19 Tracker',
          theme: theme,
          home: SplashScreen(),
        );
      },
    );
  }
}