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
  double scaleFactor = 1;
  int range = 0;

  int touchedIndex;
  ThemeData theme;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    AppLocalizations lang = AppLocalizations.of(context);

    theme = Theme.of(context);

    if(size.width<400){
      scaleFactor = 0.75;
    }else if(size.width<=450){
      scaleFactor = 0.9;
    }

    return FutureBuilder(
      future: StateWiseData.getIndiaTimeSeries(),
      builder: (BuildContext context, snapshot){

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
                lang.translate(kLoadingLang),
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

        List<FlSpot> totalCnfSpots = List();
        List<FlSpot> totalRecSpots = List();
        List<FlSpot> totalDetSpots = List();
        List<FlSpot> totalActiveSpots = List();


        double totalCnf = 0.0;
        double totalRec = 0.0;
        double totalDet = 0.0;
        double totalAct = 0.0;

        String dataRangeStr = "";

        if(dataRange == DataRange.BEGINNING){
          range = caseTime.length;
          dataRangeStr = lang.translate(kSinceBeginningLang);
        }else if(dataRange == DataRange.SIX_MONTHS){
          DateTime now = DateTime.now();
          DateTime sixMonthsAgo = DateTime(
            2020,
            now.month-6,
            now.day+1,
          );
          int time = (now.millisecondsSinceEpoch-sixMonthsAgo.millisecondsSinceEpoch).toInt();
          range = (time/(1000*60*60*24)).round();
          String str = DateFormat("d MMM yyyy").format(
            DateTime(
              2020,
              DateTime.now().month-6,
              DateTime.now().day+1,
            ),
          );
          if(lang.locale.languageCode == "hi"){
            dataRangeStr = "$str से";
          }else{
            dataRangeStr = "Since $str";
          }
        }else if(dataRange == DataRange.MONTH){
          range = 32;
          dataRangeStr = lang.translate(kLast30DaysLang);
        }else if(dataRange == DataRange.TWO_WEEK){
          range = 15;
          dataRangeStr = lang.translate(kLast14DaysLang);
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

        for(int i = (caseTime.length-range);i<max;i++){
          Map map = caseTime[i];
          double currentCnf = double.parse(map[kTotalConfirmed]);
          double currentRec = double.parse(map[kTotalRecovered]);
          double currentDet = double.parse(map[kTotalDeaths]);
          double currentAct = currentCnf-currentDet-currentRec;

          if(totalCnf < currentCnf){
            totalCnf = currentCnf;
          }
          if(totalRec < currentRec){
            totalRec = currentRec;
          }
          if(totalDet < currentDet){
            totalDet = currentDet;
          }
          if(totalAct < currentAct){
            totalAct = currentAct;
            print(totalAct);
          }

          totalCnfSpots.add(
              FlSpot(
                i.toDouble(),
                logarithmic?math.log(currentCnf)*math.log2e*1000:currentCnf,
              )
          );
          totalActiveSpots.add(
            FlSpot(
              i.toDouble(),
              logarithmic?math.log(currentAct)*math.log2e*1000:currentAct,
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


        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: 10*scaleFactor,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical:8.0,horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        lang.translate(kTotalCnfLang),
                        style: TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 25*scaleFactor,
                          color: kRedColor,
                        ),
                      ),
                      Text(
                        NumberFormat(",##,###","hi_IN").format(int.parse(map['total'][kConfirmed].toString())),
                        style: TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 25*scaleFactor,
                          color: kRedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16*scaleFactor,),
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
                                    height: 15*scaleFactor,
                                    width: 15*scaleFactor,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8,),
                                        ),
                                        color: kBlueColor
                                    ),
                                  ),
                                  SizedBox(width: 5*scaleFactor,),
                                  Text(
                                    lang.translate(kActiveLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                      fontSize: 16*scaleFactor
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
                                    height: 15*scaleFactor,
                                    width: 15*scaleFactor,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8,),
                                        ),
                                        color: kGreenColor
                                    ),
                                  ),
                                  SizedBox(width: 5*scaleFactor,),
                                  Text(
                                    lang.translate(kRecoveredLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                      fontSize: 16*scaleFactor,
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
                                    height: 15*scaleFactor,
                                    width: 15*scaleFactor,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8,),
                                        ),
                                        color: Colors.grey
                                    ),
                                  ),
                                  SizedBox(width: 5*scaleFactor,),
                                  Text(
                                    lang.translate(kDeathsLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                      fontSize: 16*scaleFactor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20*scaleFactor,),
                      Center(
                        child: _getPieChart(
                          double.parse(map["total"][kConfirmed]),
                          double.parse(map["total"][kActive]),
                          double.parse(map["total"][kRecovered]),
                          double.parse(map["total"][kDeaths]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8*scaleFactor,),
                Text(
                  lang.translate(kScalingModesLang),
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 25*scaleFactor,
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
                          fontSize: 16*scaleFactor,
                        ),
                      ),
                    ),
                    SizedBox(width: 5*scaleFactor,),
                    Switch(
                      value: uniformScale,
                      activeColor: theme.accentColor,
                      onChanged: (bool value){
                        setState(() {
                          uniformScale = value;
                        });
                      },
                    ),
                    SizedBox(width: 5*scaleFactor,),
                  ],
                ),
                SizedBox(height: 5*scaleFactor,),
                Text(
                  lang.translate(kShowingDataLang),
                  style: TextStyle(
                    color: kGreyColor,
                    fontFamily: kNotoSansSc,
                    fontSize: 16*scaleFactor,
                  ),
                ),
                SizedBox(height: 20*scaleFactor,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  elevation: 2,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
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
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: (){
                            setState(() {
                              if(dataRange != DataRange.SIX_MONTHS){
                                dataRange = DataRange.SIX_MONTHS;
                              }
                            });
                          },
                          child: Container(
                            height: 35*scaleFactor,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: dataRange != DataRange.SIX_MONTHS?theme.backgroundColor:theme.accentColor,
                            ),
                            child: Center(
                              child: Text(
                                lang.translate(kSixMonths),
                                style: TextStyle(
                                  fontFamily: kQuickSand,
                                  fontSize: 14*scaleFactor,
                                  color:dataRange != DataRange.SIX_MONTHS?
                                  theme.brightness == Brightness.light?Colors.black:Colors.white:
                                  theme.brightness == Brightness.light?Colors.white:Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
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
                      ),
                      Expanded(
                        child: InkWell(
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
                      ),
                    ],
                  ),
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
                          SizedBox(height: 5*scaleFactor,),
                          _getLineChart(totalCnfSpots, totalCnf, max),
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
                            lang.translate(kActiveCasesLang),
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
                          SizedBox(height: 5*scaleFactor,),
                          _getLineChart(totalActiveSpots, uniformScale?totalCnf:totalAct, max),
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
                          SizedBox(height: 5*scaleFactor,),
                          _getLineChart(totalRecSpots, uniformScale?totalCnf:totalRec, max),
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
                          SizedBox(height: 5*scaleFactor,),
                          _getLineChart(totalDetSpots, uniformScale?totalCnf:totalDet, max),
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
              title: touchedIndex == 0?"${NumberFormat(",##,###","hi_IN").format(active.toInt())}":"${((active/confirmed)*100).toString().substring(0,4)}%",
              titlePositionPercentageOffset: touchedIndex ==0 ?1.4:0.5,
              titleStyle: TextStyle(
                fontFamily: kQuickSand,
                fontSize: touchedIndex == 0?20*scaleFactor:12*scaleFactor,
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
              ),
              showTitle: true,
              radius: touchedIndex == 0?size.width*0.17:size.width*0.15,
            ),
            PieChartSectionData(
              value: recovered,
              color: kGreenColor,
              title: touchedIndex == 1?"${NumberFormat(",##,###","hi_IN").format(recovered.toInt())}":"${((recovered/confirmed)*100).toString().substring(0,4)}%",
              titlePositionPercentageOffset: touchedIndex == 1?1.3:0.5,
              titleStyle: TextStyle(
                fontFamily: kQuickSand,
                fontSize: touchedIndex == 1?20*scaleFactor:12*scaleFactor,
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
              ),
              radius: touchedIndex == 1?size.width*0.17:size.width*0.15,
              showTitle: true,
            ),
            PieChartSectionData(
              value: deaths,
              color: Colors.grey,
              title: touchedIndex == 2?"${NumberFormat(",##,###","hi_IN").format(deaths.toInt())}":"${((deaths/confirmed)*100).toString().substring(0,4)}%",
              titlePositionPercentageOffset: touchedIndex == 2?1.4:0.5,
              titleStyle: TextStyle(
                fontFamily: kQuickSand,
                fontSize: touchedIndex == 2?20*scaleFactor:12*scaleFactor,
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
    double dotSize = 2;

//    print(total);

    if(dataRange == DataRange.BEGINNING){
      bottomTitleInterval = (maxX/15).roundToDouble();
      dotSize = 0;
    }else if(dataRange == DataRange.SIX_MONTHS){
      bottomTitleInterval = 10;
      dotSize = 0;
    }else if(dataRange == DataRange.MONTH){
      bottomTitleInterval = 3;
    }else if(dataRange == DataRange.TWO_WEEK){
      bottomTitleInterval = 2;
    }


    sideInterval = (total/10);


    return Padding(
      padding: const EdgeInsets.all(6),
      child: AspectRatio(
        aspectRatio: 1.8,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> list){
                  List<LineTooltipItem> returnList = List();

                  list.forEach((element) {
                    DateTime date = DateTime(
                        2020,
                        1,
                        30+element.x.toInt(),
                    );
                    returnList.add(
                      LineTooltipItem(
                        "${DateFormat("d MMM").format(date)}\n${NumberFormat(",##,###","hi_IN").format(element.y.toInt())}",
                        TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 12*scaleFactor,
                          color: theme.brightness == Brightness.light?Colors.white:Colors.black,
                        ),
                      ),
                    );
                  });

                  return returnList;
                },
                tooltipBottomMargin: 50,
                tooltipBgColor: theme.accentColor,
              ),
              touchCallback: (LineTouchResponse touchResponse) {},
              handleBuiltInTouches: true,
            ),
            maxY: total+500,
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
                  interval: sideInterval,
                  reservedSize: total<1000?20:20*scaleFactor,
                  textStyle: TextStyle(
                    fontSize: 10*scaleFactor,
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontFamily: kNotoSansSc,
                  ),
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
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  rotateAngle: math.pi*90,
                  interval: bottomTitleInterval,
                  textStyle: TextStyle(
                    fontSize: 8*scaleFactor,
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontFamily: kNotoSansSc,
                  ),
                  getTitles: (double value){
                    DateTime returnDate = DateTime(
                        2020,
                        1,
                        30+value.toInt(),
                    );
                    return DateFormat("d MMM").format(returnDate);
                  },
                )
            ),
            lineBarsData: [
              LineChartBarData(
                dotData: FlDotData(
                  dotSize: dotSize,
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
