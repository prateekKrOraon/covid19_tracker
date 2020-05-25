import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/data/state_wise_data.dart';
import 'package:covid19_tracker/data/states_daily_changes.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/analytics/math_functions.dart';
import 'package:covid19_tracker/utilities/helpers/data_range.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:covid19_tracker/utilities/models/state_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import '../error_screen.dart';

class AnalyticsScreen extends StatefulWidget{
  @override
  _AnalyticsScreenState createState() {
    return _AnalyticsScreenState();
  }
}

class _AnalyticsScreenState extends State<AnalyticsScreen>{

  double scaleFactor = 1;
  String dataRange = DataRange.BEGINNING;
  ThemeData theme;
  String dataRangeStr = "";
  double tooltipYPos = 10;
  double tooltipXPos = 10;
  String tooltipText = "";
  bool tooltipActive = false;
  Color tooltipColor = Colors.transparent;
  Size size;

  int graphCategory = -1;

  Future _data;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  void _getData()async{
    _data = Future.wait([StateWiseData.getInstance(),StatesDailyChanges.getInstance()]);
  }

  @override
  Widget build(BuildContext context) {

    theme = Theme.of(context);
    size = MediaQuery.of(context).size;
    AppLocalizations lang = AppLocalizations.of(context);

    if(size.width<400){
      scaleFactor = 0.75;
    }else if(size.width<=450){
      scaleFactor = 0.9;
    }

    return FutureBuilder(
      future: _data,
      builder: (BuildContext context,snapshot){
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



        MathFunctions functions = MathFunctions();

        Map map = snapshot.data[0];
        functions.parseData(map);
        List<double> growthFactors = functions.growthFactor(functions.confirmedTimeSeries);
        List<double> growthRatios = functions.growthRatio(functions.confirmedTimeSeries);
        List<double> growthRates = functions.gradient(functions.getLog(functions.confirmedTimeSeries));
        List<double> secondDerivative = functions.gradient(functions.gradient(functions.confirmedTimeSeries));
        List<double> mortalityRates = functions.mortalityRate(functions.deathsTimeSeries,functions.confirmedTimeSeries);
        List<double> recoveryRates = functions.recoveryRate(functions.recoveredTimeSeries,functions.confirmedTimeSeries);
        Map<String,int> cases = functions.getCases(functions.confirmedTimeSeries);
        List<CaseModel> caseModel = List();
        List<BarChartGroupData> stateGrowthRates = List();
        List<BarChartGroupData> stateMortalityRates = List();
        List<BarChartGroupData> stateRecoveryRates = List();

        Map statesDailyChanges = snapshot.data[1];
        List confirmedDaily = statesDailyChanges[kConfirmed];


        List stateWise = map[kStateWise];
        List<StateInfo> stateInfo = List();

        for(int i = 1;i<stateWise.length;i++){
          Map state = stateWise[i];
          stateInfo.add(
            StateInfo.fromMap(context, state),
          );
        }

        stateInfo.sort((a,b) => b.confirmed.compareTo(a.confirmed));

        List<BarChartGroupData> stateCnfBarGroup = List();
        double cnfHighest = 0;
        List<BarChartGroupData> stateRestBarGroup = List();
        double restHighest = 0;
        double stateGrowthHighest = 0;
        double stateRecRateHighest = 0;
        double stateDetRateHighest = 0;

        List<StateInfo> stateList = List();

        int j = 0;
        for(int i=0;i<stateInfo.length;i++){

          StateInfo state = stateInfo[i];
          if(state.stateCode != "UN"){
            stateList.add(
              state,
            );
            int deaths = state.deaths;
            int confirmed = state.confirmed;
            int recovered = state.recovered;

            if(confirmed==0){
              confirmed = 1;
            }

            if((deaths/confirmed)*100>stateDetRateHighest){
              stateDetRateHighest = (deaths/confirmed)*100;
            }

            stateMortalityRates.add(
              BarChartGroupData(
                showingTooltipIndicators: [],
                x: j,
                barRods: [
                  BarChartRodData(
                    y: (deaths/confirmed)*100,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    color: theme.accentColor,
                    width: 6*scaleFactor,
                  ),
                ],
              ),
            );

            if((recovered/confirmed)*100>stateRecRateHighest){
              stateRecRateHighest = (recovered/confirmed)*100;
            }
            stateRecoveryRates.add(
              BarChartGroupData(
                showingTooltipIndicators: [],
                x: j,
                barRods: [
                  BarChartRodData(
                    y: (recovered/confirmed)*100,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    color: theme.accentColor,
                    width: 6*scaleFactor,
                  ),
                ],
              ),
            );


            int casesToday = confirmedDaily[confirmedDaily.length-1][state.stateCode.toLowerCase()];
            int casesWeekAgo = confirmedDaily[confirmedDaily.length-7][state.stateCode.toLowerCase()];
            if(casesWeekAgo == null){
              casesWeekAgo = 0;
            }
            if(casesToday == null){
              casesToday = state.confirmed;
            }
            int confirmedCasesToday = casesToday-casesWeekAgo;
            int confirmedCaseWeekAgo = casesWeekAgo;
            if(confirmedCaseWeekAgo==0){
              confirmedCaseWeekAgo=1;
            }
            if(((confirmedCasesToday/confirmedCaseWeekAgo)*100)/7>stateGrowthHighest){
              stateGrowthHighest = ((confirmedCasesToday/confirmedCaseWeekAgo)*100)/7;
            }

            stateGrowthRates.add(
              BarChartGroupData(
                showingTooltipIndicators: [],
                x: j,
                barRods: [
                  BarChartRodData(
                    y: ((confirmedCasesToday/confirmedCaseWeekAgo)*100)/7,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10),
                    ),
                    color: theme.accentColor,
                    width: 6*scaleFactor,
                  ),
                ],
              ),
            );


            if(state.confirmed>cnfHighest){
              cnfHighest = state.confirmed.toDouble();
            }

            stateCnfBarGroup.add(
              BarChartGroupData(
                  showingTooltipIndicators: [],
                  x: j,
                  barRods: [
                    BarChartRodData(
                      y: state.confirmed.toDouble(),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                      color: theme.accentColor,
                      width: 6*scaleFactor,
                    ),
                  ]
              ),
            );

            if(state.active>restHighest){
              restHighest = state.active.toDouble();
            }
            if(state.recovered>restHighest){
              restHighest = state.recovered.toDouble();
            }
            if(state.deaths>restHighest){
              restHighest = state.deaths.toDouble();
            }

            stateRestBarGroup.add(
              BarChartGroupData(
                  showingTooltipIndicators: [],
                  x: j,
                  barRods: [
                    BarChartRodData(
                      y: state.active.toDouble(),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                      color: kBlueColor,
                      width: 4*scaleFactor,
                    ),
                    BarChartRodData(
                      y: state.recovered.toDouble(),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                      color: kGreenColor,
                      width: 4*scaleFactor,
                    ),
                    BarChartRodData(
                      y: state.deaths.toDouble(),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                      ),
                      color: Colors.grey,
                      width: 4*scaleFactor,
                    ),
                  ]
              ),
            );
            j++;
          }
        }

        cases.forEach((key, value) {
          if(value !=0){
            caseModel.add(
                CaseModel(key, value),
            );
          }
        });

        caseModel.sort((a,b) => double.parse(a.key).compareTo(double.parse(b.key)));

        List<FlSpot> spots = List();
        int i = 0;
        double highest = 0;


        int range = 0;

        if(dataRange == DataRange.BEGINNING){
          range = growthFactors.length;
        }else if(dataRange == DataRange.MONTH){
          range = 30;
        }else if(dataRange == DataRange.TWO_WEEK){
          range = 14;
        }

        if(dataRange == DataRange.BEGINNING){
          dataRangeStr = lang.translate(kSinceBeginningLang);
        }else if(dataRange == DataRange.MONTH){
          dataRangeStr = lang.translate(kLast30DaysLang);
        }else if(dataRange == DataRange.TWO_WEEK){
          dataRangeStr = lang.translate(kLast14DaysLang);
        }

        List<FlSpot> grSpots = List();
        double grHighest = 0;
        List<FlSpot> gRSpots = List();
        double gRHighest = 0;
        List<FlSpot> sdSpots = List();
        double sdHighest = 0;
        List<FlSpot> mrSpots = List();
        double mrHighest = 0;
        List<FlSpot> rrSpots = List();
        double rrHighest = 0;

        for(int i = growthFactors.length-range; i<growthFactors.length;i++){
          double element = 0;

          element = growthFactors[i];
          if(element > highest){
            highest = element;
          }
          spots.add(
              FlSpot(
                i.toDouble(),
                element,
              )
          );

          element = growthRatios[i];
          if(element > grHighest){
            grHighest = element;
          }
          grSpots.add(
            FlSpot(
              i.toDouble(),
              element,
            ),
          );

          element = growthRates[i];
          if(element > gRHighest){
            gRHighest = element;
          }
          gRSpots.add(
            FlSpot(
              i.toDouble(),
              element,
            ),
          );

          element = secondDerivative[i];
          if(element > sdHighest){
            sdHighest = element;
          }
          sdSpots.add(
            FlSpot(
              i.toDouble(),
              element,
            ),
          );

          element = mortalityRates[i];
          if(element > mrHighest){
            mrHighest = element;
          }
          mrSpots.add(
            FlSpot(
              i.toDouble(),
              element,
            ),
          );

          element = recoveryRates[i];
          if(element > rrHighest){
            rrHighest = element;
          }
          rrSpots.add(
            FlSpot(
              i.toDouble(),
              element,
            ),
          );
        }


        List<Widget> moreCharts = List();
        moreCharts.add(
          _getChartLayout(
            lang.translate(kMortalityRateLang),
            "${lang.translate(kCurMortalityRateLang)} = ${(mortalityRates[mortalityRates.length-1]).toString().substring(0,4)} %",
            mrSpots,
            mrHighest,
            mortalityRates.length,
          )
        );

        moreCharts.add(
            _getChartLayout(
              lang.translate(kRecoveryRateLang),
              "${lang.translate(kCurRecoveryRateLang)} = ${(recoveryRates[recoveryRates.length-1]).toString().substring(0,4)} %",
              rrSpots,
              rrHighest,
              recoveryRates.length,
            )
        );

        List<Widget> growthMetricsList = List();
        growthMetricsList.add(
          _getChartLayout(
            lang.translate(kGrowthFactorLang),
            "${lang.translate(kCurGrowthFactLang)} = ${growthFactors[growthFactors.length-2].toString().substring(0,4)}",
            spots,
            highest+4,
            growthFactors.length,
          ),
        );

        growthMetricsList.add(
          _getChartLayout(
            lang.translate(kGrowthRatioLang),
            "${lang.translate(kCurGrowthRatioLang)} = ${growthRatios[growthRatios.length-2].toString().substring(0,4)}",
            grSpots,
            grHighest+0.5,
            growthRatios.length,
          ),
        );

        growthMetricsList.add(
          _getChartLayout(
            lang.translate(kGrowthRateLang),
            "${lang.translate(kCurGrowthRateLang)} = ${(growthRates[growthRates.length-2]*100).toString().substring(0,4)} %",
            gRSpots,
            gRHighest+0.2,
            growthRates.length,
          ),
        );

        growthMetricsList.add(
          _getChartLayout(
            lang.translate(kSecondDerivativeLang),
            "",
            sdSpots,
            sdHighest+50,
            secondDerivative.length,
          ),
        );

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5,),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16*scaleFactor,),
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
                    ),
                    SizedBox(width: 10*scaleFactor,),
                  ],
                ),
                SizedBox(height: 16*scaleFactor,),
                _getSectionTitle(lang.translate(kGrowthMetricsLang)),
                SizedBox(height: 16*scaleFactor,),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: (){
                      NetworkHandler.getInstance().launchInBrowser("https://prateekkroraon.github.io/covid-19-tracker/statistical-analysis.html");
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            SimpleLineIcons.info,
                            size: 14*scaleFactor,
                            color: kGreyColor,
                          ),
                          SizedBox(width: 5*scaleFactor,),
                          Text(
                            lang.translate(kKnowMoreLang),
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 16*scaleFactor,
                              color: kGreyColor,
                            ),
                          ),
                          SizedBox(width: 5*scaleFactor,),
                          Icon(
                            Icons.launch,
                            size: 14*scaleFactor,
                            color: kGreyColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: size.width*0.85,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: growthMetricsList.length,
                    controller: PageController(
                      initialPage: 0,
                      viewportFraction: 0.95,
                    ),
                    itemBuilder: (BuildContext context,int index){
                      return growthMetricsList[index];
                    },
                  ),
                ),
                _getSectionTitle(lang.translate(kMoreLang)),
                SizedBox(height: 16*scaleFactor,),
                Container(
                  height: size.width*0.85,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: moreCharts.length,
                    controller: PageController(
                      initialPage: 0,
                      viewportFraction: 0.95,
                    ),
                    itemBuilder: (BuildContext context,int index){
                      return moreCharts[index];
                    },
                  ),
                ),
                _getSectionTitle(lang.translate(kDaysToReachLang),scroll: false),
                SizedBox(height: 16*scaleFactor,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10,),
                  ),
                  elevation: 2,
                  color: theme.backgroundColor,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lang.translate(kDate),
                                textAlign: TextAlign.left,
                                style:TextStyle(
                                  fontFamily: kQuickSand,
                                  fontSize: 20*scaleFactor,
                                  color: theme.accentColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                lang.translate(kCasesLang),
                                textAlign: TextAlign.center,
                                style:TextStyle(
                                  fontFamily: kQuickSand,
                                  fontSize: 20*scaleFactor,
                                  color: theme.accentColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                lang.translate(kDaysLang),
                                textAlign: TextAlign.center,
                                style:TextStyle(
                                  fontFamily: kQuickSand,
                                  fontSize: 20*scaleFactor,
                                  color: theme.accentColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                lang.translate(kDifferenceLang),
                                textAlign: TextAlign.center,
                                style:TextStyle(
                                  fontFamily: kQuickSand,
                                  fontSize: 20*scaleFactor,
                                  color: theme.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Divider(color: kGreyColor,),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: cases.length,
                          itemBuilder: (BuildContext context,int index){
                            if(caseModel[index].value == 0){
                              return SizedBox();
                            }
                            return Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4,),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          DateFormat("d MMM y").format(
                                            DateTime(
                                              DateTime.now().year,
                                              1,
                                              30+caseModel[index].value,
                                            )
                                          ),
                                          textAlign: TextAlign.left,
                                          style:TextStyle(
                                            fontFamily: kQuickSand,
                                            fontSize: 16*scaleFactor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          caseModel[index].key,
                                          textAlign: TextAlign.center,
                                          style:TextStyle(
                                            fontFamily: kQuickSand,
                                            fontSize: 16*scaleFactor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          caseModel[index].value.toString(),
                                          textAlign: TextAlign.center,
                                          style:TextStyle(
                                            fontFamily: kQuickSand,
                                            fontSize: 16*scaleFactor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          index==0?"${caseModel[index].value}":"${caseModel[index].value-caseModel[index-1].value}",
                                          textAlign: TextAlign.center,
                                          style:TextStyle(
                                            fontFamily: kQuickSand,
                                            fontSize: 16*scaleFactor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider()
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24*scaleFactor,),
                _getSectionTitle(lang.translate(kStateWiseAvgGrowthRatesLang),scroll: false),
                Text(
                  lang.translate(kGrowthRateDisclaimerLang),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 16*scaleFactor,
                    color: kGreyColor,
                  ),
                ),
                SizedBox(height: 16*scaleFactor,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10,),
                  ),
                  elevation: 2,
                  color: theme.backgroundColor,
                  child: Container(
                    width: size.width,
                    padding: EdgeInsets.all(10),
                    child: _getBarChart(stateGrowthRates, stateGrowthHighest,stateList,numberData: true,category: GraphCategories.AVG_GROWTH_RATE),
                  ),
                ),
                SizedBox(height: 24*scaleFactor,),
                _getSectionTitle(lang.translate(kStateWiseRecRateLang),scroll: false),
                SizedBox(height: 16*scaleFactor,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10,),
                  ),
                  elevation: 2,
                  color: theme.backgroundColor,
                  child: Container(
                    width: size.width,
                    padding: EdgeInsets.all(10),
                    child: _getBarChart(stateRecoveryRates, stateRecRateHighest,stateList,numberData: true,category: GraphCategories.REC_RATES),
                  ),
                ),
                SizedBox(height: 24*scaleFactor,),
                _getSectionTitle(lang.translate(kStateWiseMortalityRateLang),scroll: false),
                SizedBox(height: 16*scaleFactor,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10,),
                  ),
                  elevation: 2,
                  color: theme.backgroundColor,
                  child: Container(
                    width: size.width,
                    padding: EdgeInsets.all(10),
                    child: _getBarChart(stateMortalityRates, stateDetRateHighest,stateList,numberData: true,category: GraphCategories.DET_RATE),
                  ),
                ),
                SizedBox(height: 24*scaleFactor,),
                _getSectionTitle(lang.translate(kStateWiseCnfCasesLang),scroll: false),
                SizedBox(height: 16*scaleFactor,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10,),
                  ),
                  elevation: 2,
                  color: theme.backgroundColor,
                  child: Container(
                    width: size.width,
                    padding: EdgeInsets.all(10),
                    child: _getBarChart(stateCnfBarGroup, cnfHighest+1000,stateList,numberData:false,category: GraphCategories.CNF_CASES),
                  ),
                ),
                SizedBox(height: 24*scaleFactor,),
                _getSectionTitle(lang.translate(kStateWiseCasesLang),scroll: false),
                SizedBox(height: 16*scaleFactor,),
                Material(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10,),
                  ),
                  elevation: 2,
                  color: theme.backgroundColor,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(height: 10*scaleFactor,),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 15*scaleFactor,
                                            width: 15*scaleFactor,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8,),
                                              ),
                                              color: kBlueColor,
                                            ),
                                          ),
                                          SizedBox(width: 10*scaleFactor,),
                                          Text(
                                            lang.translate(kActiveLang),
                                            style: TextStyle(
                                              fontFamily: kQuickSand,
                                              fontSize: 16*scaleFactor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 15*scaleFactor,
                                        width: 15*scaleFactor,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8,),
                                          ),
                                          color: kGreenColor,
                                        ),
                                      ),
                                      SizedBox(width: 10*scaleFactor,),
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
                                    children: [
                                      Container(
                                        height: 15*scaleFactor,
                                        width: 15*scaleFactor,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8,),
                                          ),
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 10*scaleFactor,),
                                      Text(
                                        lang.translate(kDeaths),
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
                            SizedBox(height: 10*scaleFactor,),
                            RotatedBox(
                              quarterTurns: 1,
                              child: Container(
                                width: 800*scaleFactor,
                                child: _getRestBarChart(stateRestBarGroup, restHighest+1000,stateList,rotated: true,category: GraphCategories.STATE_CASES),
                              ),
                            ),
                          ],
                        ),
                        graphCategory != GraphCategories.STATE_CASES?SizedBox():Positioned(
                          right: tooltipXPos,
                          top: tooltipYPos,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            constraints: BoxConstraints(
                              minHeight: 50*scaleFactor,
                              minWidth: 100*scaleFactor,
                            ),
                            decoration: BoxDecoration(
                              color: tooltipColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    tooltipText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: kQuickSand,
                                      color: Colors.white,
                                      fontSize: 14*scaleFactor
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _getSectionTitle(String title,{bool scroll = true}){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontFamily: kQuickSand,
                fontSize: 25*scaleFactor,
              ),
            ),
          ],
        ),
        scroll?Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10,),
          child: Container(
            height: 20*scaleFactor,
            width: 20*scaleFactor,
            child: Center(
              child: Icon(
                SimpleLineIcons.arrow_right,
                size: 20*scaleFactor,
              ),
            ),
          ),
        ):SizedBox(),
      ],
    );
  }

  void showTooltip(String title,String subtitle,Color color,String chart,int xPos,int yPos,bool showTooltip,int category){
    graphCategory = category;
    tooltipText = "$title\n$subtitle";
    this.tooltipActive = showTooltip;
    this.tooltipColor = color;
    tooltipXPos = yPos.toDouble();
    tooltipYPos = xPos.toDouble();

  }

  Widget _getBarChart(List<BarChartGroupData> barGroups,double highest,List<StateInfo> list,{bool rotated=false,bool numberData=false,int category}){


    double sideInterval = (highest/10).roundToDouble();

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          Container(
            width: category == GraphCategories.STATE_CASES?800*scaleFactor:size.width,
            child: BarChart(
              BarChartData(
                barTouchData: BarTouchData(
                  handleBuiltInTouches: false,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: theme.accentColor,
                    getTooltipItem: (groupData,a,rodData,b){
                      return BarTooltipItem(
                        "${list[groupData.x].displayName}\n${rodData.y.round()}",
                        TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 14*scaleFactor,
                          color: theme.brightness==Brightness.light?Colors.white:Colors.black,
                        ),
                      );
                    }
                  ),
                  touchCallback: (BarTouchResponse response){
                    setState(() {
                      if (response.spot != null &&
                          response.touchInput is! FlPanEnd &&
                          response.touchInput is! FlLongPressEnd) {
                        showTooltip(
                            list[response.spot.touchedBarGroup.x].displayName,
                            category == GraphCategories.CNF_CASES?"${NumberFormat(",###").format(response.spot.touchedRodData.y.toInt())}":"${response.spot.touchedRodData.y.toStringAsFixed(1)} %",
                            response.spot.touchedRodData.color,
                            "cases",
                            (50+response.spot.touchedRodData.y*20*scaleFactor).toInt(),
                            (response.spot.touchedBarGroup.x*8*scaleFactor).toInt(),
                            true,
                            category
                        );
                      } else {
                        showTooltip(
                            "",
                            "",
                            Colors.transparent,
                            "cases",
                            0,
                            0,
                            false,
                            category
                        );
                        graphCategory = -1;
                      }
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(
                      color: kGreyColor,
                    ),
                    left: BorderSide(
                      color: kGreyColor,
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  rightTitles: SideTitles(
                    showTitles: false,
                  ),
                  leftTitles: SideTitles(
                      reservedSize: 15*scaleFactor,
                      showTitles: true,
                      interval: sideInterval,
                      rotateAngle: rotated?math.pi*86:0,
                      getTitles: (double value){
                        String str = "";
                        if(numberData){
                          if(value<1 && value>=0){
                            if(value.toString().length>=4){
                              str = value.toString().substring(0,4);
                            }
                          }else{
                            if(value>=100){
                              str = value.toString().substring(0,3);
                            }else if(value>=10&& value<100){
                              str = value.toString().substring(0,2);
                            }else if(value<10){
                              str = value.toString().substring(0,1);
                            }else if(value == 0){
                              str = "0";
                            }else{
                              str = value.toString().substring(0,3);
                            }
                          }
                        }else{
                          if(value >= 100000){
                            str = "${value.toString().substring(0,1)}L";
                          }else if(value>=10000){
                            str = "${value.toString().substring(0,2)}K";
                          }else if(value>=1000){
                            str = "${value.toString().substring(0,1)}K";
                          }else{
                            str = value.toString();
                          }
                        }

                        return str;
                      },
                      textStyle: TextStyle(
                        color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                        fontSize: 10*scaleFactor,
                      )
                  ),
                  bottomTitles: SideTitles(
                      rotateAngle: rotated?math.pi*86:math.pi*90,
                      showTitles: true,
                      reservedSize: 15*scaleFactor,
                      getTitles: (double value){
                        return list[value.toInt()].stateCode;
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
          graphCategory == category?Positioned(
            left: tooltipXPos,
            child: Material(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              color: theme.accentColor,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 150,
                ),
                padding:EdgeInsets.symmetric(horizontal: 10,vertical: 5,),
                child:Column(
                  children: [
                    Text(
                      tooltipText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kQuickSand,
                        fontSize: 14*scaleFactor,
                        color:theme.brightness == Brightness.light?Colors.white:Colors.black,
                      ),
                    ),
                  ],
                )
              ),
            ),
          ):SizedBox(),
        ],
      ),
    );
  }

  Widget _getChartLayout(String title,String subText, List<FlSpot> spots,double highest,int maxX){

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4,vertical: 8),
          child: Material(
            borderRadius: BorderRadius.all(
                Radius.circular(10)
            ),
            elevation: 2,
            color: theme.backgroundColor,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: kQuickSand,
                      fontSize: 25*scaleFactor,
                    ),
                  ),
                  Text(
                    subText,
                    style: TextStyle(
                      fontFamily: kQuickSand,
                      fontSize: 20*scaleFactor,
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
                  _getLineChart(spots, highest, maxX),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _getRestBarChart(List<BarChartGroupData> barGroups,double highest,List<StateInfo> list,{bool rotated=false,bool numberData=false,int category}){

    double sideInterval = (highest/10).roundToDouble();

    return BarChart(
      BarChartData(
        barTouchData: BarTouchData(
          handleBuiltInTouches: rotated?false:true,
          touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: theme.accentColor,
              getTooltipItem: (groupData,a,rodData,b){
                return BarTooltipItem(
                  "${list[groupData.x].displayName}\n${rodData.y.round()}",
                  TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 14*scaleFactor,
                    color: theme.brightness==Brightness.light?Colors.white:Colors.black,
                  ),
                );
              }
          ),
          touchCallback: (BarTouchResponse response){
              setState(() {
                if (response.spot != null &&
                    response.touchInput is! FlPanEnd &&
                    response.touchInput is! FlLongPressEnd) {
                  showTooltip(
                    list[response.spot.touchedBarGroup.x].displayName,
                    "${NumberFormat(",###").format(response.spot.touchedRodData.y.toInt())}",
                    response.spot.touchedRodData.color,
                    "cases",
                    (50+response.spot.touchedBarGroup.x*20*scaleFactor).toInt(),
                    50,
                    true,
                    GraphCategories.STATE_CASES,
                  );
                } else {
                  showTooltip(
                    "",
                    "",
                    Colors.transparent,
                    "cases",
                    0,
                    0,
                    false,
                    GraphCategories.STATE_CASES,
                  );
                  graphCategory = -1;
                }
              });
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(
              color: kGreyColor,
            ),
            left: BorderSide(
              color: kGreyColor,
            ),
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: SideTitles(
            showTitles: false,
          ),
          leftTitles: SideTitles(
              reservedSize: 15*scaleFactor,
              showTitles: true,
              interval: sideInterval,
              rotateAngle: rotated?math.pi*86:0,
              getTitles: (double value){
                String str = "";
                if(numberData){
                  if(value<1 && value>=0){
                    if(value.toString().length>=4){
                      str = value.toString().substring(0,4);
                    }
                  }else{
                    if(value>=100){
                      str = value.toString().substring(0,3);
                    }else if(value>=10&& value<100){
                      str = value.toString().substring(0,2);
                    }else if(value<10){
                      str = value.toString().substring(0,1);
                    }else if(value == 0){
                      str = "0";
                    }else{
                      str = value.toString().substring(0,3);
                    }
                  }
                }else{
                  if(value >= 100000){
                    str = "${value.toString().substring(0,1)}L";
                  }else if(value>=10000){
                    str = "${value.toString().substring(0,2)}K";
                  }else if(value>=1000){
                    str = "${value.toString().substring(0,1)}K";
                  }else{
                    str = value.toString();
                  }
                }

                return str;
              },
              textStyle: TextStyle(
                color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                fontSize: 10*scaleFactor,
              )
          ),
          bottomTitles: SideTitles(
              rotateAngle: rotated?math.pi*86:math.pi*90,
              showTitles: true,
              reservedSize: 15*scaleFactor,
              getTitles: (double value){
                return list[value.toInt()].stateCode;
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
    );
  }

  Widget _getLineChart(List<FlSpot> spots,double total,int maxX){
    double bottomTitleInterval = 0;
    double sideInterval = 2;


    if(dataRange == DataRange.BEGINNING){
      bottomTitleInterval = (maxX/10).roundToDouble();
    }else if(dataRange == DataRange.MONTH){
      bottomTitleInterval = 3;
    }else if(dataRange == DataRange.TWO_WEEK){
      bottomTitleInterval = 2;
    }

    sideInterval = double.parse((total/5).toStringAsFixed(2));

    return Padding(
      padding: const EdgeInsets.all(6),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> spots){
                  List<LineTooltipItem> list = List();

                  spots.forEach((element) {
                    DateTime date = DateTime(
                      2020,
                      DateTime.now().month,
                      DateTime.now().day-maxX+element.x.toInt(),
                    );
                    list.add(
                      LineTooltipItem(
                        "${DateFormat("d MMM y").format(date)}\n${element.y.toStringAsFixed(2)}",
                        TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 14*scaleFactor,
                          color: theme.brightness == Brightness.light?Colors.white:Colors.black,
                        )
                      )
                    );
                  });

                  return list;
                },
                tooltipBottomMargin: 50,
                tooltipBgColor: theme.accentColor,
              ),
              touchCallback: (LineTouchResponse touchResponse) {
                // implementation
              },
              handleBuiltInTouches: true,
            ),
            maxY: total,
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
                  reservedSize: 20*scaleFactor,
                  textStyle: TextStyle(
                    fontSize: 10*scaleFactor,
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontFamily: kNotoSansSc,
                  ),
                  getTitles: (double value){
                    String val = value.toString();

                    if(value>1000){
                      return '${value.toString().substring(0,1)}k';
                    }else if(value>100){
                      return value.round().toString();
                    }else if(value>10){
                      return value.round().toString();
                    }else if(value>0){
                      return value.toStringAsFixed(2);
                    }else if(value==0){
                      return "0";
                    }else if(value>-1000){
                      return value.round().toString();
                    }else if(value>-10000){
                      return '${value.toString().substring(0,2)}.${value.toString().substring(2,3)}k';
                    }

                    return val;


                  },
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  rotateAngle: math.pi*90,
                  interval: bottomTitleInterval,
                  margin: 15*scaleFactor,
                  textStyle: TextStyle(
                    fontSize: 8*scaleFactor,
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

class CaseModel{
  String key;
  int value;

  CaseModel(this.key,this.value);
}

class GraphCategories{
  static const int AVG_GROWTH_RATE = 0;
  static const int REC_RATES = 1;
  static const int DET_RATE = 2;
  static const int CNF_CASES = 3;
  static const int STATE_CASES = 4;
}