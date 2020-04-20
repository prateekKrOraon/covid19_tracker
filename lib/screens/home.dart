import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/screens/resources_screen.dart';
import 'package:covid19_tracker/screens/update_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'about_screen.dart';
import 'charts_screen.dart';
import 'dashboard.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int _currentTabIndex = 0;

  final List<BottomNavigationBarItem> _bottomNavItems = <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(
        AntDesign.home,
      ),
      title: Text(
        "Dashboard",
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
        "Updates",
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
        "Trends",
        style: TextStyle(
          fontFamily: kQuickSand,
        ),
      ),
    ),
    BottomNavigationBarItem(
      icon: Icon(
        AntDesign.eye,
      ),
      title: Text(
        "Resources",
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
        "About",
        style: TextStyle(
          fontFamily: kQuickSand,
        ),
      ),
    ),
  ];

  final _body = <Widget>[
    Dashboard(),
    UpdatesScreen(),
    ChartsScreen(),
    ResourcesScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
