import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/resources_screen.dart';
import 'package:covid19_tracker/screens/update_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'about_screen.dart';
import 'charts_screen.dart';
import 'dashboard.dart';

typedef void LocaleChangeCallback(Locale locale);

class Home extends StatefulWidget {

  final LocaleChangeCallback onLocaleChange;

  Home({Key key,this.onLocaleChange}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {

    AppLocalizations lang = AppLocalizations.of(context);

    List<BottomNavigationBarItem> _bottomNavItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(
          AntDesign.home,
        ),
        title: Text(
          lang.translate(kDashboardLang),
          style: TextStyle(
            fontFamily: kQuickSand,
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
          ),
        ),
      ),
      BottomNavigationBarItem(
        icon: Icon(
          AntDesign.linechart,
        ),
        title: Text(
          lang.translate(kTrendsLang),
          style: TextStyle(
            fontFamily: kQuickSand,
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
          ),
        ),
      ),
      BottomNavigationBarItem(
        icon: Icon(
          AntDesign.infocirlceo,
        ),
        title: Text(
          lang.translate(kAboutLang),
          style: TextStyle(
            fontFamily: kQuickSand,
          ),
        ),
      ),
    ];

    List<Widget> _body = <Widget>[
      Dashboard(),
      UpdatesScreen(),
      ChartsScreen(),
      ResourcesScreen(),
      AboutScreen(onLocaleChange: widget.onLocaleChange,),
    ];

    return Scaffold(
      body: SafeArea(
        child: _body[_currentTabIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
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
