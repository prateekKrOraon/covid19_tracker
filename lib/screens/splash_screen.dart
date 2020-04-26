import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

typedef void LocaleChangeCallback(Locale locale);

class SplashScreen extends StatefulWidget{

  final LocaleChangeCallback onLocaleChange;

  SplashScreen({this.onLocaleChange});

  @override
  _SplashScreenState createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen>{


  @override
  void initState() {
    initLang();
    super.initState();
  }

  initLang()async{

    Future.delayed(Duration(seconds: 3)).then((value){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home(onLocaleChange: widget.onLocaleChange,)), (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    AppLocalizations lang = AppLocalizations.of(context);


    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(),
            Text(
              lang.translate(kAppNameLang),
              style: TextStyle(
                  fontFamily: kQuickSand,
                  fontSize: 30,
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Text(
                    lang.translate(kAppSubTitleLang),
                    style: TextStyle(
                      color: kGreyColor,
                      fontFamily: kQuickSand,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}