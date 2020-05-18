import 'dart:collection';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/resources/resources_screen.dart';
import 'package:covid19_tracker/screens/updates/update_log_screen.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:package_info/package_info.dart';
import 'about/about_screen.dart';
import 'trends/charts_screen.dart';
import 'dashboard/dashboard.dart';

typedef void LocaleChangeCallback(Locale locale);

class Home extends StatefulWidget {

  final LocaleChangeCallback onLocaleChange;

  Home({Key key,this.onLocaleChange}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _currentTabIndex = 0;
  PackageInfo packageInfo;
  Map<String,dynamic> update = HashMap();
  bool isUpdateAvailable = false;
  double scaleFactor = 1;

  @override
  initState(){
    checkForUpdate();
    super.initState();
  }

  //function to check for updates
  // sends current version of application
  checkForUpdate()async{
    packageInfo = await PackageInfo.fromPlatform();
    if(packageInfo != null){
      Map<String,dynamic> map = await NetworkHandler.getInstance().checkForUpdates(packageInfo.version);
      if(map != null && map['update']){
        setState((){
          update = map;
          isUpdateAvailable = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    AppLocalizations lang = AppLocalizations.of(context);

    Size size = MediaQuery.of(context).size;

    if(size.width<400){
      scaleFactor = 0.75;
    }else if(size.width<=450){
      scaleFactor = 0.9;
    }

    List<BottomNavigationBarItem> _bottomNavItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(
          AntDesign.home,
        ),
        title: Text(
          lang.translate(kDashboardLang),
          style: TextStyle(
            fontFamily: kQuickSand,
            fontSize: 14*scaleFactor,
          ),
        ),
      ),
      BottomNavigationBarItem(
        icon: Icon(
          AntDesign.clockcircleo,
        ),
        title: Text(
          lang.translate(kUpdatesLang),
          style: TextStyle(
            fontFamily: kQuickSand,
            fontSize: 14*scaleFactor
          ),
        ),
      ),
      BottomNavigationBarItem(
        icon: Icon(
          AntDesign.linechart,
        ),
        title: Text(
          lang.translate(kAnalysisLang),
          style: TextStyle(
            fontFamily: kQuickSand,
            fontSize: 14*scaleFactor
          ),
        ),
      ),
      BottomNavigationBarItem(
        icon: Icon(
          AntDesign.eyeo,
        ),
        title: Text(
          lang.translate(kResourcesLang),
          style: TextStyle(
            fontFamily: kQuickSand,
            fontSize: 14*scaleFactor
          ),
        ),
      ),
      BottomNavigationBarItem(
        icon: Container(
          width: 30*scaleFactor,
          child: Stack(
            children: <Widget>[
              Icon(
                AntDesign.infocirlceo,
              ),
              Positioned(
                right: 0,
                child:isUpdateAvailable?Container(
                  width: 15*scaleFactor,
                  height: 15*scaleFactor,
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
                          fontSize: 8*scaleFactor,
                      ),
                    ),
                  ),
                ):SizedBox(),
              )
            ],
          ),
        ),
        title: Text(
          lang.translate(kAboutLang),
          style: TextStyle(
            fontFamily: kQuickSand,
            fontSize: 14*scaleFactor
          ),
        ),
      ),
    ];

    List<Widget> _body = <Widget>[
      Dashboard(),
      UpdatesScreen(),
      ChartsScreen(),
      ResourcesScreen(),
      AboutScreen(onLocaleChange: widget.onLocaleChange,update:update),
    ];

    return Scaffold(
      body: SafeArea(
        child: _body[_currentTabIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedIconTheme: IconThemeData().copyWith(
          size: 24*scaleFactor,
        ),
        unselectedIconTheme: IconThemeData().copyWith(
          size: 20*scaleFactor
        ),
        selectedItemColor: Theme.of(context).accentColor,
        backgroundColor: Theme.of(context).primaryColorLight,
        unselectedItemColor: Theme.of(context).unselectedWidgetColor,
        items: _bottomNavItems,
        currentIndex: _currentTabIndex,
        type: BottomNavigationBarType.shifting,
        onTap: (int index){
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
    );
  }
}
