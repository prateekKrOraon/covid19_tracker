import 'dart:math' as math;
import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/utilities/data_range.dart';
import 'package:covid19_tracker/data/state_wise_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyCaseTimeChart extends StatefulWidget{

  @override
  _DailyCaseTimeChartState createState() {
    return _DailyCaseTimeChartState();
  }
}

class _DailyCaseTimeChartState extends State<DailyCaseTimeChart>{

  String dataRange = DataRange.MONTH;
  double textScaleFactor = 1;

  ThemeData theme;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    theme = Theme.of(context);

    if(size.width <= 360){
      textScaleFactor = 0.75;
    }

    return FutureBuilder(
      future: StateWiseData.getInstance(),
      builder:(BuildContext context, snapshot){

        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
        }

        Map map = snapshot.data;
        List caseTime = map[kCaseTimeSeries];
        double dailyHighestCnf = 0;
        double dailyHighestRec = 0;
        double dailyHighestDet = 0;

        List<BarChartGroupData> dailyConfirmedChartGroup = List();
        List<BarChartGroupData> dailyRecChartGroup = List();
        List<BarChartGroupData> dailyDetChartGroup = List();

        int range = 0;

        if(dataRange == DataRange.BEGINNING){
          range = caseTime.length;
        }else if(dataRange == DataRange.MONTH){
          range = 31;
        }else if(dataRange == DataRange.TWO_WEEK){
          range = 14;
        }

        String lastUpdate = "";

        for(int i = caseTime.length-range;i<caseTime.length;i++){

          Map map = caseTime[i];

          double currentCnf = double.parse(map[kDailyConfirmed]);
          double currentRec = double.parse(map[kDailyRecovered]);
          double currentDet = double.parse(map[kDailyDeaths]);

          if(currentCnf>dailyHighestCnf){
            dailyHighestCnf = currentCnf;
          }

          if(currentRec>dailyHighestRec){
            dailyHighestRec = currentRec;
          }

          if(currentDet>dailyHighestDet){
            dailyHighestDet = currentDet;
          }

          dailyConfirmedChartGroup.add(
            BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                      y: currentCnf,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    color: theme.accentColor,
                    width: dataRange == DataRange.BEGINNING?2:8,
                  ),
                ],
            ),
          );

          dailyRecChartGroup.add(
            BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                      y: currentRec,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    color: theme.accentColor,
                    width: dataRange == DataRange.BEGINNING?2:8,
                  ),
                ],
            ),
          );

          dailyDetChartGroup.add(
            BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                      y: currentDet,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    color: theme.accentColor,
                    width: dataRange == DataRange.BEGINNING?2:8,
                  ),
                ],
            ),
          );

          if(i == caseTime.length-1){
            lastUpdate = map[kDate];
          }
        }

        String dataRangeStr = "";

        if(dataRange == DataRange.BEGINNING){
          dataRangeStr = "Since 30 Jan 2020";
        }else if(dataRange == DataRange.MONTH){
          dataRangeStr = "Last 30 days";
        }else if(dataRange == DataRange.TWO_WEEK){
          dataRangeStr = "Last 14 days";
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Scale Modes',
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 25*textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Showing data',
                        style: TextStyle(
                          color: kGreyColor,
                          fontFamily: kNotoSansSc,
                          fontSize: 16*textScaleFactor,
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Material(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      elevation: 2,
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            onTap: (){
                              setState(() {
                                if(dataRange != DataRange.BEGINNING){
                                  dataRange = DataRange.BEGINNING;
                                }
                              });
                            },
                            child: Container(
                              height: 35,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft:Radius.circular(10),
                                    bottomLeft: Radius.circular(10)
                                ),
                                color: dataRange != DataRange.BEGINNING?theme.backgroundColor:theme.accentColor,
                              ),
                              child: Center(
                                child: Text(
                                  'Beginning',
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontWeight: FontWeight.bold,
                                    color:dataRange != DataRange.BEGINNING?
                                    theme.brightness == Brightness.light?Colors.black:Colors.white:
                                    theme.brightness == Brightness.light?Colors.white:Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                if(dataRange != DataRange.MONTH){
                                  dataRange = DataRange.MONTH;
                                }
                              });
                            },
                            child: Container(
                              height: 35,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: dataRange != DataRange.MONTH?theme.backgroundColor:theme.accentColor,
                              ),
                              child: Center(
                                child: Text(
                                  '1 Month',
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontWeight: FontWeight.bold,
                                    color: dataRange != DataRange.MONTH?
                                    theme.brightness == Brightness.light?Colors.black:Colors.white:
                                    theme.brightness == Brightness.light?Colors.white:Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              setState(() {
                                if(dataRange != DataRange.TWO_WEEK){
                                  dataRange = DataRange.TWO_WEEK;
                                }
                              });
                            },
                            child: Container(
                              height: 35,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                                color: dataRange != DataRange.TWO_WEEK?theme.backgroundColor:theme.accentColor,
                              ),
                              child: Center(
                                child: Text(
                                  '2 Week',
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontWeight: FontWeight.bold,
                                    color: dataRange != DataRange.TWO_WEEK?
                                    theme.brightness == Brightness.light?Colors.black:Colors.white:
                                    theme.brightness == Brightness.light?Colors.white:Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                  ],
                ),
                SizedBox(height: 20,),
                Text(
                  "Last updated on $lastUpdate\2020",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kGreenColor,
                    fontSize: 16*textScaleFactor,
                    fontFamily: kQuickSand,
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
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Confirmed Cases',
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 25*textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20,),
                          _getBarChart(dailyConfirmedChartGroup, dailyHighestCnf+200),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  elevation: 2,
                  color: theme.backgroundColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Recoveries',
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 25*textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20,),
                          _getBarChart(dailyRecChartGroup, dailyHighestRec+200),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  elevation: 2,
                  color: theme.backgroundColor,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            'Deaths',
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 25*textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*textScaleFactor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20,),
                          _getBarChart(dailyDetChartGroup, dailyHighestDet+10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _getBarChart(List<BarChartGroupData> barGroups,double highest){
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AspectRatio(
        aspectRatio: 2,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
              allowTouchBarBackDraw: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: kAccentColor,
              ),
              touchCallback: (BarTouchResponse response){}
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(
                  color: kGreyColor,
                ),
                right: BorderSide(
                  color: kGreyColor,
                ),
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(
                showTitles: false,
              ),
              rightTitles: SideTitles(
                  reservedSize: 20,
                  showTitles: true,
                  interval: highest<200?10:200,
                  getTitles: (double value){
                    return value.toInt().toString();
                  },
                  textStyle: TextStyle(
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontSize: 10*textScaleFactor,
                  )
              ),
              bottomTitles: SideTitles(
                  rotateAngle: math.pi*90,
                  showTitles: dataRange==DataRange.BEGINNING?false:true,
                  getTitles: (double value){
                    DateTime now = DateTime.now();
                    DateTime returnDate = DateTime(
                        2020,
                        now.month,
                        now.day-31+value.toInt()
                    );
                    return DateFormat("d MMM").format(returnDate);
                  },
                  textStyle: TextStyle(
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontSize: 8*textScaleFactor,
                  )
              ),
            ),
            maxY: highest,
            backgroundColor: Colors.transparent,
            barGroups: barGroups,
            gridData: FlGridData(
                drawHorizontalLine: true,
                horizontalInterval: highest<200?10:200,
                drawVerticalLine: true
            ),
          ),
        ),
      ),
    );
  }
}