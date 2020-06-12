import 'dart:math' as math;
import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/helpers/data_range.dart';
import 'package:covid19_tracker/data/state_wise_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../error_screen.dart';

class DailyCaseTimeChart extends StatefulWidget{

  @override
  _DailyCaseTimeChartState createState() {
    return _DailyCaseTimeChartState();
  }
}

class _DailyCaseTimeChartState extends State<DailyCaseTimeChart>{

  String dataRange = DataRange.MONTH;
  double scaleFactor = 1;

  ThemeData theme;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context);
    if(size.width<400){
      scaleFactor = 0.75;
    }else if(size.width<=450){
      scaleFactor = 0.9;
    }

    return FutureBuilder(
      future: StateWiseData.getIndiaTimeSeries(),
      builder:(BuildContext context, snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return Column(
            children: [
              LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
              SizedBox(
                height: size.height*0.4,
              ),
              Text(
                lang.translate(kLoading),
                style: TextStyle(
                  fontFamily: kQuickSand,
                ),
              ),
            ],
          );
        }
        if(snapshot.hasError){
          return Center(
            child: ErrorScreen(
              onClickRetry: (){
                setState(() {
                  StateWiseData.refresh();
                });
              },
            ),
          );
        }
        if(!snapshot.hasData){
          return Center(
            child: ErrorScreen(
              onClickRetry: (){
                setState(() {
                  StateWiseData.refresh();
                });
              },
            ),
          );
        }

        Map map = snapshot.data;
        List caseTime = map['timeseries'];
        double dailyHighestCnf = 0;
        double dailyHighestRec = 0;
        double dailyHighestDet = 0;
        double dailyHighestAct = 0;

        List<BarChartGroupData> dailyConfirmedChartGroup = List();
        List<BarChartGroupData> dailyRecChartGroup = List();
        List<BarChartGroupData> dailyDetChartGroup = List();
        List<BarChartGroupData> dailyActChartGroup = List();

        int range = 0;

        if(dataRange == DataRange.BEGINNING){
          range = caseTime.length;
        }else if(dataRange == DataRange.MONTH){
          range = 30;
        }else if(dataRange == DataRange.TWO_WEEK){
          range = 14;
        }

        String lastUpdate = "";

        int lastDate = int.parse(caseTime[caseTime.length-1][kDate].toString().substring(0,3));

        int max = 0;
        if(lastDate<=30){
          if((lastDate+1)%31 > DateTime.now().day){
            max = caseTime.length-1;
          }else{
            max = caseTime.length;
          }
        }else if(lastDate==31){
          if((lastDate+1)%32 > DateTime.now().day){
            max = caseTime.length-1;
          }else{
            max = caseTime.length;
          }
        }else{
          max = caseTime.length;
        }

        for(int i = caseTime.length-range;i<max;i++){

          Map map = caseTime[i];

          double currentCnf = double.parse(map[kDailyConfirmed]);
          double currentRec = double.parse(map[kDailyRecovered]);
          double currentDet = double.parse(map[kDailyDeaths]);
          double currentAct = currentCnf - currentRec - currentDet;

          if(currentAct < 0){
            currentAct = 0;
          }

          if(currentCnf>dailyHighestCnf){
            dailyHighestCnf = currentCnf;
          }

          if(currentRec>dailyHighestRec){
            dailyHighestRec = currentRec;
          }

          if(currentDet>dailyHighestDet){
            dailyHighestDet = currentDet;
          }

          if(currentAct>dailyHighestAct){
            dailyHighestAct = currentAct;
          }

          dailyConfirmedChartGroup.add(
            BarChartGroupData(
                x: i,
                showingTooltipIndicators: [],
                barRods: [
                  BarChartRodData(
                      y: currentCnf,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    color: theme.accentColor,
                    width: dataRange == DataRange.BEGINNING?2*scaleFactor:6*scaleFactor,
                  ),
                ],
            ),
          );

          dailyActChartGroup.add(
            BarChartGroupData(
              x: i,
              showingTooltipIndicators: [],
              barRods: [
                BarChartRodData(
                  y: currentAct,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                  color: theme.accentColor,
                  width: dataRange == DataRange.BEGINNING?2*scaleFactor:6*scaleFactor,
                ),
              ],
            ),
          );

          dailyRecChartGroup.add(
            BarChartGroupData(
                x: i,
              showingTooltipIndicators: [],
                barRods: [
                  BarChartRodData(
                      y: currentRec,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    color: theme.accentColor,
                    width: dataRange == DataRange.BEGINNING?2*scaleFactor:6*scaleFactor,
                  ),
                ],
            ),
          );

          dailyDetChartGroup.add(
            BarChartGroupData(
                x: i,
                showingTooltipIndicators: [],
                barRods: [
                  BarChartRodData(
                      y: currentDet,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                    color: theme.accentColor,
                    width: dataRange == DataRange.BEGINNING?2*scaleFactor:6*scaleFactor,
                  ),
                ],
            ),
          );

          if(i == max-1){
            lastUpdate = map[kDate];
          }
        }

        String dataRangeStr = "";

        if(dataRange == DataRange.BEGINNING){
          dataRangeStr = lang.translate(kSinceBeginningLang);
        }else if(dataRange == DataRange.MONTH){
          dataRangeStr = lang.translate(kLast30DaysLang);
        }else if(dataRange == DataRange.TWO_WEEK){
          dataRangeStr = lang.translate(kLast14DaysLang);
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 8*scaleFactor,),
                Text(
                  lang.translate(kScalingModesLang),
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 25*scaleFactor,
                  ),
                ),
                SizedBox(height: 10*scaleFactor,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        lang.translate(kShowingDataLang),
                        style: TextStyle(
                          color: kGreyColor,
                          fontFamily: kNotoSansSc,
                          fontSize: 16*scaleFactor,
                        ),
                      ),
                    ),
                    SizedBox(width: 10*scaleFactor,),
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
                              height: 35*scaleFactor,
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
                                  lang.translate(kBeginningLang),
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 14*scaleFactor,
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
                              height: 35*scaleFactor,
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: dataRange != DataRange.MONTH?theme.backgroundColor:theme.accentColor,
                              ),
                              child: Center(
                                child: Text(
                                  lang.translate(k1MonthLang),
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 14*scaleFactor,
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
                              height: 35*scaleFactor,
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
                                  lang.translate(k2WeekLang),
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 14*scaleFactor,
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
                    SizedBox(width: 10*scaleFactor,),
                  ],
                ),
                SizedBox(height: 20*scaleFactor,),
                Text(
                  "${lang.translate(kLastUpdatedAtLang)}: $lastUpdate\2020",
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 16*scaleFactor,
                    fontFamily: kQuickSand,
                  ),
                ),
                SizedBox(height: 10*scaleFactor,),
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
                            lang.translate(kConfirmedLang),
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 25*scaleFactor,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*scaleFactor,
                            ),
                          ),
                          SizedBox(height: 10*scaleFactor,),
                          _getBarChart(dailyConfirmedChartGroup, dailyHighestCnf+200),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10*scaleFactor,),
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
                            lang.translate(kActiveLang),
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 25*scaleFactor,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*scaleFactor,
                            ),
                          ),
                          SizedBox(height: 10*scaleFactor,),
                          _getBarChart(dailyActChartGroup, dailyHighestAct+200),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20*scaleFactor,),
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
                            lang.translate(kRecoveredLang),
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 25*scaleFactor,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*scaleFactor,
                            ),
                          ),
                          SizedBox(height: 10*scaleFactor,),
                          _getBarChart(dailyRecChartGroup, dailyHighestRec+200),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20*scaleFactor),
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
                            lang.translate(kDeathsLang),
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 25*scaleFactor,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*scaleFactor,
                            ),
                          ),
                          SizedBox(height: 10*scaleFactor,),
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

    double sideInterval = (highest/10).roundToDouble();

    if(sideInterval < 0.001){
      sideInterval = 1;
    }
    int maxX = 30;
    if(dataRange == DataRange.BEGINNING){
      maxX = barGroups.length;
    }else if(dataRange == DataRange.MONTH){
      maxX = 30;
    }else if(dataRange == DataRange.TWO_WEEK){
      maxX = 14;
    }

    return Padding(
      padding: const EdgeInsets.all(6),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
              allowTouchBarBackDraw: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (groupData,a,rodData,b){
                  DateTime date = DateTime(
                    2020,
                    1,
                    30+groupData.x.toInt(),
                  );
                  return BarTooltipItem(
                    "${DateFormat("d MMM").format(date)}\n${NumberFormat(",##,###","hi_IN").format(rodData.y.toInt())}",
                    TextStyle(
                      fontFamily: kQuickSand,
                      fontSize: 12*scaleFactor,
                      color: theme.brightness == Brightness.light?Colors.white:Colors.black,
                    )
                  );
                },
                tooltipBgColor: theme.accentColor,
              ),
              touchCallback: (BarTouchResponse response){
                setState(() {
                  if (response.spot != null &&
                      response.touchInput is! FlPanEnd &&
                      response.touchInput is! FlLongPressEnd) {
                    //touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
                  } else {
                    //touchedIndex = -1;
                  }
                });
              }
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
                  interval: sideInterval,
                  getTitles: (double value){
                    if(value >= 10000000){
                      return '${(value).toInt().toString().substring(0,2)}m';
                    }else if(value>=1000000){
                      return '${(value).toInt().toString().substring(0,1)}.${(value).toInt().toString().substring(1,2)}m';
                    }else if(value>=100000){
                      return '${(value).toInt().toString().substring(0,3)}k';
                    }else if(value>=10000){
                      return '${(value).toInt().toString().substring(0,2)}k';
                    }else if(value>=1000){
                      return '${(value).toInt().toString().substring(0,1)}.${(value).toInt().toString().substring(1,2)}k';
                    }else{
                      return '${(value).toInt().toString()}';
                    }
                  },
                  textStyle: TextStyle(
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontSize: 10*scaleFactor,
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
                        now.day-maxX+value.toInt(),
                    );
                    return DateFormat("d MMM").format(returnDate);
                  },
                  textStyle: TextStyle(
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontSize: 8*scaleFactor,
                  )
              ),
            ),
            maxY: highest,
            backgroundColor: Colors.transparent,
            barGroups: barGroups,
            gridData: FlGridData(
                drawHorizontalLine: true,
                horizontalInterval: sideInterval,
                drawVerticalLine: true
            ),
          ),
        ),
      ),
    );
  }
}