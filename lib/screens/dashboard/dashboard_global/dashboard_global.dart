/*
*
* Dashboard for global data
*
*/


import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/data/state_wise_data.dart';
import 'package:covid19_tracker/data/country_wise_data.dart';
import 'package:covid19_tracker/data/world_data.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/dashboard/dashboard_global/country_data_screen.dart';
import 'package:covid19_tracker/screens/dashboard/dashboard_global/global_full_list.dart';
import 'package:covid19_tracker/utilities/models/country.dart';
import 'package:covid19_tracker/utilities/custom_widgets/custom_widgets.dart';
import 'package:covid19_tracker/utilities/helpers/data_range.dart';
import 'package:covid19_tracker/utilities/models/global_time_series_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'package:covid19_tracker/data/global_time_series_data.dart';
import '../../error_screen.dart';
import 'dart:math' as math;

class DashboardGlobal extends StatefulWidget{
  @override
  _DashboardGlobalState createState() {
    return _DashboardGlobalState();
  }
}

class _DashboardGlobalState extends State<DashboardGlobal>{

  double textScaleFactor = 1;


  ThemeData theme;
  bool refresh = false;
  String dataRange = DataRange.MONTH;

  Future _data;

  @override
  void initState() {
    _getData();
    super.initState();
  }

  _getData()async{
    _data = Future.wait([WorldData.getInstance(),CountryWiseData.getInstance(),GlobalTimeSeriesData.getInstance()]);
  }

  _refreshData()async{
    StateWiseData.refresh();
    CountryWiseData.refresh();
    GlobalTimeSeriesData.refresh();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    if(size.width<=360.0){
      textScaleFactor = 0.75;
    }

    return FutureBuilder(
      future: _data,
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }
        if(snapshot.hasError){
          return Center(
            child: ErrorScreen(
              onClickRetry: (){
                setState(() {
                  StateWiseData.refresh();
                  CountryWiseData.refresh();
                  GlobalTimeSeriesData.refresh();
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
                  CountryWiseData.refresh();
                  GlobalTimeSeriesData.refresh();
                });
              },
            ),
          );
        }

        List data = snapshot.data;

        Map worldData = data[0];
        List countryWiseData = data[1];
        Map globalTimeSeries = data[2]['result'];

        List<Country> countries = List();



        countryWiseData.forEach((map){
          countries.add(
            Country.fromMap(context,map),
          );
        });

        List<Country> worstAffectedCountries = List();

        for(int i=0;i<5;i++){
          worstAffectedCountries.add(
            countries[i],
          );
        }

        DateTime worldDataLastUpdated = DateTime.fromMillisecondsSinceEpoch(worldData[kCountryUpdated]);

        List<Map<String,dynamic>> globalTimeSeriesList = List();

        List<FlSpot> globalCnfSeries = List();
        List<FlSpot> globalDetSeries = List();
        List<FlSpot> globalRecSeries = List();
        int totalCnf = 0;
        int totalRec = 0;
        int totalDet = 0;


        String dataRangeStr = "";

        if(dataRange == DataRange.BEGINNING){
          dataRangeStr = lang.translate(kFrom22JanLang);
        }else if(dataRange == DataRange.MONTH){
          dataRangeStr = lang.translate(kLast30DaysLang);
        }else if(dataRange == DataRange.TWO_WEEK){
          dataRangeStr = lang.translate(kLast14DaysLang);
        }

        int range = 0;

        if(dataRange == DataRange.BEGINNING){
          range = globalTimeSeries.length;
        }else if(dataRange == DataRange.MONTH){
          range = 31;
        }else if(dataRange == DataRange.TWO_WEEK){
          range = 14;
        }

        List<GlobalTimeSeries> globalTimeSeriesData = List();

        globalTimeSeries.forEach((key,value){
          Map map = globalTimeSeries[key];
          globalTimeSeriesList.add(map);
          globalTimeSeriesData.add(
            GlobalTimeSeries.fromMap(value, key),
          );
        });


        int j = 0;
        for(int i = globalTimeSeriesList.length-range;i<globalTimeSeriesList.length;i++){
          Map map = globalTimeSeriesList[i];
          globalCnfSeries.add(
              FlSpot(
                j.toDouble(),
                double.parse(map[kConfirmed].toString()),
              )
          );
          totalCnf = map[kConfirmed];
          globalDetSeries.add(
              FlSpot(
                j.toDouble(),
                double.parse(map[kDeaths].toString()),
              )
          );
          totalDet = map[kDeaths];
          globalRecSeries.add(
              FlSpot(
                j.toDouble(),
                double.parse(map[kRecovered].toString()),
              )
          );
          totalRec = map[kRecovered];
          j++;
        }



        List<Widget> chartsList = List();
        chartsList.add(
          _getLineChartLayout(lang.translate(kConfirmedLang), globalCnfSeries, totalCnf.toDouble()+500000, globalCnfSeries.length),
        );
        chartsList.add(
          _getLineChartLayout(lang.translate(kRecoveredLang), globalRecSeries, totalRec.toDouble()+250000, globalRecSeries.length),
        );
        chartsList.add(
          _getLineChartLayout(lang.translate(kDeaths), globalDetSeries, totalDet.toDouble()+100000, globalDetSeries.length),
        );


        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10,),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            "${lang.translate(kLastUpdatedAtLang)}: ${DateFormat("d MMM, ").add_jm().format(worldDataLastUpdated)} IST",
                            style: TextStyle(
                              color: kGreenColor,
                              fontSize: 16*textScaleFactor,
                              fontFamily: kQuickSand,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            setState(() {
                              _refreshData();
                              //Future.wait([WorldData.refresh(),CountryWiseData.refresh(),GlobalTimeSeriesData.refresh()]);
                            });
                          },
                          child: Container(
                            child: Center(
                              child: Icon(
                                SimpleLineIcons.refresh,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16,),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            DashboardTile(
                              mainTitle: lang.translate(kTotalCnfLang),
                              value: worldData[kCountryTotalCases].toString(),
                              delta: worldData[kCountryTodayCases].toString(),
                              color: kRedColor,
                            ),
                            SizedBox(width: 10,),
                            DashboardTile(
                              mainTitle: lang.translate(kTotalActvLang),
                              value: worldData[kCountryActive].toString(),
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
                              value: worldData[kCountryRecovered].toString(),
                              delta: "",
                              color: kGreenColor,
                            ),
                            SizedBox(width: 10,),
                            DashboardTile(
                              mainTitle: lang.translate(kTotalDetLang),
                              value: worldData[kCountryDeaths].toString(),
                              delta: worldData[kCountryTodayDeaths].toString(),
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
                              mainTitle: lang.translate(kCriticalLang),
                              value: worldData[kCountryCritical].toString(),
                              delta: "",
                              color: kOrangeColor,
                            ),
                            SizedBox(width: 10,),
                            DashboardTile(
                              mainTitle: lang.translate(kAffectedCountriesLang),
                              value: worldData[kAffectedCountries].toString(),
                              delta: "",
                              color: kGreyColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Material(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                      elevation: 2,
                      color: theme.backgroundColor,
                      child: Container(
                        decoration:BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      lang.translate(kTotalTestedLang),
                                      style: TextStyle(
                                        fontFamily: kQuickSand,
                                        fontSize: 24*textScaleFactor,
                                        color: kDarkBlueColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      worldData[kCountryTests].toString(),
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        color: kDarkBlueColor,
                                        fontSize: 24*textScaleFactor,
                                        fontFamily: kQuickSand,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16,),
                  Material(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    elevation: 2,
                    color: theme.backgroundColor,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment:CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  lang.translate(kWorstAffectedCountriesLang),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: kGreyColor,
                                    fontFamily: kNotoSansSc,
                                    fontSize: 24*textScaleFactor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 5,),
                              InkWell(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullGlobalList(countries),
                                      )
                                  );
                                },
                                child: Container(
                                  child: Row(
                                    children: <Widget>[
                                      Text(
                                        lang.translate(kCompleteListLang),
                                        style: TextStyle(
                                          fontFamily: kQuickSand,
                                          color: kGreyColor,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Icon(
                                        AntDesign.arrowright,
                                        color: kGreyColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16,),
                          TableHeaderStatic(lang.translate(kCountryLang)),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: worstAffectedCountries.length,
                            itemBuilder: (BuildContext context,int index){

                              if(countries[index].totalCases == 0){
                                return SizedBox();
                              }

                              return TableRows(
                                country: worstAffectedCountries[index],
                                onTouchCallback: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => CountryDataScreen(worstAffectedCountries[index]),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24,),
                  Material(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    elevation: 2,
                    color: theme.backgroundColor,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            lang.translate(kGlobalRatioLang),
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              color: kGreyColor,
                              fontSize: 24,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: _createGlobalRatioGraph(countries, worldData[kCountryTotalCases]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24,),
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
                  SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
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
                                    if(dataRange != DataRange.BEGINNING){
                                      setState(() {
                                        dataRange = DataRange.BEGINNING;
                                      });
                                    }
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
                                    if(dataRange != DataRange.MONTH){
                                      setState(() {
                                        dataRange = DataRange.MONTH;
                                      });
                                    }

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
                                    if(dataRange != DataRange.TWO_WEEK){
                                      setState(() {
                                        dataRange = DataRange.TWO_WEEK;
                                      });
                                    }
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
                  ),
                  SizedBox(height: 24,),
                  Container(
                    height: size.width*0.7,
                    width: size.width,
                    child: PageView.builder(
                      controller: PageController(
                        initialPage: 0,
                        viewportFraction: 0.95,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: chartsList.length,
                      itemBuilder: (BuildContext context,int index){
                        return chartsList[index];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _getLineChart(List<FlSpot> spots,double total,int maxX){
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
              horizontalInterval: total<1500000?total<500000?100000:250000:500000,
            ),
            titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: false,
                ),
                rightTitles: SideTitles(
                    showTitles: true,
                    interval: total<1500000?total<500000?100000:250000:500000,
                    reservedSize: 25,
                    textStyle: TextStyle(
                      fontSize: 10*textScaleFactor,
                      color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                      fontFamily: kNotoSansSc,
                    ),
                    getTitles: (double value){
                      if(value<100000 && value>10000){
                        return '${(value).toString().substring(0,2)}k';
                      }else if (value>=100000 && value<1000000){
                        return '${(value).toString().substring(0,3)}k';
                      }else if(value >= 1000000){
                        return  '${(value).toString().substring(0,1)}.${(value).toString().substring(1,2)}m';
                      }{
                        return '${(value).toInt().toString()}';
                      }
                    }
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  rotateAngle: math.pi*90,
                  interval: 3,
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



  Widget _createGlobalRatioGraph(List<Country> countries,int totalPositive){

    List<BarChartGroupData> globalRatioData = List();

    double highest = 0;


    for(int i=0;i<8;i++){

      int currentPos = countries[i].totalCases;
      double percent = (currentPos/totalPositive)*100;
      if(highest<percent){
        highest = percent;
      }

      globalRatioData.add(
        BarChartGroupData(
          x: i,
          showingTooltipIndicators: [0],
          barRods: [
            BarChartRodData(
              y: percent,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              color: theme.accentColor,
              width: MediaQuery.of(context).size.width/20,
            ),
          ],
        ),
      );

    }

    return _getBarChart(countries,globalRatioData,highest+5, globalRatioData.length);

  }

  Widget _getBarChart(List<Country> countries,List<BarChartGroupData> barGroups,double highest,int maxX){
    return Padding(
      padding: const EdgeInsets.all(8),
      child: AspectRatio(
        aspectRatio: 1.5,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
                allowTouchBarBackDraw: true,
                touchTooltipData: BarTouchTooltipData(
                  fitInsideVertically: true,
                  getTooltipItem: (BarChartGroupData grpData,int val1,BarChartRodData rodData, int val2){
                    String tooltipVal;
                    if(rodData.y>=10){
                      tooltipVal = rodData.y.toString().substring(0,5);
                    }else{
                      tooltipVal = rodData.y.toString().substring(0,4);
                    }
                    return BarTooltipItem(
                      "$tooltipVal%",
                      TextStyle(
                        fontFamily: kQuickSand,
                        fontSize: 14*textScaleFactor,
                        color: Theme.of(context).accentColor,
                      )
                    );
                  },
                  tooltipBottomMargin: 0,
                  tooltipBgColor: Colors.transparent,
                ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(
                  color: kGreyColor,
                ),
              left: BorderSide.none
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: SideTitles(
                  reservedSize: 16,
                  showTitles: false,
                  interval: 10,
                  getTitles: (double value){
                    return "${value.toInt()} %";
                  },
                  textStyle: TextStyle(
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontSize: 10*textScaleFactor,
                  )
              ),
              bottomTitles: SideTitles(
                  interval: 5,
                  showTitles: true,
                  getTitles: (double value){

                    return countries[value.toInt()].displayName;
                  },
                  textStyle: TextStyle(
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontSize: 12*textScaleFactor,
                  )
              ),
            ),
            maxY: highest,
            backgroundColor: Colors.transparent,
            barGroups: barGroups,
          ),
        ),
      ),
    );
  }

}