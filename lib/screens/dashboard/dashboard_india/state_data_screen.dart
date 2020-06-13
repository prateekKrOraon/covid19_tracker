/*
*
* Information for states of India
*
*/

import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/custom_widgets/custom_widgets.dart';
import 'package:covid19_tracker/utilities/models/district.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:covid19_tracker/utilities/helpers/sorting.dart';
import 'package:covid19_tracker/utilities/models/state_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../error_screen.dart';

class StateData extends StatefulWidget{

  StateData({this.stateInfo});

  final StateInfo stateInfo;

  @override
  _StateDataState createState() {
    return _StateDataState();
  }
}

class _StateDataState extends State<StateData>{

  ThemeData theme;

  StateInfo stateInfo;
  bool logarithmic = false;
  bool _loading = true;


  NetworkHandler _networkHandler;

  double scaleFactor = 1;

  SortingOrder sortingOrder;

  Future _data;

  @override
  void initState() {
    _networkHandler = NetworkHandler.getInstance();
    this.stateInfo = widget.stateInfo;
    sortingOrder = SortingOrder();
    _getData();
    super.initState();
  }

  Future _getData()async{
    _data = _networkHandler.getStateData(this.stateInfo.stateCode.toUpperCase())..whenComplete(() {
      setState(() {
        _loading = false;
      });
    });
  }

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _loading?LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: theme.scaffoldBackgroundColor,
              ):SizedBox(height: 3,),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            lang.locale.languageCode=="en"?stateInfo.stateName:stateInfo.stateNameHI,
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 30*scaleFactor,
                            ),
                          ),
                          Text(
                            "${lang.translate(kLastUpdatedAtLang)}: ${DateFormat("d MMM, ").add_jm().format(stateInfo.lastUpdated)}",
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 14*scaleFactor,
                              color: theme.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16*scaleFactor,),
                    Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              DashboardTile(
                                mainTitle: lang.translate(kTotalCnfLang),
                                value: stateInfo.confirmed.toString(),
                                delta: stateInfo.deltaCnf.toString(),
                                color: kRedColor,
                              ),
                              SizedBox(width: 10*scaleFactor,),
                              DashboardTile(
                                mainTitle: lang.translate(kTotalActvLang),
                                value: stateInfo.active.toString(),
                                delta: "",
                                color: kBlueColor,
                              ),
                            ],
                          ),
                          SizedBox(height: 10*scaleFactor,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              DashboardTile(
                                mainTitle: lang.translate(kTotalRecLang),
                                value: stateInfo.recovered.toString(),
                                delta: stateInfo.deltaRec.toString(),
                                color: kGreenColor,
                              ),
                              SizedBox(width: 10*scaleFactor,),
                              DashboardTile(
                                mainTitle: lang.translate(kTotalDetLang),
                                value: stateInfo.deaths.toString(),
                                delta: stateInfo.deltaDet.toString(),
                                color: kGreyColor,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10*scaleFactor,),
                    FutureBuilder(
                      future: _data,
                      builder: (BuildContext context, snapshot){
                        if(snapshot.connectionState == ConnectionState.waiting){
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: size.height*0.2,
                              ),
                              Text(
                                lang.translate(kLoadingLang),
                                textAlign: TextAlign.center,
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
                                  _data = _networkHandler.getStateData(stateInfo.stateCode.toUpperCase());
                                });
                              },
                            ),
                          );
                        }
                        if(snapshot.data['district_wise']==null){
                          return Center(
                            child: ErrorScreen(
                              onClickRetry: (){
                                setState(() {
                                  _data = _networkHandler.getStateData(stateInfo.stateCode.toUpperCase());
                                });
                              },
                            ),
                          );
                        }

                        //Table data processing
                        //Map zones = snapshot.data['zones'];
                        List districtData = snapshot.data['district_wise'];
                        Map testData = snapshot.data['test_data'];

                        String totalTested = testData['total_tested'];
                        if(totalTested == ""){
                          totalTested = "0";
                        }
                        String testSource = testData['source'];
                        DateTime testLastUpdated;

                        if(testData['last_update'] != ""){
                          testLastUpdated = DateTime(
                            int.parse(testData['last_update'].substring(6,10)),
                            int.parse(testData['last_update'].substring(3,5)),
                            int.parse(testData['last_update'].substring(0,2)),
                          );
                        }

                        List<District> districts = List();

                        districtData.forEach((map){
                          //not adding unknown cases now... to be added later at the end of the sorted list
                          if('Unknown' != map[kDistrict].toString()) {
                            districts.add(
                              District.fromMap(
                                context,
                                map,
                              ),
                            );
                          }
                        });

                        //Sorting districts according to decreasing order of  confirmed cases
                        districts.sort((a,b) => b.confirmed.compareTo(a.confirmed));

                        //unknown cases is appended at the end of the sorted list is there is any
                        if(districtData[districtData.length-1][kDistrict] == 'Unknown'){
                          districts.add(
                            District.fromMap(context, districtData[districtData.length-1]),
                          );
                        }

                        //Table data processing ends here

                        //Charts data Processing
                        List dailyReport = snapshot.data['timeseries'];
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

                        int range = 90;
                        if(dailyReport.length<range){
                          range = dailyReport.length;
                        }

                        int j = 0;
                        int k = 0;
                        int l = 0;
                        List<Widget> lineChartLayouts = List();
                        List<Widget> barChartLayouts = List();

                        if(stateInfo.stateCode != "UN"){
                          for(int i = 0; i<dailyReport.length; i++){
                            Map day = dailyReport[i];
                            if(i%3==0){
                              String str = day[stateInfo.stateCode.toLowerCase()];
                              int currentCnf = 0;
                              if(str != ""){
                                currentCnf = int.parse(str);
                              }

                              if(dailyHighestCnf<currentCnf){
                                dailyHighestCnf = currentCnf;
                              }
                              totalCnf += currentCnf;
                              if(i>=dailyReport.length-90){
                                cnfSpots.add(
                                  FlSpot(
                                    j.toDouble(),
                                    totalCnf.toDouble(),
                                  ),
                                );
                                dailyConfirmedChartGroup.add(
                                  BarChartGroupData(
                                    x: j,
                                    showingTooltipIndicators: [],
                                    barRods: [
                                      BarChartRodData(
                                        y: currentCnf.toDouble(),
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
                                j++;
                              }
                            }
                            if(i%3==1){
                              String str = day[stateInfo.stateCode.toLowerCase()];
                              int currentRec = 0;
                              if(str!=""){
                                currentRec = int.parse(str);
                              }
                              if(dailyHighestRec < currentRec){
                                dailyHighestRec = currentRec;
                              }
                              totalRec += currentRec;
                              if(i>=dailyReport.length-90){
                                recSpots.add(
                                  FlSpot(
                                    (k).toDouble(),
                                    totalRec.toDouble(),
                                  ),
                                );
                                dailyRecChartGroup.add(
                                  BarChartGroupData(
                                    x: k,
                                    showingTooltipIndicators: [],
                                    barRods: [
                                      BarChartRodData(
                                        y: currentRec.toDouble(),
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
                                k++;
                              }
                            }
                            if(i%3==2){
                              String str = day[stateInfo.stateCode.toLowerCase()];
                              int currentDet = 0;
                              if(str != "") {
                                currentDet = int.parse(str);
                              }

                              if(dailyHighestDet < currentDet){
                                dailyHighestDet = currentDet;
                              }
                              totalDet += currentDet;
                              if(i>=dailyReport.length-90){
                                detSpots.add(
                                  FlSpot(
                                    l.toDouble(),
                                    totalDet.toDouble(),
                                  ),
                                );
                                dailyDetChartGroup.add(
                                  BarChartGroupData(
                                    x: l,
                                    showingTooltipIndicators: [],
                                    barRods: [
                                      BarChartRodData(
                                        y: currentDet.toDouble(),
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
                                l++;
                              }
                            }
                          }
                          lineChartLayouts.add(
                            _getLineChartLayout(lang.translate(kConfirmedLang),cnfSpots, totalCnf.toDouble(), 30),
                          );

                          lineChartLayouts.add(
                            _getLineChartLayout(lang.translate(kRecoveredLang),recSpots, totalRec.toDouble(), 30),
                          );

                          lineChartLayouts.add(
                            _getLineChartLayout(lang.translate(kDeathsLang),detSpots, totalDet.toDouble(), 30),
                          );



                          barChartLayouts.add(
                            _getBarChartLayout(lang.translate(kDailyCnfLang), dailyConfirmedChartGroup, (dailyHighestCnf).toDouble(),range~/3),
                          );

                          barChartLayouts.add(
                            _getBarChartLayout(lang.translate(kDailyRecLang), dailyRecChartGroup, (dailyHighestRec).toDouble(),range~/3),
                          );

                          barChartLayouts.add(
                            _getBarChartLayout(lang.translate(kDailyDetLang), dailyDetChartGroup, (dailyHighestDet).toDouble(),range~/3),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Material(
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
                                                fontSize: 24*scaleFactor,
                                                color: kDarkBlueColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              NumberFormat(",##,###","hi_IN").format(double.parse(totalTested)),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: kDarkBlueColor,
                                                fontSize: 24*scaleFactor,
                                                fontFamily: kQuickSand,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5*scaleFactor,),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              "${lang.translate(kLastUpdatedAtLang)} ${testLastUpdated==null?"--/--/----":DateFormat("d MMM y").format(testLastUpdated)}",
                                              style: TextStyle(
                                                fontFamily: kQuickSand,
                                                fontSize: 14*scaleFactor,
                                                color: kGreyColor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              highlightColor: Colors.transparent,
                                              onTap: (){
                                                if(testSource != ""){
                                                  NetworkHandler.getInstance().launchInBrowser(testSource);
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    lang.translate(kSourceLang),
                                                    style: TextStyle(
                                                      color: kGreyColor,
                                                      fontSize: 12*scaleFactor,
                                                      fontFamily: kNotoSansSc,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5*scaleFactor,),
                                                  Icon(
                                                    Icons.launch,
                                                    color: kGreyColor,
                                                    size: 12*scaleFactor,
                                                  )
                                                ],
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
                            stateInfo.stateNotes!=""?Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6,),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    SizedBox(height: 10*scaleFactor,),
                                    Text(
                                      "Note:\n${stateInfo.stateNotes}",
                                      style: TextStyle(
                                        fontFamily: kNotoSansSc,
                                        fontSize: 13*scaleFactor,
                                        color:kGreyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ):SizedBox(),
                            SizedBox(height: 10*scaleFactor,),
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
                                  children: <Widget>[
                                    Center(

                                      child: TableHeaderStatic(lang.translate(kDistrictLang),),
                                    ),
                                    Center(
                                      child: Container(
                                        child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: districts.length,
                                            itemBuilder:(BuildContext context,int index){
                                              District district = districts[index];

                                              if(district.confirmed == 0){
                                                return SizedBox();
                                              }

                                              return Column(
                                                children: <Widget>[
                                                  SizedBox(height:5*scaleFactor,),
                                                  Container(
                                                    padding: EdgeInsets.only(left: 6,right: 6),
                                                    constraints:BoxConstraints(
                                                      minHeight: 30*scaleFactor,
                                                      maxHeight: 76*scaleFactor,
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: <Widget>[
//                                                    Container(
//                                                      width: 20*scaleFactor,
//                                                      height: 20*scaleFactor,
//                                                      child: Center(
//                                                        child: Container(
//                                                          height: 10*scaleFactor,
//                                                          width: 10*scaleFactor,
//                                                          decoration: BoxDecoration(
//                                                            borderRadius: BorderRadius.all(
//                                                              Radius.circular(5,),
//                                                            ),
//                                                            color: district.zone,
//                                                          ),
//                                                        ),
//                                                      ),
//                                                    ),
                                                        Expanded(
                                                          child: Text(
                                                            lang.locale.languageCode=="en"?district.districtName:district.districtNameHI,
                                                            style: TextStyle(
                                                              fontFamily: kQuickSand,
                                                              fontSize: 14*scaleFactor,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              Text(
                                                                district.confirmed.toString(),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontFamily: kQuickSand,
                                                                  fontSize: 14*scaleFactor,
                                                                ),
                                                              ),
                                                              SizedBox(height: 3*scaleFactor,),
                                                              Text(
                                                                district.deltaCnf==0?"":"(${district.deltaCnf<0?"":"+"}${district.deltaCnf})",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontFamily: kQuickSand,
                                                                  color: kRedColor,
                                                                  fontSize: 12*scaleFactor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              Text(
                                                                district.active.toString(),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontFamily: kQuickSand,
                                                                  fontSize: 14*scaleFactor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: <Widget>[
                                                              Text(
                                                                district.recovered.toString(),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontFamily: kQuickSand,
                                                                  fontSize: 14*scaleFactor,
                                                                ),
                                                              ),
                                                              SizedBox(height: 3*scaleFactor,),
                                                              Text(
                                                                district.deltaRec==0?"":"(${district.deltaRec<0?"":"+"}${district.deltaRec})",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontFamily: kQuickSand,
                                                                  color: kGreenColor,
                                                                  fontSize: 12*scaleFactor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: <Widget>[
                                                              Text(
                                                                district.deaths.toString(),
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontFamily: kQuickSand,
                                                                  fontSize: 14*scaleFactor,
                                                                ),
                                                              ),
                                                              SizedBox(height: 3*scaleFactor,),
                                                              Text(
                                                                district.deltaDet==0?"":"(${district.deltaDet<0?"":"+"}${district.deltaDet})",
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  fontFamily: kQuickSand,
                                                                  color: Colors.grey,
                                                                  fontSize: 12*scaleFactor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(height:5*scaleFactor,),
                                                  Container(height: 1,color: theme.brightness == Brightness.light?kGreyColorLight:Colors.grey[800],),
                                                ],
                                              );
                                            },
                                        ),
                                      ),
                                    ),//Tabular data
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 20*scaleFactor,),
                            stateInfo.stateCode != "UN"?Padding(
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
                                          fontSize: 25*scaleFactor,
                                        ),
                                      ),
                                      Text(
                                        lang.translate(kLast30DaysLang),
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontFamily: kQuickSand,
                                          fontSize: 16*scaleFactor,
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
                                          size: 20*scaleFactor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ):SizedBox(),
                            SizedBox(height: 20*scaleFactor,),
                            stateInfo.stateCode != "UN"?Container(
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
                            ):SizedBox(),
                            stateInfo.stateCode != "UN"?Container(
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
                            ):SizedBox(),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
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
                        fontSize: 25*scaleFactor,
                      ),
                    ),
                    SizedBox(height: 20*scaleFactor,),
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
                        fontSize: 25*scaleFactor,
                      ),
                    ),
                    SizedBox(height: 20*scaleFactor,),
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

    double sideInterval = (highest/10).roundToDouble();

    if(sideInterval<0.001){
      sideInterval = 1;
    }

    return Padding(
      padding: const EdgeInsets.all(6),
      child: AspectRatio(
        aspectRatio: 2,
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
                allowTouchBarBackDraw: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (groupData,a,rodData,b){
                    String date = DateFormat("d MMM").format(
                      DateTime(
                        2020,
                        DateTime.now().month,
                        DateTime.now().day-maxX+groupData.x,
                      ),
                    );
                    String val = NumberFormat(",##,###","hi_IN").format(
                      rodData.y.toInt(),
                    );
                    return BarTooltipItem(
                        "$date\n$val",
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
                    } else {
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
                  reservedSize: 20*scaleFactor,
                  showTitles: true,
                  interval: sideInterval,
                  getTitles: (double value){
                    if(value>100000){
                      return "${value.toString().substring(0,3)}.${value.toString().substring(3,4)}";
                    }else if(value>=10000){
                      return "${value.toString().substring(0,2)}.${value.toString().substring(2,3)}k";
                    }else if(value>=1000){
                      return "${value.toString().substring(0,1)}.${value.toString().substring(1,2)}k";
                    }

                    return value.toInt().toString();
                  },
                  textStyle: TextStyle(
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontSize: 10*scaleFactor,
                    fontFamily: kQuickSand
                  )
              ),
              bottomTitles: SideTitles(
                  rotateAngle: math.pi*90,
                  interval: 3,
                  margin: 20*scaleFactor,
                  reservedSize: 15*scaleFactor,
                  showTitles: true,
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
                    fontFamily: kQuickSand
                  )
              ),
            ),
            maxY: highest,
            backgroundColor: Colors.transparent,
            barGroups: barGroups,
            gridData: FlGridData(
              drawHorizontalLine: true,
              horizontalInterval: sideInterval,
              drawVerticalLine: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget _getLineChart(List<FlSpot> spots,double total,int maxX){

    double sideInterval = (total/10).roundToDouble();
    double bottomInterval = (maxX/10).roundToDouble();

    total = total + (total*0.1);

    if(sideInterval<0.001){
      sideInterval = 1;
    }

    return Padding(
      padding: const EdgeInsets.all(6),
      child: AspectRatio(
        aspectRatio: 2,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> list){
                  List<LineTooltipItem> returnList = List();

                  list.forEach((element) {
                    DateTime date = DateTime(
                      2020,
                      DateTime.now().month,
                      DateTime.now().day-maxX+element.x.toInt(),
                    );
                    String val = NumberFormat(",##,###","hi_IN").format(
                      element.y.toInt(),
                    );
                    returnList.add(
                      LineTooltipItem(
                        "${DateFormat("d MMM").format(date)}\n$val",
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
              touchCallback: (LineTouchResponse response) {
                setState(() {
                  if (response.lineBarSpots != null &&
                      response.touchInput is! FlPanEnd &&
                      response.touchInput is! FlLongPressEnd) {
                    //touchedIndex = barTouchResponse.spot.touchedBarGroupIndex;
                  } else {
                    //touchedIndex = -1;
                  }
                });
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
                    reservedSize: total<500?20*scaleFactor:20*scaleFactor,
                    textStyle: TextStyle(
                      fontSize: 10*scaleFactor,
                      color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                      fontFamily: kQuickSand,
                    ),
                    getTitles: (double value){
                      if(value >= 10000000){
                        return '${(value).toInt().toString().substring(0,2)}m';
                      }else if(value>=1000000){
                        return '${(value).toInt().toString().substring(0,1)}.${(value).toInt().toString().substring(1,2)}m';
                      }else if(value>=100000){
                        return '${(value).toInt().toString().substring(0,3)}k';
                      }else if(value>=10000){
                        return '${(value).toInt().toString().substring(0,2)}.${value.toString().substring(2,3)}k';
                      }else if(value>=1000){
                        return '${(value).toInt().toString().substring(0,1)}.${(value).toInt().toString().substring(1,2)}k';
                      }else{
                        return '${(value).toInt().toString()}';
                      }
                    }
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  rotateAngle: math.pi*90,
                  reservedSize: 15*scaleFactor,
                  margin: 10*scaleFactor,
                  interval: bottomInterval,
                  textStyle: TextStyle(
                    fontSize: 8*scaleFactor,
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontFamily: kQuickSand,
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

}