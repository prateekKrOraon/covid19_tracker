import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/onboarding_screen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
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


  SharedPreferences _prefs;
  bool onBoarding = false;
  String langCode;

  @override
  void initState() {
    initSharedPrefs();
    initLang();
    super.initState();
  }

  initSharedPrefs()async{
    _prefs = await SharedPreferences.getInstance();
    //checking if the onboarding screen has been shown to the user or not
    bool check = _prefs.getBool(kOnboarding);
    if(check == null){
      onBoarding = false;
    }else{
      onBoarding = check;
    }
    //checking for locale information
    langCode = _prefs.getString("language_code");
  }

  initLang()async{
    Future.delayed(Duration(seconds: 3)).then((value){
      ThemeData theme = Theme.of(context);
      AppLocalizations lang = AppLocalizations.of(context);
      if(langCode == null){
        // locale is not saved in shared preferences then ask for language, one time only
        showDialog<Map<String,String>>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context){
            return SimpleDialog(
              title: Text(
                "Choose Language/भाषा चुनें",
                style: TextStyle(
                  fontFamily: kQuickSand,
                ),
              ),
              children: <Widget>[
                ListTile(
                  title: Text(
                    "English - US",
                    style: TextStyle(
                      fontFamily: kQuickSand,
                    ),
                  ),
                  trailing: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        width: 2,
                        color: theme.accentColor,
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                  onTap: (){
                    Map<String,String> map = {
                      "lang_code":"en",
                      "country_code":"US",
                    };
                    Navigator.pop(context,map);
                  },
                ),
                ListTile(
                  title: Text(
                    "हिन्दी - भारत",
                    style: TextStyle(
                      fontFamily: kQuickSand,
                    ),
                  ),
                  trailing: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      border: Border.all(
                        width: 2,
                        color: theme.accentColor,
                      ),
                      color: Colors.transparent,
                    ),
                  ),
                  onTap: (){
                    Map<String,String> map = {
                      "lang_code":"hi",
                      "country_code":"IN",
                    };
                    Navigator.pop(context,map);
                  },
                ),
              ],
            );
          },
        ).then((Map<String,String> returnVal){
          //saving chosen locale in shared preferences and going to onboarding screen
          if(returnVal != null){
            widget.onLocaleChange(Locale(returnVal["lang_code"],returnVal["country_code"]));
            Future.delayed(Duration(seconds: 2)).then((value){
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => onBoarding?Home(onLocaleChange: widget.onLocaleChange,):Onboarding(widget.onLocaleChange)), (route) => false);
            });
          }
        });
      }else{
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => !onBoarding?Onboarding(widget.onLocaleChange):Home(onLocaleChange: widget.onLocaleChange,)), (route) => false);
      }
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
            Image(
              height: 125,
              width: 125,
              image: AssetImage(
                "assets/app_icon_large.png"
              ),
            ),
            SizedBox(height: 10,),
            Text(
              lang.translate(kAppNameLang),
              style: TextStyle(
                  fontFamily: kQuickSand,
                  fontSize: 30,
              ),
            ),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}