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

class TotalCaseTimeChart extends StatefulWidget{
  @override
  _TotalCaseTimeChartState createState() {
    return _TotalCaseTimeChartState();
  }
}

class _TotalCaseTimeChartState extends State<TotalCaseTimeChart>{

  bool logarithmic = false;
  bool uniformScale = true;
  String dataRange = DataRange.MONTH;
  double textScaleFactor = 1;

  int touchedIndex;
  ThemeData theme;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    AppLocalizations lang = AppLocalizations.of(context);

    theme = Theme.of(context);

    if(size.width <= 360){
      textScaleFactor = 0.75;
    }

    return FutureBuilder(
      future: StateWiseData.getInstance(),
      builder: (BuildContext context, snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
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
        List caseTime = map[kCaseTimeSeries];

        List<FlSpot> totalCnfSpots = List();
        List<FlSpot> totalRecSpots = List();
        List<FlSpot> totalDetSpots = List();


        double totalCnf = 0.0;
        double totalRec = 0.0;
        double totalDet = 0.0;

        int range = 0;

        if(dataRange == DataRange.BEGINNING){
          range = caseTime.length;
        }else if(dataRange == DataRange.MONTH){
          range = 31;
        }else if(dataRange == DataRange.TWO_WEEK){
          range = 14;
        }

        String lastUpdate = "";

        for(int i = (caseTime.length-range);i<caseTime.length;i++){
          Map map = caseTime[i];
          double currentCnf = double.parse(map[kTotalConfirmed]);
          double currentRec = double.parse(map[kTotalRecovered]);
          double currentDet = double.parse(map[kTotalDeaths]);
          if(i==caseTime.length-1){
            totalCnf = currentCnf;
            totalRec = currentRec;
            totalDet = currentDet;
          }
          totalCnfSpots.add(
              FlSpot(
                i.toDouble(),
                logarithmic?math.log(currentCnf)*math.log2e*1000:currentCnf,
              )
          );
          totalRecSpots.add(
            FlSpot(
              i.toDouble(),
              logarithmic?currentRec==0?0:math.log(currentRec)*100:currentRec,
            ),
          );
          totalDetSpots.add(
              FlSpot(
                i.toDouble(),
                logarithmic?currentDet==0?0:math.log(currentDet)*100:currentDet,
              )
          );
          if(i == caseTime.length-1){
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
                SizedBox(height: 10,),
                Text(
                  "${lang.translate(kLastUpdatedAtLang)}: $lastUpdate\2020",
                  style: TextStyle(
                    color: kGreenColor,
                    fontSize: 16*textScaleFactor,
                    fontFamily: kQuickSand,
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:8.0,horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        lang.translate(kTotalCnfLang),
                        style: TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 25*textScaleFactor,
                          color: kRedColor,
                        ),
                      ),
                      Text(
                        map[kStateWise][0][kConfirmed],
                        style: TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 25*textScaleFactor,
                          color: kRedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16,),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        width: size.width*0.4,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8,),
                                        ),
                                        color: kBlueColor
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                    lang.translate(kActiveLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8,),
                                        ),
                                        color: kGreenColor
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                    lang.translate(kRecoveredLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8,),
                                        ),
                                        color: Colors.grey
                                    ),
                                  ),
                                  SizedBox(width: 5,),
                                  Text(
                                    lang.translate(kDeathsLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                        child: _getPieChart(
                          double.parse(map[kStateWise][0][kConfirmed]),
                          double.parse(map[kStateWise][0][kActive]),
                          double.parse(map[kStateWise][0][kRecovered]),
                          double.parse(map[kStateWise][0][kDeaths]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8,),
                Text(
                  lang.translate(kScalingModesLang),
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 25*textScaleFactor,
                  ),
                ),
//                SizedBox(height: 10,),
//                Row(
//                  children: <Widget>[
//                    Expanded(
//                      child: Text(
//                        'Logarithmic',
//                        style: TextStyle(
//                          color: kGreyColor,
//                          fontFamily: kNotoSansSc,
//                          fontSize: 16*textScaleFactor,
//                        ),
//                      ),
//                    ),
//                    SizedBox(width: 5,),
//                    Switch(
//                      value: logarithmic,
//                      activeColor: theme.accentColor,
//                      onChanged: (bool value){
//                        setState(() {
//                          logarithmic = value;
//                        });
//                      },
//                    ),
//                    SizedBox(width: 5,),
//                  ],
//                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        lang.translate(kUniformScaleLang),
                        style: TextStyle(
                          color: kGreyColor,
                          fontFamily: kNotoSansSc,
                          fontSize: 16*textScaleFactor,
                        ),
                      ),
                    ),
                    SizedBox(width: 5,),
                    Switch(
                      value: uniformScale,
                      activeColor: theme.accentColor,
                      onChanged: (bool value){
                        setState(() {
                          uniformScale = value;
                        });
                      },
                    ),
                    SizedBox(width: 5,),
                  ],
                ),
                SizedBox(height: 5,),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        lang.translate(kShowingDataLang),
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
                      child: Container(
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
                                    lang.translate(kBeginningLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                      color: dataRange != DataRange.BEGINNING?
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
                                    lang.translate(k1MonthLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
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
                                    lang.translate(k2WeekLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
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
                    ),
                    SizedBox(width: 10,),
                  ],
                ),
                SizedBox(height: 20,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: theme.backgroundColor,
                  elevation: 2,
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
                              fontSize: 25*textScaleFactor,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*textScaleFactor,
                            ),
                          ),
                          SizedBox(height: 5,),
                          _getLineChart(totalCnfSpots, totalCnf, caseTime.length),
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
                  color: theme.backgroundColor,
                  elevation: 2,
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
                              fontSize: 25*textScaleFactor,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*textScaleFactor,
                            ),
                          ),
                          SizedBox(height: 5,),
                          _getLineChart(totalRecSpots, uniformScale?totalCnf:totalRec, caseTime.length),
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
                  color: theme.backgroundColor,
                  elevation: 2,
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
                              fontSize: 25*textScaleFactor,
                            ),
                          ),
                          Text(
                            dataRangeStr,
                            style: TextStyle(
                              color: kGreyColor,
                              fontFamily: kQuickSand,
                              fontSize: 16*textScaleFactor,
                            ),
                          ),
                          SizedBox(height: 5,),
                          _getLineChart(totalDetSpots, uniformScale?totalCnf:totalDet, caseTime.length),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _getPieChart(double confirmed, double active, double recovered, double deaths){

    Size size = MediaQuery.of(context).size;
    AppLocalizations lang = AppLocalizations.of(context);

    return PieChart(
      PieChartData(
          centerSpaceRadius: size.width*0.125,
          sectionsSpace: 0,
          pieTouchData: PieTouchData(
            enabled: true,
            touchCallback: (PieTouchResponse response){
              setState(() {
                if (response.touchInput is FlLongPressEnd ||
                    response.touchInput is FlPanEnd) {
                  touchedIndex = -1;
                } else {
                  touchedIndex = response.touchedSectionIndex;
                }
              });
            }
          ),
          borderData: FlBorderData(
            show: false,
          ),
          startDegreeOffset: 0,
          sections: [
            PieChartSectionData(
              value: active,
              color: kBlueColor,
              title: touchedIndex == 0?"${active.toInt()}":"${((active/confirmed)*100).toString().substring(0,4)}%",
              titlePositionPercentageOffset: touchedIndex ==0 ?1.4:0.5,
              titleStyle: TextStyle(
                fontFamily: kQuickSand,
                fontSize: touchedIndex == 0?20:12,
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
              ),
              showTitle: true,
              radius: touchedIndex == 0?size.width*0.17:size.width*0.15,
            ),
            PieChartSectionData(
              value: recovered,
              color: kGreenColor,
              title: touchedIndex == 1?"${recovered.toInt()}":"${((recovered/confirmed)*100).toString().substring(0,4)}%",
              titlePositionPercentageOffset: touchedIndex == 1?1.4:0.5,
              titleStyle: TextStyle(
                fontFamily: kQuickSand,
                fontSize: touchedIndex == 1?20:12,
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
              ),
              radius: touchedIndex == 1?size.width*0.17:size.width*0.15,
              showTitle: true,
            ),
            PieChartSectionData(
              value: deaths,
              color: Colors.grey,
              title: touchedIndex == 2?"${deaths.toInt()}":"${((deaths/confirmed)*100).toString().substring(0,4)}%",
              titlePositionPercentageOffset: touchedIndex == 2?1.5:0.5,
              titleStyle: TextStyle(
                fontFamily: kQuickSand,
                fontSize: touchedIndex == 2?20:12,
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
              ),
              radius: touchedIndex == 2?size.width*0.17:size.width*0.15,
              showTitle: true,
            ),
          ]
      ),
    );

  }

  Widget _getLineChart(List<FlSpot> spots,double total,int maxX){
    double bottomTitleInterval = 0;
    double sideInterval = 0;
    double multiplier = 0;

    if(dataRange == DataRange.BEGINNING){
      bottomTitleInterval = 6;
    }else if(dataRange == DataRange.MONTH){
      bottomTitleInterval = 3;
    }else if(dataRange == DataRange.TWO_WEEK){
      bottomTitleInterval = 1;
    }

    if(uniformScale && total>3000){
      sideInterval = 2000;
      multiplier = 1000;
    }else if(!uniformScale && total>3000){
      sideInterval = 2000;
      multiplier = 1000;
    }else if(!uniformScale && total>1000){
      sideInterval = 1000;
      multiplier = 100;
    }else{
      sideInterval = 200;
      multiplier = 100;
    }


    return Padding(
      padding: const EdgeInsets.all(6),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBottomMargin: 50,
                tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              ),
              touchCallback: (LineTouchResponse touchResponse) {},
              handleBuiltInTouches: true,
            ),
            maxY: total<2000?total+200:total+2000,
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
            gridData: FlGridData(
              drawHorizontalLine: true,
              horizontalInterval: logarithmic?math.log(sideInterval)*multiplier:sideInterval,
            ),
            titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: false,
                ),
                rightTitles: SideTitles(
                  showTitles: true,
                  interval: logarithmic?math.log(sideInterval)*multiplier:sideInterval,
                  reservedSize: total<1000?20:20,
                  textStyle: TextStyle(
                    fontSize: 10*textScaleFactor,
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontFamily: kNotoSansSc,
                  ),
                  getTitles: (double value){

                    if(!logarithmic){
                      if(value>=10000){
                        return '${(value).toString().substring(0,2)}k';
                      }else if(value<10000 && value>=1000){
                        return '${(value).toString().substring(0,1)}k';
                      }else{
                        return (value).toInt().toString();
                      }
                    }else{
                      if(value>=10000){
                        return '${(value).toString().substring(0,2)}k';
                      }else if(value<10000 && value>=1000){
                        return '${(value).toString().substring(0,1)}k';
                      }else{
                        return (value).toInt().toString();
                      }
                    }

                  },
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  rotateAngle: math.pi*90,
                  interval: bottomTitleInterval,
                  textStyle: TextStyle(
                    fontSize: 8*textScaleFactor,
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontFamily: kNotoSansSc,
                  ),
                  getTitles: (double value){
                    DateTime now = DateTime.now();
                    DateTime returnDate = DateTime(
                        2020,
                        now.month,
                        now.day-maxX+value.toInt()
                    );
                    return DateFormat("d MMM").format(returnDate);
                  },
                )
            ),
            lineBarsData: [
              LineChartBarData(
                dotData: FlDotData(
                  dotSize: 2,
                  strokeWidth: 0,
                ),
                isCurved: true,
                barWidth: 2,
                isStrokeCapRound: true,
                colors: [theme.accentColor],
                spots: spots,
              ),
            ],
          ),
        ),
      ),
    );
  }

}
