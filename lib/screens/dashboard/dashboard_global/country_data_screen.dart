/*
*
* Individual countries information
*
*/


import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/custom_widgets/custom_widgets.dart';
import 'package:covid19_tracker/utilities/models/country.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../error_screen.dart';

class CountryDataScreen extends StatefulWidget{

  final Country country;

  CountryDataScreen(this.country);

  @override
  _CountryDataScreen createState() {
    return _CountryDataScreen(country);
  }
}

class _CountryDataScreen extends State<CountryDataScreen>{

  final Country country;
  double textScaleFactor = 1;
  ThemeData theme;
  bool logarithmic = false;

  _CountryDataScreen(this.country);

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    AppLocalizations lang = AppLocalizations.of(context);

    if(size.width<=360){
      textScaleFactor = 0.75;
    }

    theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            country.displayName,
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 30*textScaleFactor,
                            ),
                          ),
                          Container(
                            height: 30,
                            width: 60,
                            child: Image(
                              fit: BoxFit.contain,
                              image: NetworkImage(
                                country.flagLink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${lang.translate(kLastUpdatedAtLang)}: ${DateFormat("d MMM, ").add_jm().format(country.updated)}",
                        style: TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 14*textScaleFactor,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          DashboardTile(
                            mainTitle: lang.translate(kTotalCnfLang),
                            value: country.totalCases.toString(),
                            delta: country.todayCases.toString(),
                            color: kRedColor,
                          ),
                          SizedBox(width: 10,),
                          DashboardTile(
                            mainTitle: lang.translate(kTotalActvLang),
                            value: country.active.toString(),
                            delta: "",
                            color: kBlueColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          DashboardTile(
                            mainTitle: lang.translate(kTotalRecLang),
                            value: country.deaths.toString(),
                            delta: "",
                            color: kGreenColor,
                          ),
                          SizedBox(width: 10,),
                          DashboardTile(
                            mainTitle: lang.translate(kTotalDetLang),
                            value: country.recovered.toString(),
                            delta: country.todayDeaths.toString(),
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          DashboardTile(
                            mainTitle: lang.translate(kCriticalLang),
                            value: country.critical.toString(),
                            delta: "",
                            color: kGreyColor,
                          ),
                          SizedBox(width: 10,),
                          DashboardTile(
                            mainTitle: lang.translate(kMildCasesLang),
                            value: country.mild.toString(),
                            delta: "",
                            color: kGreyColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          DashboardTile(
                            mainTitle: lang.translate(kTotalTestedLang),
                            value: country.tests.toString(),
                            delta: "",
                            color: kGreyColor,
                          ),
                          SizedBox(width: 10,),
                          DashboardTile(
                            mainTitle: lang.translate(kTestsPerMillionLang),
                            value: country.testPerOneMil.toString(),
                            delta: "",
                            color: kGreyColor,
                          ),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          DashboardTile(
                            mainTitle: lang.translate(kCasesPerMillionLang),
                            value: country.casesPerOneMil.toString(),
                            delta: "",
                            color: kGreyColor,
                          ),
                          SizedBox(width: 10,),
                          DashboardTile(
                            mainTitle: lang.translate(kDeathsPerMillionLang),
                            value: country.deathsPerOneMil.toString(),
                            delta: "",
                            color: kGreyColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24,),
                FutureBuilder(
                  future: NetworkHandler.getInstance().getCountryData(country.countryName),
                  builder: (BuildContext context,snapshot){

                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Container(height:size.width,child: Center(child: CircularProgressIndicator(),));
                    }
                    if(snapshot.hasError){
                      return Center(
                        child: ErrorScreen(
                          onClickRetry: (){
                            setState(() {
                              // Future builder will rebuild itself and check for future.
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
                              // Future builder will rebuild itself and check for future.
                            });
                          },
                        ),
                      );
                    }


                    //Charts data Processing

                    Map countriesDailyReport = snapshot.data;

                    if(!countriesDailyReport.containsKey("timeline")){
                      return Center(
                        child: Text(
                          lang.locale.languageCode=="hi"?
                          "${country.displayName} ${lang.translate(kCountryDataErrorLang)}":
                          "${lang.translate(kCountryDataErrorLang)} ${country.displayName}",
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            color: theme.accentColor,
                          ),
                        ),
                      );
                    }
                    Map casesTimeline = countriesDailyReport['timeline'][kCountryTotalCases];
                    Map deathsTimeline = countriesDailyReport['timeline'][kCountryDeaths];
                    Map recoveryTimeline = countriesDailyReport['timeline'][kCountryRecovered];
                    
                    
                    

                    int totalCnf = 0;
                    int totalRec = 0;
                    int totalDet = 0;

                    List<FlSpot> cnfSpots = List();
                    List<FlSpot> recSpots = List();
                    List<FlSpot> detSpots = List();

                    int dailyHighestCnf = 0;
                    List<BarChartGroupData> dailyConfirmedChartGroup = List();

                    int dailyHighestRec = 0;
                    List<BarChartGroupData> dailyRecChartGroup = List();

                    int dailyHighestDet = 0;
                    List<BarChartGroupData> dailyDetChartGroup = List();

                    int range = 30;

                    int i = 0;
                    double prev = 0;


                    casesTimeline.forEach((key,value){
                      if(casesTimeline.length-range<=i){
                        cnfSpots.add(
                            FlSpot(
                              i.toDouble(),
                              double.parse(value.toString()),
                            ),
                        );
                        double current = double.parse(value.toString())-prev;
                        dailyConfirmedChartGroup.add(
                          BarChartGroupData(
                            x: i,
                            showingTooltipIndicators: [],
                            barRods: [
                              BarChartRodData(
                                y: current<0?0:current,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                                color: theme.accentColor,
                                width: 5,
                              ),
                            ],
                          ),
                        );
                        if(value-prev.toInt()>dailyHighestCnf){
                          dailyHighestCnf = value-prev.toInt();
                        }
                      }
                      totalCnf = value;
                      i++;
                      prev = double.parse(value.toString());
                    });

                    i=0;
                    prev = 0;

                    deathsTimeline.forEach((key,value){
                      if(casesTimeline.length-range<=i){
                        detSpots.add(
                            FlSpot(
                              i.toDouble(),
                              double.parse(value.toString()),
                            ),
                        );
                        double current = double.parse(value.toString())-prev;
                        dailyDetChartGroup.add(
                          BarChartGroupData(
                            x: i,
                            showingTooltipIndicators: [],
                            barRods: [
                              BarChartRodData(
                                y: current<0?0:current,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                                color: theme.accentColor,
                                width: 5,
                              ),
                            ],
                          ),
                        );
                        if(value-prev.toInt()>dailyHighestDet){
                          dailyHighestDet = value-prev.toInt();
                        }
                      }
                      totalDet = value;
                      i++;
                      prev = double.parse(value.toString());
                    });

                    i=0;
                    prev = 0;

                    recoveryTimeline.forEach((key,value){
                      if(casesTimeline.length-range<=i){
                        recSpots.add(
                            FlSpot(
                              i.toDouble(),
                              double.parse(value.toString()),
                            ),
                        );
                        double current = double.parse(value.toString())-prev;
                        dailyRecChartGroup.add(
                          BarChartGroupData(
                            x: i,
                            showingTooltipIndicators: [],
                            barRods: [
                              BarChartRodData(
                                y: current<0?0:current,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  topLeft: Radius.circular(10),
                                ),
                                color: theme.accentColor,
                                width: 5,
                              ),
                            ],
                          ),
                        );
                        if(value-prev.toInt()>dailyHighestRec){
                          dailyHighestRec = value-prev.toInt();
                        }
                      }
                      totalRec = value;
                      i++;
                      prev = double.parse(value.toString());
                    });

                    List<Widget> lineChartLayouts = List();

                    lineChartLayouts.add(
                      _getLineChartLayout(lang.translate(kConfirmedLang),cnfSpots, totalCnf.toDouble(), cnfSpots.length),
                    );

                    if(country.recovered != 0){
                      lineChartLayouts.add(
                        _getLineChartLayout(lang.translate(kRecoveredLang),recSpots, totalRec.toDouble(), recSpots.length),
                      );
                    }

                    lineChartLayouts.add(
                      _getLineChartLayout(lang.translate(kDeathsLang),detSpots, totalDet.toDouble(), detSpots.length),
                    );

                    List<Widget> barChartLayouts = List();

                    barChartLayouts.add(
                      _getBarChartLayout(lang.translate(kDailyCnfLang), dailyConfirmedChartGroup, (dailyHighestCnf+1000).toDouble(),dailyConfirmedChartGroup.length),
                    );

                    if(country.recovered != 0){
                      barChartLayouts.add(
                        _getBarChartLayout(lang.translate(kDailyRecLang), dailyRecChartGroup, (dailyHighestRec+1000).toDouble(),dailyRecChartGroup.length),
                      );
                    }

                    barChartLayouts.add(
                      _getBarChartLayout(lang.translate(kDailyDetLang), dailyDetChartGroup, (dailyHighestDet+500).toDouble(),dailyDetChartGroup.length),
                    );









                    return Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    lang.translate(kSpreadTrendsLang),
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                      fontSize: 25*textScaleFactor,
                                    ),
                                  ),
                                  Text(
                                    lang.translate(kLast30DaysLang),
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontFamily: kQuickSand,
                                      fontSize: 16*textScaleFactor,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10,),
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  child: Center(
                                    child: Icon(
                                      SimpleLineIcons.arrow_right,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          height: size.width*0.7,
                          width: size.width,
                          child: Center(
                            child: PageView.builder(
                                itemCount: lineChartLayouts.length,
                                scrollDirection: Axis.horizontal,
                                controller: PageController(
                                  initialPage: 0,
                                  viewportFraction: 0.95,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return lineChartLayouts[index];
                                }
                            ),
                          ),
                        ),
                        Container(
                          height: size.width*0.7,
                          width: size.width,
                          child: Center(
                            child: PageView.builder(
                                itemCount: barChartLayouts.length,
                                scrollDirection: Axis.horizontal,
                                controller: PageController(
                                  initialPage: 0,
                                  viewportFraction: 0.95,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return barChartLayouts[index];
                                }
                            ),
                          ),
                        ),
                      ],
                    );

                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBarChartLayout(String caseStr,List<BarChartGroupData> barGroups,double highest,int maxX){
    return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
            child: Material(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              elevation: 2,
              color: theme.backgroundColor,
              shadowColor: Colors.black,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      caseStr,
                      style: TextStyle(
                        fontFamily: kQuickSand,
                        fontSize: 25*textScaleFactor,
                      ),
                    ),
                    SizedBox(height: 20,),
                    _getBarChart(barGroups, highest,maxX)
                  ],
                ),
              ),
            ),
          ),
        ]
    );
  }

  Widget _getLineChartLayout(String caseStr,List<FlSpot> spots,double total,int maxX){
    return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 5),
            child: Material(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              elevation: 2,
              color: theme.backgroundColor,
              shadowColor: Colors.black,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      caseStr,
                      style: TextStyle(
                        fontFamily: kQuickSand,
                        fontSize: 25*textScaleFactor,
                      ),
                    ),
                    SizedBox(height: 20,),
                    _getLineChart(spots,total,maxX),
                  ],
                ),
              ),
            ),
          ),
        ]
    );
  }


  Widget _getBarChart(List<BarChartGroupData> barGroups,double highest,int maxX){
    return Padding(
      padding: const EdgeInsets.all(8),
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
                  interval: highest<10000?highest<1000?200:1000:highest>=50000?25000:10000,
                  getTitles: (double value){
                    if(value<10000 && value>=1000){
                      return '${(value).toString().substring(0,1)}k';
                    }else if (value>=10000 && value<100000){
                      return '${(value).toString().substring(0,2)}k';
                    }else if(value>=100000){
                      return '${(value).toString().substring(0,1)}m';
                    }else{
                      return '${(value).toInt().toString()}';
                    }
                  },
                  textStyle: TextStyle(
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontSize: 10*textScaleFactor,
                  )
              ),
              bottomTitles: SideTitles(
                  rotateAngle: math.pi*90,
                  interval: 5,
                  showTitles: true,
                  getTitles: (double value){
                    DateTime now = DateTime.now();
                    DateTime returnDate = DateTime(
                        2020,
                        now.month,
                        now.day-maxX+value.toInt()-1
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
                horizontalInterval: highest<10000?highest<1000?200:1000:highest>=50000?25000:10000,
                drawVerticalLine: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getLineChart(List<FlSpot> spots,double total,int maxX){

    //total<=10000?total<=5000?total<500?total<100?50:100:500:5000:total<=50000?10000:total<=100000?25000:total>500000?100000:50000;

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
            maxY: total<500?total+200:total+2000,
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
              horizontalInterval: total<=10000?total<=5000?total<500?total<100?50:100:500:5000:total<=50000?10000:total<=100000?25000:total>500000?100000:50000,
            ),
            titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: false,
                ),
                rightTitles: SideTitles(
                    showTitles: true,
                    interval: logarithmic?math.log(2000)*math.log2e*1000:total<=10000?total<=5000?total<500?total<100?50:100:500:5000:total<=50000?10000:total<=100000?25000:total>500000?100000:50000,
                    reservedSize: total<=10000?20:total<=50000?20:20,
                    textStyle: TextStyle(
                      fontSize: 10*textScaleFactor,
                      color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                      fontFamily: kNotoSansSc,
                    ),
                    getTitles: (double value){
                      if(value<10000 && value>=1000){
                        return '${(value).toString().substring(0,1)}k';
                      }else if (value>=10000 && value<100000){
                        return '${(value).toString().substring(0,2)}k';
                      }else if(value>=100000){
                        return '${(value).toString().substring(0,1)}m';
                      }else{
                        return '${(value).toInt().toString()}';
                      }
                    }
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  rotateAngle: math.pi*90,
                  interval: 1,
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
                        now.day-maxX+value.toInt()-1
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
                isCurved: false,
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