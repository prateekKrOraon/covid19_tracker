import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/trends/analytics.dart';
import 'package:covid19_tracker/screens/trends/compare.dart';
import 'package:covid19_tracker/screens/trends/daily_case_time_chart_screen.dart';
import 'package:covid19_tracker/screens/trends/predictions.dart';
import 'package:covid19_tracker/screens/trends/total_case_time_chart_screen.dart';
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
    AnalyticsScreen(),
    Predictions(),
    CompareScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    ThemeData themeData = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context);

    return DefaultTabController(
      length: _tabPages.length,
      child: Scaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        appBar: TabBar(
          isScrollable: true,
          indicatorColor: themeData.accentColor,
          tabs: <Widget>[
            Tab(text: lang.translate(kCumulativeLang),),
            Tab(text: lang.translate(kDailyLang)),
            Tab(text: lang.translate(kMoreAnalysis),),
            Tab(text: lang.translate(kPredictions),),
            Tab(text: "Compare",),
          ],
        ),
        body: TabBarView(
        children: _tabPages,
      ),
      ),
    );
  }



}