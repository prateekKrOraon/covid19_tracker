import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/screens/daily_case_time_chart_screen.dart';
import 'package:covid19_tracker/screens/demographics.dart';
import 'package:covid19_tracker/screens/total_case_time_chart_screen.dart';
import 'package:flutter/material.dart';

class ChartsScreen extends StatefulWidget{
  @override
  _ChartScreenState createState() {
    return _ChartScreenState();
  }
}

class _ChartScreenState extends State<ChartsScreen> with SingleTickerProviderStateMixin{

  @override
  void initState() {
    super.initState();
  }


  List<Widget> _tabPages = [
    TotalCaseTimeChart(),
    DailyCaseTimeChart(),
  ];

  @override
  Widget build(BuildContext context) {

    ThemeData themeData = Theme.of(context);

    return DefaultTabController(
      length: _tabPages.length,
      child: Scaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        appBar: TabBar(
          indicatorColor: themeData.accentColor,
          tabs: <Widget>[
            Tab(text: 'Commulative',),
            Tab(text: 'Daily'),
          ],
        ),
        body: TabBarView(
        children: _tabPages,
      ),
      ),
    );
  }



}