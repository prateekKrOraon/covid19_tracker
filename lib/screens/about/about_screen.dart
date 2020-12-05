import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/data/update_log.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/about/open_source_licenses.dart';
import 'package:covid19_tracker/screens/about/preventions_screen.dart';
import 'package:covid19_tracker/screens/about/symptoms_screen.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'faqs_screen.dart';

typedef void LocaleChangeCallback(Locale locale);

class AboutScreen extends StatefulWidget{

  final LocaleChangeCallback onLocaleChange;
  final Map<String,dynamic> update;

  AboutScreen({this.onLocaleChange,this.update});

  @override
  _AboutScreenState createState() {
    return _AboutScreenState();
  }
}

class _AboutScreenState extends State<AboutScreen>{

  NetworkHandler _networkHandler;
  double scaleFactor = 1;
  ThemeData theme;
  bool darkTheme;
  Map<String,dynamic> update;
  bool isUpdateAvailable = false;

  @override
  void initState() {
    _networkHandler = NetworkHandler.getInstance();
    this.update = widget.update;
    if(update.containsKey('update')){
      if(update['update']){
        setState(() {
          isUpdateAvailable = true;
        });
      }
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    theme = Theme.of(context);
    darkTheme = theme.brightness == Brightness.dark?true:false;
    AppLocalizations lang = AppLocalizations.of(context);

    if(MediaQuery.of(context).size.width<400){
      scaleFactor=0.75;
    }else if(MediaQuery.of(context).size.width<=450){
      scaleFactor = 0.9;
    }

    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20,),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image(
                      height: 100*scaleFactor,
                      width: 100*scaleFactor,
                      image: AssetImage('assets/app_icon_large.png'),
                    ),
                    SizedBox(height: 16*scaleFactor,),
                    Text(
                      lang.translate(kAppNameLang),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30*scaleFactor,
                        fontFamily: kQuickSand,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32*scaleFactor,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  lang.translate(kCOVID19Lang),
                  style: TextStyle(
                    fontSize: 25*scaleFactor,
                    fontFamily: kQuickSand,
                  ),
                ),
              ),
              SizedBox(height: 16*scaleFactor,),
              InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FAQsScreen(),
                      )
                  );
                },
                child: Container(
                  height: 56*scaleFactor,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 20*scaleFactor,),
                      Icon(
                        AntDesign.questioncircleo,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20*scaleFactor,),
                      Expanded(
                        child: Text(
                          lang.translate(kFAQsLang),
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SymptomsScreen(),
                      )
                  );
                },
                child: Container(
                  height: 56*scaleFactor,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 20*scaleFactor,),
                      Icon(
                        AntDesign.medicinebox,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20*scaleFactor,),
                      Expanded(
                        child: Text(
                          lang.translate(kSymptomsLang),
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: (){
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => PreventionsScreen(),
                   )
                 );
                },
                child: Container(
                  height: 56*scaleFactor,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 20*scaleFactor,),
                      Icon(
                        MaterialCommunityIcons.block_helper,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20*scaleFactor,),
                      Expanded(
                        child: Text(
                          lang.translate(kPreventionLang),
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              SizedBox(height: 32*scaleFactor,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  lang.translate(kDeveloperLang),
                  style: TextStyle(
                    fontSize: 25*scaleFactor,
                    fontFamily: kQuickSand,
                  ),
                ),
              ),
              SizedBox(height: 16*scaleFactor,),
              InkWell(
                onTap: (){
                  _networkHandler.launchInBrowser(developerPrateekGitHubLink);
                },
                child: Container(
                  height: 56*scaleFactor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 20*scaleFactor,),
                      Icon(
                        AntDesign.github,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20*scaleFactor,),
                      Expanded(
                        child: Text(
                          lang.translate(kDeveloperNameLang),
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.launch,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20,),
                    ],
                  ),
                ),
              ),
              Divider(),
              SizedBox(height: 32*scaleFactor,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  lang.translate(kApplicationLang),
                  style: TextStyle(
                    fontSize: 25*scaleFactor,
                    fontFamily: kQuickSand,
                  ),
                ),
              ),
              SizedBox(height: 16*scaleFactor,),
              InkWell(
                splashColor: Colors.transparent,
                onTap: (){
                  if(isUpdateAvailable){
                    _networkHandler.launchInBrowser(update['link']);
                  }
                },
                child: Container(
                  height: 56*scaleFactor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 20*scaleFactor,),
                      Icon(
                        AntDesign.infocirlceo,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20*scaleFactor,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              lang.translate(kVersionLang),
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 16*scaleFactor,
                              ),
                            ),
                            isUpdateAvailable?Text(
                              "${lang.translate(kUpdateAvailableLang)} (v${update['version']}). ${lang.translate(kClickToDownloadLang)}",
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 10*scaleFactor,
                                color: theme.accentColor,
                              ),
                            ):SizedBox(),
                          ],
                        ),
                      ),
                      isUpdateAvailable?Container(
                        width: 20*scaleFactor,
                        height: 20*scaleFactor,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          color: kRedColor,
                        ),
                        child: Center(
                          child: Text(
                            'N',
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 10*scaleFactor
                            ),
                          ),
                        ),
                      ):SizedBox(),
                      SizedBox(width: 5*scaleFactor,),
                      Text(
                        '1.7.3',
                        style: TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 16*scaleFactor,
                        ),
                      ),
                      SizedBox(width: 20,),
                    ],
                  ),
                ),
              ),
              Divider(),
              Container(
                height: 56*scaleFactor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(width: 20*scaleFactor,),
                    Icon(
                      darkTheme?Icons.brightness_2:Icons.brightness_5,
                      size: 24*scaleFactor,
                      color: theme.accentColor,
                    ),
                    SizedBox(width: 20*scaleFactor,),
                    Expanded(
                      child: Text(
                        darkTheme?lang.translate(kLightThemeLang):lang.translate(kDarkThemeLang),
                        style: TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 16*scaleFactor,
                        ),
                      ),
                    ),
                    Switch(
                      value: darkTheme,
                      activeColor: theme.accentColor,
                      onChanged: (bool value){
                        changeBrightness();
                        setState(() {
                          darkTheme = value;
                        });
                      },
                    ),
                    SizedBox(width: 20,),
                  ],
                ),
              ),
              Divider(),
              InkWell(
                onTap: (){
                  showDialog<Map<String,String>>(
                    context: context,
                    builder: (BuildContext context){
                      return SimpleDialog(
                        title: Text(
                          lang.translate(kChooseLanguageLang),
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                        children: <Widget>[
                          ListTile(
                            title: Text(
                              "English - US",
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 16*scaleFactor
                              ),
                            ),
                            trailing: Container(
                              height: 20*scaleFactor,
                              width: 20*scaleFactor,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: theme.accentColor,
                                ),
                                color: lang.locale.languageCode == "en"?theme.accentColor:Colors.transparent,
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
                                fontSize: 16*scaleFactor
                              ),
                            ),
                            trailing: Container(
                              height: 20*scaleFactor,
                              width: 20*scaleFactor,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                border: Border.all(
                                  width: 2,
                                  color: theme.accentColor,
                                ),
                                color: lang.locale.languageCode == "hi"?theme.accentColor:Colors.transparent,
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
                    }
                  ).then((Map<String,String> returnVal){
                    if(returnVal != null){
                      widget.onLocaleChange(Locale(returnVal["lang_code"],returnVal["country_code"]));
                      setState(() {
                        UpdateLog.refresh(returnVal["lang_code"]);
                      });
                    }
                  });
                },
                child: Container(
                  height: 56*scaleFactor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 20*scaleFactor,),
                      Icon(
                        MaterialCommunityIcons.translate,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20*scaleFactor,),
                      Expanded(
                        child: Text(
                          lang.translate(kChangeLanguageLang),
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: (){
                  _networkHandler.launchInBrowser("https://github.com/prateekKrOraon/covid19_tracker");
                },
                child: Container(
                  height: 56*scaleFactor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 20*scaleFactor,),
                      Icon(
                        AntDesign.github,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20*scaleFactor,),
                      Expanded(
                        child: Text(
                          lang.translate(kSourceCodeLang),//lang.translate(kDeveloperNameLang),
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.launch,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20,),
                    ],
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: (){
                  _networkHandler.launchInBrowser("https://github.com/prateekKrOraon/covid-19-tracker-api");
                },
                child: Container(
                  height: 56*scaleFactor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 20*scaleFactor,),
                      Icon(
                        AntDesign.github,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20*scaleFactor,),
                      Expanded(
                        child: Text(
                          lang.translate(kAPILang),//lang.translate(kDeveloperNameLang),
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.launch,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20,),
                    ],
                  ),
                ),
              ),
              Divider(),
              SizedBox(height: 32*scaleFactor,),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  lang.translate(kLicenseLang),
                  style: TextStyle(
                    fontSize: 25*scaleFactor,
                    fontFamily: kQuickSand,
                  ),
                ),
              ),
              SizedBox(height: 16*scaleFactor,),
              InkWell(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OpenSourceLicenses(),
                    ),
                  );
                },
                child: Container(
                  height: 56*scaleFactor,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(width: 20*scaleFactor,),
                      Icon(
                        MaterialCommunityIcons.license,
                        size: 24*scaleFactor,
                        color: theme.accentColor,
                      ),
                      SizedBox(width: 20*scaleFactor,),
                      Expanded(
                        child: Text(
                          lang.translate(kOpenSrcLang),
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(theme.brightness == Brightness.dark? Brightness.light: Brightness.dark);
  }
}