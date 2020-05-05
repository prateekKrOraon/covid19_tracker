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
import 'package:covid19_tracker/utilities/analytics/math_functions.dart';
import 'package:covid19_tracker/utilities/custom_widgets/custom_widgets.dart';
import 'package:covid19_tracker/utilities/helpers/data_range.dart';
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
  String dataRange = DataRange.MONTH;
  String dataRangeStr = "";

  _CountryDataScreen(this.country);

  @override
  void initState() {
    _getCountryData();
    super.initState();
  }
  Future _countryData;
  _getCountryData(){
    _countryData = NetworkHandler.getInstance().getCountryData(country.iso3);
  }

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
                  future: _countryData,
                  builder: (BuildContext context,snapshot){

                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Container(height:100,child: Center(child: CircularProgressIndicator(),));
                    }
                    if(snapshot.hasError){
                      return Container(
                        height: 100,
                        child: Center(
                          child: Text(
                            lang.locale.languageCode=="hi"?
                            "${country.displayName} ${lang.translate(kCountryDataErrorLang)}":
                            "${lang.translate(kCountryDataErrorLang)} ${country.displayName}",
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              color: theme.accentColor,
                            ),
                          ),
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
                    double prevCnf = 0;
                    double prevRec = 0;
                    double prevDet = 0;

                    Map result = snapshot.data['result'];

                    if(dataRange == DataRange.BEGINNING){
                      range = result.length;
                      dataRangeStr = lang.translate(kSinceBeginningLang);
                    }else if(dataRange == DataRange.MONTH){
                      range = 30;
                      dataRangeStr = lang.translate(kLast30DaysLang);
                    }else if(dataRange == DataRange.TWO_WEEK){
                      range = 14;
                      dataRangeStr = lang.translate(kLast14DaysLang);
                    }

                    List<double> confirmedCases = List();

                    result.forEach((key, value) {
                      if(result.length-range<=i){
                        cnfSpots.add(
                          FlSpot(
                            (i-(result.length-range)).toDouble(),
                            double.parse(value[kConfirmed].toString()),
                          ),
                        );
                        double current = double.parse(value[kConfirmed].toString())-prevCnf;
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
                                width: dataRange == DataRange.BEGINNING?1:5,
                              ),
                            ],
                          ),
                        );
                        if(current>dailyHighestCnf){
                          dailyHighestCnf = (current).toInt();
                        }

                        detSpots.add(
                          FlSpot(
                            (i-(result.length-range)).toDouble(),
                            double.parse(value[kDeaths].toString()),
                          ),
                        );
                        current = double.parse(value[kDeaths].toString())-prevDet;
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
                                width: dataRange == DataRange.BEGINNING?1:5,
                              ),
                            ],
                          ),
                        );
                        if(current>dailyHighestDet){
                          dailyHighestDet = (current).toInt();
                        }

                        recSpots.add(
                          FlSpot(
                            (i-(result.length-range)).toDouble(),
                            double.parse(value[kRecovered].toString()),
                          ),
                        );
                        current = double.parse(value[kRecovered].toString())-prevRec;
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
                                width: dataRange == DataRange.BEGINNING?1:5,
                              ),
                            ],
                          ),
                        );
                        if(current>dailyHighestRec){
                          dailyHighestRec = (current).toInt();
                        }
                      }
                      confirmedCases.add(double.parse(value[kConfirmed].toString()));
                      prevCnf = double.parse(value[kConfirmed].toString());
                      prevDet = double.parse(value[kDeaths].toString());
                      prevRec = double.parse(value[kRecovered].toString());
                      i++;
                    });


                    // More Analysis
                    MathFunctions functions = MathFunctions();
                    //functions.parseData(map);
                    List<double> growthFactors = functions.growthFactor(confirmedCases);


                    List<FlSpot> spots = List();
                    double highest = 0;
                    i = 0;
                    for(int i = growthFactors.length-range; i<growthFactors.length;i++){
                      double element = growthFactors[i];
                      if(element > highest){
                        highest = element;
                      }
                      spots.add(
                          FlSpot(
                            (i-(growthFactors.length-range)).toDouble(),
                            element,
                          )
                      );
                    }

                    List<double> growthRatios = functions.growthRatio(confirmedCases);
                    List<FlSpot> grSpots = List();
                    double grHighest = 0;
                    for(int i = growthRatios.length-range; i<growthRatios.length;i++){
                      double element = growthRatios[i];
                      if(element > grHighest){
                        grHighest = element;
                      }
                      grSpots.add(
                        FlSpot(
                          (i-(growthRatios.length-range)).toDouble(),
                          element,
                        ),
                      );
                    }

                    //functions.getLog(functions.confirmedTimeSeries)
                    List<double> growthRates = functions.gradient(functions.getLog(confirmedCases));
                    List<FlSpot> gRSpots = List();
                    double gRHighest = 0;
                    for(int i = growthRates.length-range; i<growthRates.length;i++){
                      double element = growthRates[i];
                      if(element > gRHighest){
                        gRHighest = element;
                      }
                      gRSpots.add(
                        FlSpot(
                          (i-(growthRates.length-range)).toDouble(),
                          element,
                        ),
                      );
                    }

                    List<double> secondDerivative = functions.gradient(functions.gradient(confirmedCases));
                    List<FlSpot> sdSpots = List();
                    double sdHighest = 0;
                    for(int i = secondDerivative.length-range; i<secondDerivative.length;i++){
                      double element = secondDerivative[i];
                      if(element > sdHighest){
                        sdHighest = element;
                      }
                      sdSpots.add(
                        FlSpot(
                          (i-(secondDerivative.length-range)).toDouble(),
                          element,
                        ),
                      );
                    }

                    List<Widget> moreCharts = List();
                    moreCharts.add(
                      _getLineChartLayout("Growth Factor", spots, highest, range,more: true),
                    );
                    moreCharts.add(
                      _getLineChartLayout("Growth Ratio", grSpots, grHighest, range,more: true),
                    );
                    moreCharts.add(
                      _getLineChartLayout("Growth Rate", gRSpots, gRHighest, range,more: true),
                    );
                    moreCharts.add(
                      _getLineChartLayout("Second Derivative", sdSpots, sdHighest, range,more: true),
                    );

                    List<Widget> lineChartLayouts = List();

                    lineChartLayouts.add(
                      _getLineChartLayout(lang.translate(kConfirmedLang),cnfSpots, prevCnf.toDouble(), cnfSpots.length),
                    );

                    if(country.recovered != 0){
                      lineChartLayouts.add(
                        _getLineChartLayout(lang.translate(kRecoveredLang),recSpots, prevRec.toDouble(), recSpots.length),
                      );
                    }

                    lineChartLayouts.add(
                      _getLineChartLayout(lang.translate(kDeathsLang),detSpots, prevDet.toDouble(), detSpots.length),
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
                                    dataRangeStr,
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
                        Container(
                          height: size.width*0.8,
                          width: size.width,
                          child: Center(
                            child: PageView.builder(
                                itemCount: moreCharts.length,
                                scrollDirection: Axis.horizontal,
                                controller: PageController(
                                  initialPage: 0,
                                  viewportFraction: 0.95,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return moreCharts[index];
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

  Widget _getLineChartLayout(String caseStr,List<FlSpot> spots,double total,int maxX,{bool more=false}){
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
                    more?_getLineChartForMoreAnalysis(spots, total, maxX):_getLineChart(spots,total,maxX),
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
                  interval: highest<10000?highest<1000?200:1000:highest>=50000?25000:5000,
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
                  interval: dataRange == DataRange.BEGINNING?10:1,
                  showTitles: dataRange != DataRange.BEGINNING,
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
                    fontSize: 8*textScaleFactor,
                  )
              ),
            ),
            maxY: highest,
            backgroundColor: Colors.transparent,
            barGroups: barGroups,
            gridData: FlGridData(
                drawHorizontalLine: true,
                horizontalInterval: highest<10000?highest<1000?200:1000:highest>=50000?25000:5000,
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
                  interval: dataRange == DataRange.BEGINNING?10:1,
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
                        now.day-maxX+value.toInt(),
                    );
                    return DateFormat("d MMM").format(returnDate);
                  },
                )
            ),
            lineBarsData: [
              LineChartBarData(
                dotData: FlDotData(
                  dotSize: dataRange == DataRange.BEGINNING?0:2,
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


  Widget _getLineChartForMoreAnalysis(List<FlSpot> spots,double total,int maxX){
    double bottomTitleInterval = 0;
    double sideInterval = 2;
    double multiplier = 0;
    double maxY = 0;



    if(dataRange == DataRange.BEGINNING){
      bottomTitleInterval = 6;
    }else if(dataRange == DataRange.MONTH){
      bottomTitleInterval = 3;
    }else if(dataRange == DataRange.TWO_WEEK){
      bottomTitleInterval = 1;
    }

    if(total>3000){
      sideInterval = 700;
      maxY = total+500;
    }else if(total>2000){
      sideInterval = 500;
      maxY = total+500;
    }else if(total > 500){
      sideInterval = 300;
      maxY = total+250;
    }else if(total >100){
      sideInterval = 100;
      maxY = total+50;
    }else if(total > 50){
      sideInterval = 20;
      maxY = total+25;
    }else if(total > 10){
      sideInterval = 10;
      maxY = total+5;
    }else if(total > 6){
      sideInterval = 1;
      maxY = total+500+3;
    }else if(total > 3){
      sideInterval = 1;
      maxY = total+1.5;
    }else if (total > 1){
      sideInterval = 0.4;
      maxY = total+0.5;
    }else if(sideInterval>0.5){
      sideInterval = 0.1;
      maxY = total+0.25;
    }else{
      sideInterval = 0.01;
      maxY = total;
    }


    return Padding(
      padding: const EdgeInsets.all(6),
      child: AspectRatio(
        aspectRatio: 1.5,
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
            maxY: maxY,
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
              horizontalInterval: sideInterval,
            ),
            titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: false,
                ),
                rightTitles: SideTitles(
                  showTitles: true,
                  interval: sideInterval,
                  reservedSize: total>1000?30:20,
                  textStyle: TextStyle(
                    fontSize: 10*textScaleFactor,
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontFamily: kNotoSansSc,
                  ),
                  getTitles: (double value){
                    String val = value.toString();

                    if(value>0){
                      if(val.length<4){
                        val = val.substring(0,3);
                      }else if(val.length>=6){
                        val = val.substring(0,6);
                      }if(val.length>=4){
                        val = val.substring(0,4);
                      }
                    }else if(value<0){
                      if(val.length<5){
                        val = val.substring(0,4);
                      }else if(val.length>=7){
                        val = val.substring(0,7);
                      }if(val.length>=5){
                        val = val.substring(0,5);
                      }
                    }

                    return val;

                  },
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  rotateAngle: math.pi*90,
                  interval: dataRange == DataRange.BEGINNING?10:1,
                  margin: 30,
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
                        now.day-maxX+value.toInt(),
                    );
                    return DateFormat("d MMM").format(returnDate);
                  },
                )
            ),
            lineBarsData: [
              LineChartBarData(
                dotData: FlDotData(
                  dotSize: 0,
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