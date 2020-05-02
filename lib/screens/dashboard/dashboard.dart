import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/dashboard/dashboard_india/dashboard_india.dart';
import 'package:covid19_tracker/screens/dashboard/dashboard_global/dashboard_global.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget{
  @override
  _DashboardState createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard>{

  double textScaleFactor = 1;

  ThemeData theme;
  bool refresh = false;


  @override
  void initState() {
    super.initState();
  }

  List<Widget> _tabPages = [
    DashboardIndia(),
    DashboardGlobal(),
  ];

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return DefaultTabController(
      length: _tabPages.length,
      child: Scaffold(
        appBar: TabBar(
          indicatorColor: themeData.accentColor,
          tabs: <Widget>[
            Tab(text: AppLocalizations.of(context).translate("india"),),
            Tab(text: AppLocalizations.of(context).translate("global"),),
          ],
        ),
        body: TabBarView(
          children: _tabPages,
        ),
      ),
    );
  }

}