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
  double textScaleFactor = 1;
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

    if(MediaQuery.of(context).size.width<=360){
      textScaleFactor=0.75;
    }

    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20,),
              Image(
                height: 100,
                width: 100,
                image: AssetImage('assets/app_icon_large.png'),
              ),
              SizedBox(height: 16,),
              Text(
                lang.translate(kAppNameLang),
                style: TextStyle(
                  fontSize: 30*textScaleFactor,
                  fontFamily: kQuickSand,
                ),
              ),
              SizedBox(height: 16,),
              Center(
                child: Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  elevation: 2,
                  color: theme.backgroundColor,
                  child: InkWell(
                    onTap: (){
                      _networkHandler.launchInBrowser("https://github.com/prateekKrOraon/covid19_tracker");
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.3,
                      padding: EdgeInsets.symmetric(vertical: 16,horizontal: 8,),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            AntDesign.github,
                            color: theme.accentColor,
                          ),
                          SizedBox(width: 10,),
                          Text(
                            lang.translate(kGitHubLang),
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: kQuickSand,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                elevation: 2,
                color: theme.backgroundColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        lang.translate(kCOVID19Lang),
                        style: TextStyle(
                          fontSize: 25*textScaleFactor,
                          fontFamily: kQuickSand,
                        ),
                      ),
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
                          height: 56,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                AntDesign.questioncircleo,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  lang.translate(kFAQsLang),
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                          height: 56,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                AntDesign.medicinebox,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  lang.translate(kSymptomsLang),
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                          height: 56,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                MaterialCommunityIcons.block_helper,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  lang.translate(kPreventionLang),
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                elevation: 2,
                color: theme.backgroundColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        lang.translate(kSourceLang),
                        style: TextStyle(
                          fontSize: 25*textScaleFactor,
                          fontFamily: kQuickSand,
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          _networkHandler.launchInBrowser(crowdSourcedDatabaseLink);
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                Icons.storage,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  lang.translate(kCrowdSrcDBLang),
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.launch,
                                color: theme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          _networkHandler.launchInBrowser(covid19IndiaAPILink);
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                Icons.web_asset,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  'api.covid19india.org',
                                  style: TextStyle(
                                      fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.launch,
                                color: theme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          _networkHandler.launchInBrowser(coronaLMAONinjaAPILink);
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                Icons.web_asset,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  'corona.lmao.ninja',
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.launch,
                                color: theme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          _networkHandler.launchInBrowser(covidAPILink);
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                Icons.web_asset,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  'covidapi.info',
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.launch,
                                color: theme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                elevation: 2,
                color: theme.backgroundColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        lang.translate(kDeveloperLang),
                        style: TextStyle(
                          fontSize: 25*textScaleFactor,
                          fontFamily: kQuickSand,
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          _networkHandler.launchInBrowser(developerPrateekGitHubLink);
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                AntDesign.github,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  lang.translate(kDeveloperNameLang),
                                  style: TextStyle(
                                      fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.launch,
                                color: theme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                elevation: 2,
                color: theme.backgroundColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        lang.translate(kApplicationLang),
                        style: TextStyle(
                          fontSize: 25*textScaleFactor,
                          fontFamily: kQuickSand,
                        ),
                      ),
                      InkWell(
                        splashColor: Colors.transparent,
                        onTap: (){
                          if(isUpdateAvailable){
                            _networkHandler.launchInBrowser(update['link']);
                          }
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                AntDesign.infocirlceo,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      lang.translate(kVersionLang),
                                      style: TextStyle(
                                        fontSize: 16*textScaleFactor,
                                      ),
                                    ),
                                    isUpdateAvailable?Text(
                                      "${lang.translate(kUpdateAvailableLang)} (v${update['version']}). ${lang.translate(kClickToDownloadLang)}",
                                      style: TextStyle(
                                        fontSize: 10*textScaleFactor,
                                        color: theme.accentColor,
                                      ),
                                    ):SizedBox(),
                                  ],
                                ),
                              ),
                              isUpdateAvailable?Container(
                                width: 20,
                                height: 20,
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
                                      fontSize: 10
                                    ),
                                  ),
                                ),
                              ):SizedBox(),
                              SizedBox(width: 5,),
                              Text(
                                '1.4.3',
                                style: TextStyle(
                                  fontSize: 16*textScaleFactor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 56,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 20,),
                            Icon(
                              darkTheme?Icons.brightness_2:Icons.brightness_5,
                              color: theme.accentColor,
                            ),
                            SizedBox(width: 30,),
                            Expanded(
                              child: Text(
                                darkTheme?lang.translate(kLightThemeLang):lang.translate(kDarkThemeLang),
                                style: TextStyle(
                                  fontSize: 16*textScaleFactor,
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
                            )
                          ],
                        ),
                      ),
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
                          height: 56,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                MaterialCommunityIcons.translate,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  lang.translate(kChangeLanguageLang),
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                elevation: 2,
                color: theme.backgroundColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        lang.translate(kLicenseLang),
                        style: TextStyle(
                          fontSize: 25*textScaleFactor,
                          fontFamily: kQuickSand,
                        ),
                      ),
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
                          height: 56,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 20,),
                              Icon(
                                MaterialCommunityIcons.license,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  lang.translate(kOpenSrcLang),
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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