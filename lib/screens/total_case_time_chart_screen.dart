import 'dart:math' as math;

import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/utilities/data_range.dart';
import 'package:covid19_tracker/data/state_wise_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  ThemeData theme;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;


    theme = Theme.of(context);

    if(size.width <= 360){
      textScaleFactor = 0.75;
    }

    return FutureBuilder(
      future: StateWiseData.getInstance(),
      builder: (BuildContext context, snapshot){

        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
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

        print(totalCnf);
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
                        'Uniform Scale',
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
                                    'Beginning',
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                      fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.all(8),
      child: AspectRatio(
        aspectRatio: 2,
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
                  reservedSize: total<1000?20:30,
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
