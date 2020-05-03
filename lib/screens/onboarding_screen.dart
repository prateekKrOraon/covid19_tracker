import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Constants/constants.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Onboarding extends StatefulWidget{

  final Function onLocaleChange;
  Onboarding(this.onLocaleChange);

  @override
  _OnboardingState createState() {
    return _OnboardingState();
  }
}

class _OnboardingState extends State<Onboarding>{

  SharedPreferences _prefs;
  @override
  void initState() {
    initSharedPrefs();
    super.initState();
  }

  initSharedPrefs()async{
    _prefs = await SharedPreferences.getInstance();
  }

  //saving information that the user has seen the onboarding screen
  // and navigating to home
  goToDashboard(){
    _prefs.setBool(kOnboarding, true).then((value){
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Home(onLocaleChange:widget.onLocaleChange,),
        ),
        (route) => false,
      );
    });
  }


  @override
  Widget build(BuildContext context) {


    ThemeData theme = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context);

    final TextStyle _textStyle = TextStyle(
      fontFamily: kQuickSand,
      color: theme.accentColor
    );

    final _pages = [
      PageViewModel(
        pageColor: theme.scaffoldBackgroundColor,
        bubbleBackgroundColor: theme.accentColor,
        title: Container(),
        body: Column(
          children: <Widget>[
            Text(lang.translate(kPrevention1Lang)),
            Text(
              lang.translate(kPrevention1DesLang),
              style: _textStyle.copyWith(
                fontSize: 16,
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
              ),
            ),
          ],
        ),
        mainImage: Center(
          child: Container(
            height: 200,
            width: 200,
            decoration:  BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image:  AssetImage(
                  'assets/wash_hands.PNG',
                ),
              ),
            ),
          ),
        ),
        textStyle: _textStyle,
      ),
      PageViewModel(
        pageColor: theme.scaffoldBackgroundColor,
        iconColor: null,
        bubbleBackgroundColor: theme.accentColor,
        title: Container(),
        body: Column(
          children: <Widget>[
            Text(lang.translate(kPrevention2Lang)),
            Text(
              lang.translate(kPrevention2DesLang),
              style: _textStyle.copyWith(
                fontSize: 16,
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
              ),
            ),
          ],
        ),
        mainImage: Center(
          child: Container(
            height: 200,
            width: 200,
            decoration:  BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image:  AssetImage(
                  'assets/social_distance.png',
                ),
              ),
            ),
          ),
        ),
        textStyle: _textStyle,
      ),
      PageViewModel(
        pageColor: theme.scaffoldBackgroundColor,
        iconColor: null,
        bubbleBackgroundColor: theme.accentColor,
        title: Container(),
        body: Column(
          children: <Widget>[
            Text(lang.translate(kPrevention3Lang)),
            Text(
              lang.translate(kPrevention3DesLang),
              style: _textStyle.copyWith(
                fontSize: 16,
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
              ),
            ),
          ],
        ),
        mainImage: Center(
          child: Container(
            height: 200,
            width: 200,
            decoration:  BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image:  AssetImage(
                  'assets/avoid_touch.png',
                ),
              ),
            ),
          ),
        ),
        textStyle: _textStyle,
      ),
      PageViewModel(
        pageColor: theme.scaffoldBackgroundColor,
        iconColor: null,
        bubbleBackgroundColor: theme.accentColor,
        title: Container(),
        body: Column(
          children: <Widget>[
            Text(lang.translate(kPrevention4Lang)),
            Text(
              lang.translate(kPrevention4DesLang),
              style: _textStyle.copyWith(
                fontSize: 16,
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
              ),
            ),
          ],
        ),
        mainImage: Center(
          child: Container(
            height: 200,
            width: 200,
            decoration:  BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image:  AssetImage(
                  'assets/hygiene.png',
                ),
              ),
            ),
          ),
        ),
        textStyle: _textStyle,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            IntroViewsFlutter(
              _pages,
              fullTransition: 200,
              onTapDoneButton: (){
                goToDashboard();
              },
              showSkipButton: false,
              doneText: Text(
                lang.translate(kGetStartedLang),
                style: TextStyle(
                  fontFamily: kQuickSand,
                  fontSize: 18,
                  color: theme.accentColor
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}