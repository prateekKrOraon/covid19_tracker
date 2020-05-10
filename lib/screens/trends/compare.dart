import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/analytics/math_functions.dart';
import 'package:covid19_tracker/utilities/helpers/data_range.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:covid19_tracker/utilities/models/country.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class CompareScreen extends StatefulWidget{
  @override
  _CompareScreenState createState() {
    return _CompareScreenState();
  }
}

class _CompareScreenState extends State<CompareScreen> with SingleTickerProviderStateMixin{

  double searchBoxHeight = 0;
  String _countryOne = "";
  String _countryTwo = "";
  Future _data;
  NetworkHandler _networkHandler = NetworkHandler.getInstance();
  String dataRange = DataRange.BEGINNING;
  ThemeData theme;
  Size size;
  double scaleFactor = 1;




  @override
  void initState() {
    super.initState();
  }

  void _getData(){
    _data = _networkHandler.getCompareResult(_countryOne.toLowerCase(), _countryTwo.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {

    theme = Theme.of(context);
    size = MediaQuery.of(context).size;
    AppLocalizations lang = AppLocalizations.of(context);

    if(size.width<=360){
      scaleFactor = 0.75;
    }

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.translate(kEnterCountryNameLang),
              style: TextStyle(
                fontFamily: kQuickSand,
                fontSize: 24*scaleFactor,
              ),
            ),
            SizedBox(height: 10*scaleFactor,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    height: 65*scaleFactor,
                    child: TextField(
                      cursorColor: theme.accentColor,
                      cursorWidth: 1,
                      textAlign: TextAlign.center,
                      onChanged: (String value){
                          _countryOne = value;
                      },
                      onSubmitted: (String value){
                        _countryOne = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 0,),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          borderSide: BorderSide(
                            width: 1,
                            color: theme.accentColor,
                          ),
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: kQuickSand,
                        fontSize: 20*scaleFactor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8*scaleFactor),
                  child: Text(
                    lang.translate(kVSLang),
                    style: TextStyle(
                      fontFamily: kQuickSand,
                      fontSize: 24*scaleFactor,
                      color: theme.accentColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 65*scaleFactor,
                    child: TextField(
                      textAlign: TextAlign.center,
                      cursorColor: theme.accentColor,
                      cursorWidth: 1,
                      onChanged: (String value){
                        _countryTwo = value;
                      },
                      onSubmitted: (String value){
                        _countryTwo = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 0,),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                            borderSide: BorderSide(
                              width: 1,
                              color: theme.accentColor,
                            )
                        ),
                      ),
                      style: TextStyle(
                        fontFamily: kQuickSand,
                        fontSize: 20*scaleFactor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16*scaleFactor,),
            Center(
              child: Container(
                height: 40*scaleFactor,
                child: RaisedButton(
                  color: theme.accentColor,
                  onPressed: (){
                    if(_countryOne != null && _countryTwo != null){
                      setState(() {
                        _getData();
                      });
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    lang.translate(kCompareLang),
                    style: TextStyle(
                      fontFamily: kQuickSand,
                      color: theme.brightness == Brightness.light?Colors.white:Colors.black,
                      fontSize: 18*scaleFactor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20*scaleFactor,),
            FutureBuilder(
              future: _data,
              builder: (BuildContext context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Container(
                    height: 200*scaleFactor,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if(snapshot.hasError){
                  print(snapshot.data);
                  return Text(
                    lang.translate(kCompareErrorLang),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kQuickSand,
                      color: kGreyColor,
                      fontSize: 16*scaleFactor,
                    ),
                  );
                }

                if(!snapshot.hasData){
                  return Text(
                    lang.translate(kHowToCompareLang),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kQuickSand,
                      color: kGreyColor,
                      fontSize: 16*scaleFactor,
                    ),
                  );
                }

                Map dataOne = snapshot.data[0];
                Map dataTwo = snapshot.data[1];
                if(dataOne.containsKey('result')){
                  if(dataOne['result'] == null){
                    return Container(
                      child: Center(
                        child: Text(
                          "$_countryOne ${lang.translate(kCountryNameError)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            color: kGreyColor,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                    );
                  }
                }
                if(dataTwo.containsKey('result')){
                  if(dataTwo['result'] == null){
                    return Container(
                      child: Center(
                        child: Text(
                          "$_countryOne ${lang.translate(kCountryNameError)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            color: kGreyColor,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                    );
                  }
                }
                if(dataOne.containsKey('country')){
                  if(dataOne['country'] == "error"){
                    return Container(
                      child: Center(
                        child: Text(
                          "$_countryOne ${lang.translate(kCountryNameError)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            color: kGreyColor,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                    );
                  }
                }
                if(dataTwo.containsKey('country')){
                  if(dataTwo['country'] == "error"){
                    return Container(
                      child: Center(
                        child: Text(
                          "$_countryTwo ${lang.translate(kCountryNameError)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            color: kGreyColor,
                            fontSize: 16*scaleFactor,
                          ),
                        ),
                      ),
                    );
                  }
                }

                Map countryOneTimeSeries = dataOne['result'];
                Map countryOneData = dataOne['details'];
                Map countryTwoTimeSeries = dataTwo['result'];
                Map countryTwoData = dataTwo['details'];

                Country countryOne = Country.fromMap(context, countryOneData);
                Country countryTwo = Country.fromMap(context, countryTwoData);
                countryOne.generateList(countryOneTimeSeries);
                countryTwo.generateList(countryTwoTimeSeries);


                List<EntryData> countryOneEntries = List();
                List<EntryData> countryTwoEntries = List();


                List<FlSpot> countryOneCnfSpots = List();
                List<FlSpot> countryTwoCnfSpots = List();

                List<FlSpot> countryOneActSpots = List();
                List<FlSpot> countryTwoActSpots = List();

                List<FlSpot> countryOneRecSpots = List();
                List<FlSpot> countryTwoRecSpots = List();

                List<FlSpot> countryOneDetSpots = List();
                List<FlSpot> countryTwoDetSpots = List();

                MathFunctions functions = MathFunctions();

                List<double> countryOneGF = functions.growthFactor(countryOne.cnfCasesSeries);
                List<double> countryTwoGF = functions.growthFactor(countryTwo.cnfCasesSeries);

                List<double> countryOneGr = functions.growthRatio(countryOne.cnfCasesSeries);
                List<double> countryTwoGr = functions.growthRatio(countryTwo.cnfCasesSeries);

                List<double> countryOneGR = functions.gradient(functions.getLog(countryOne.cnfCasesSeries));
                List<double> countryTwoGR = functions.gradient(functions.getLog(countryTwo.cnfCasesSeries));

                List<double> countryOneSD = functions.gradient(functions.gradient(countryOne.cnfCasesSeries));
                List<double> countryTwoSD = functions.gradient(functions.gradient(countryTwo.cnfCasesSeries));

                List<double> countryOneMR = functions.mortalityRate(countryOne.detCasesSeries, countryOne.cnfCasesSeries);
                List<double> countryTwoMR = functions.mortalityRate(countryTwo.detCasesSeries, countryTwo.cnfCasesSeries);

                List<double> countryOneRR = functions.mortalityRate(countryOne.recCasesSeries, countryOne.cnfCasesSeries);
                List<double> countryTwoRR = functions.mortalityRate(countryTwo.recCasesSeries, countryTwo.cnfCasesSeries);

                //Map<String,int> countryOneCases = functions.getCases(countryOne.cnfCasesSeries);
                //Map<String,int> countryTwoCases = functions.getCases(countryTwo.cnfCasesSeries);

                //List<CaseModel> countryOneCaseModel = List();
                //List<CaseModel> countryTwoCaseModel = List();

//                countryOneCases.forEach((key, value) {
//                  if(value != 0 && key != "100"){
//                    countryOneCaseModel.add(
//                      CaseModel(key, value),
//                    );
//                  }
//                });

//                countryOneCaseModel.sort((a,b) => double.parse(a.key).compareTo(double.parse(b.key)));
//
//                countryTwoCases.forEach((key, value) {
//                  if(value != 0 && key != "100"){
//                    countryTwoCaseModel.add(
//                      CaseModel(key, value),
//                    );
//                  }
//                });
//
//                countryTwoCaseModel.sort((a,b) => a.key.compareTo(b.key));
//
//                int caseModelLength = countryOneCaseModel.length>countryTwoCaseModel.length?
//                countryOneCaseModel.length:
//                countryTwoCaseModel.length;


                List<FlSpot> countryOneGFSpots = List();
                List<FlSpot> countryTwoGFSpots = List();

                List<FlSpot> countryOneGrSpots = List();
                List<FlSpot> countryTwoGrSpots = List();

                List<FlSpot> countryOneGRSpots = List();
                List<FlSpot> countryTwoGRSpots = List();

                List<FlSpot> countryOneSDSpots = List();
                List<FlSpot> countryTwoSDSpots = List();

                List<FlSpot> countryOneMRSpots = List();
                List<FlSpot> countryTwoMRSpots = List();

                List<FlSpot> countryOneRRSpots = List();
                List<FlSpot> countryTwoRRSpots = List();

                countryOneTimeSeries.forEach((key, value) {
                  countryOneEntries.add(
                    EntryData.fromMap(value),
                  );
                });
                countryTwoTimeSeries.forEach((key, value) {
                  countryTwoEntries.add(
                    EntryData.fromMap(value),
                  );
                });


                int length =
                countryOneTimeSeries.length>countryTwoTimeSeries.length?
                countryOneTimeSeries.length:
                countryTwoTimeSeries.length;

                double cnfHighest = 0;
                double actTotal = 0;
                double recTotal = 0;
                double detTotal = 0;
                double gfHighest = 0;
                double grHighest = 0;
                double gRHighest = 0;
                double sdHighest = 0;
                double mrHighest = 0;
                double rrHighest = 0;

                for(int i = 0;i<length;i++){
                  if(countryOneEntries.length-length<=i){
                    if(countryOneEntries[i].confirmed>cnfHighest){
                      cnfHighest = countryOneEntries[i].confirmed.toDouble();
                    }

                    countryOneCnfSpots.add(
                      FlSpot(
                        i.toDouble(),
                        countryOneEntries[i].confirmed.toDouble(),
                      ),
                    );

                    if(countryOneEntries[i].confirmed-countryOneEntries[i].recovered-countryOneEntries[i].deaths>actTotal){
                      actTotal = countryOneEntries[i].confirmed-countryOneEntries[i].recovered-countryOneEntries[i].deaths.toDouble();
                    }

                    int active = countryOneEntries[i].confirmed-countryOneEntries[i].recovered-countryOneEntries[i].deaths;
                    if(active <0){
                      active = 0;
                    }

                    countryOneActSpots.add(
                      FlSpot(
                        i.toDouble(),
                        active.toDouble(),
                      )
                    );

                    if(countryOneEntries[i].recovered>recTotal){
                      recTotal = countryOneEntries[i].recovered.toDouble();
                    }

                    countryOneRecSpots.add(
                      FlSpot(
                        i.toDouble(),
                        countryOneEntries[i].recovered.toDouble(),
                      )
                    );

                    if(countryOneEntries[i].deaths>detTotal){
                      detTotal = countryOneEntries[i].deaths.toDouble();
                    }

                    countryOneDetSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryOneEntries[i].deaths.toDouble(),
                        )
                    );

                    if(countryOneGF[i]>gfHighest){
                      gfHighest = countryOneGF[i];
                    }
                    countryOneGFSpots.add(
                      FlSpot(
                        i.toDouble(),
                        countryOneGF[i],
                      )
                    );

                    if(countryOneGr[i]>grHighest){
                      grHighest = countryOneGr[i];
                    }
                    countryOneGrSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryOneGr[i],
                        )
                    );

                    if(countryOneGR[i]>gRHighest){
                      gRHighest = countryOneGR[i];
                    }
                    countryOneGRSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryOneGR[i],
                        )
                    );

                    if(countryOneSD[i]>sdHighest){
                      sdHighest = countryOneSD[i];
                    }
                    countryOneSDSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryOneSD[i],
                        )
                    );

                    if(countryOneMR[i]>mrHighest){
                      mrHighest = countryOneMR[i];
                    }
                    countryOneMRSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryOneMR[i],
                        )
                    );

                    if(countryOneRR[i]>rrHighest){
                      rrHighest = countryOneRR[i];
                    }
                    countryOneRRSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryOneRR[i],
                        )
                    );

                  }
                  if(countryTwoEntries.length-length<=i){
                    if(countryTwoEntries[i].confirmed>cnfHighest){
                      cnfHighest = countryTwoEntries[i].confirmed.toDouble();
                    }

                    countryTwoCnfSpots.add(
                      FlSpot(
                        i.toDouble(),
                        countryTwoEntries[i].confirmed.toDouble(),
                      ),
                    );

                    if(countryTwoEntries[i].confirmed-countryTwoEntries[i].recovered-countryTwoEntries[i].deaths>actTotal){
                      actTotal = countryTwoEntries[i].confirmed-countryTwoEntries[i].recovered-countryTwoEntries[i].deaths.toDouble();
                    }

                    int active = countryTwoEntries[i].confirmed-countryTwoEntries[i].recovered-countryTwoEntries[i].deaths;
                    if(active<0){
                      active = 0;
                    }
                    countryTwoActSpots.add(
                        FlSpot(
                          i.toDouble(),
                          active.toDouble(),
                        )
                    );

                    if(countryTwoEntries[i].recovered>recTotal){
                      recTotal = countryTwoEntries[i].recovered.toDouble();
                    }

                    countryTwoRecSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryTwoEntries[i].recovered.toDouble(),
                        )
                    );

                    if(countryTwoEntries[i].deaths>detTotal){
                      detTotal = countryTwoEntries[i].deaths.toDouble();
                    }

                    countryTwoDetSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryTwoEntries[i].deaths.toDouble(),
                        )
                    );

                    if(countryTwoGF[i]>gfHighest){
                      gfHighest = countryTwoGF[i];
                    }
                    countryTwoGFSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryTwoGF[i],
                        )
                    );

                    if(countryTwoGr[i]>grHighest){
                      grHighest = countryTwoGr[i];
                    }
                    countryTwoGrSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryTwoGr[i],
                        )
                    );

                    if(countryTwoGR[i]>gRHighest){
                      gRHighest = countryTwoGR[i];
                    }
                    countryTwoGRSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryTwoGR[i],
                        )
                    );

                    if(countryTwoSD[i]>sdHighest){
                      sdHighest = countryTwoSD[i];
                    }
                    countryTwoSDSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryTwoSD[i],
                        )
                    );

                    if(countryTwoMR[i]>mrHighest){
                      mrHighest = countryTwoMR[i];
                    }
                    countryTwoMRSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryTwoMR[i],
                        )
                    );

                    if(countryTwoRR[i]>rrHighest){
                      rrHighest = countryTwoRR[i];
                    }
                    countryTwoRRSpots.add(
                        FlSpot(
                          i.toDouble(),
                          countryTwoRR[i],
                        )
                    );

                  }
                }


                List<Widget> firstGroupCharts = List();
                firstGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kConfirmedCasesLang),
                    countryOneCnfSpots,
                    countryTwoCnfSpots,
                    countryOneCnfSpots[countryOneCnfSpots.length-1].y.toInt().toString(),
                    countryTwoCnfSpots[countryTwoCnfSpots.length-1].y.toInt().toString(),
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    cnfHighest,
                    length,
                  ),
                );
                firstGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kActiveCasesLang),
                    countryOneActSpots,
                    countryTwoActSpots,
                    countryOneActSpots[countryOneActSpots.length-1].y.toInt().toString(),
                    countryTwoActSpots[countryTwoActSpots.length-1].y.toInt().toString(),
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    actTotal,
                    length,
                  ),
                );
                firstGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kRecoveredLang),
                    countryOneRecSpots,
                    countryTwoRecSpots,
                    countryOneRecSpots[countryOneRecSpots.length-1].y.toInt().toString(),
                    countryTwoRecSpots[countryTwoRecSpots.length-1].y.toInt().toString(),
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    recTotal,
                    length,
                  ),
                );
                firstGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kDeceasedCasesLang),
                    countryOneDetSpots,
                    countryTwoDetSpots,
                    countryOneDetSpots[countryOneDetSpots.length-1].y.toInt().toString(),
                    countryTwoDetSpots[countryTwoDetSpots.length-1].y.toInt().toString(),
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    detTotal,
                    length,
                  ),
                );

                List<Widget> secondGroupCharts = List();
                secondGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kGrowthFactorLang),
                    countryOneGFSpots,
                    countryTwoGFSpots,
                    countryOneGFSpots[countryOneGFSpots.length-1].y.toStringAsFixed(2),
                    countryTwoGFSpots[countryTwoGFSpots.length-1].y.toStringAsFixed(2),
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    gfHighest,
                    length,
                    more: true,
                  ),
                );
                secondGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kGrowthRatioLang),
                    countryOneGrSpots,
                    countryTwoGrSpots,
                    countryOneGrSpots[countryOneGrSpots.length-1].y.toStringAsFixed(2),
                    countryTwoGrSpots[countryTwoGrSpots.length-1].y.toStringAsFixed(2),
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    grHighest,
                    length,
                    more: true,
                  ),
                );
                secondGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kGrowthRateLang),
                    countryOneGRSpots,
                    countryTwoGRSpots,
                    "${(countryOneGRSpots[countryOneGRSpots.length-1].y*100).toStringAsFixed(2)} %",
                    "${(countryTwoGRSpots[countryTwoGRSpots.length-1].y*100).toStringAsFixed(2)} %",
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    gRHighest,
                    length,
                    more: true,
                  ),
                );
                secondGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kSecondDerivativeLang),
                    countryOneSDSpots,
                    countryTwoSDSpots,
                    countryOneSDSpots[countryOneSDSpots.length-1].y<0?"Negative":"Positive",
                    countryTwoSDSpots[countryTwoSDSpots.length-1].y<0?"Negative":"Positive",
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    sdHighest,
                    length,
                    more: true,
                  ),
                );

                List<Widget> thirdGroupCharts = List();
                thirdGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kMortalityRateLang),
                    countryOneMRSpots,
                    countryTwoMRSpots,
                    "${countryOneMRSpots[countryOneMRSpots.length-1].y.toStringAsFixed(2)} %",
                    "${countryTwoMRSpots[countryTwoMRSpots.length-1].y.toStringAsFixed(2)} %",
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    mrHighest,
                    length,
                    more: true,
                  ),
                );
                thirdGroupCharts.add(
                  _getLineChartLayout(
                    lang.translate(kRecoveryRateLang),
                    countryOneRRSpots,
                    countryTwoRRSpots,
                    "${countryOneRRSpots[countryOneRRSpots.length-1].y.toStringAsFixed(2)} %",
                    "${countryTwoRRSpots[countryTwoRRSpots.length-1].y.toStringAsFixed(2)} %",
                    countryOne.flagLink,
                    countryTwo.flagLink,
                    rrHighest,
                    length,
                    more: true,
                  ),
                );


                return Container(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height:60*scaleFactor,
                              child: Center(
                                child: Image(
                                  image: NetworkImage(
                                    countryOne.flagLink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height:20*scaleFactor,
                              width:20*scaleFactor,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: kGreenColor,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              height:20*scaleFactor,
                              width:20*scaleFactor,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: kRedColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height:60*scaleFactor,
                              child: Center(
                                child: Image(
                                  image: NetworkImage(
                                    countryTwo.flagLink,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height:50*scaleFactor,
                              child: Center(
                                child: Text(
                                  countryOne.displayName,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 18*scaleFactor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            child: Container(
                              child: Center(
                                child: Text(
                                  lang.translate(kVSLang),
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 20*scaleFactor,
                                    color: theme.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height:50*scaleFactor,
                              child: Center(
                                child: Text(
                                  countryTwo.displayName,
                                  textAlign:TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 20*scaleFactor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: size.width*0.8,
                        child: Center(
                          child: PageView.builder(
                            itemCount: firstGroupCharts.length,
                            controller: PageController(
                              initialPage: 0,
                              viewportFraction: 0.95,
                            ),
                            itemBuilder: (BuildContext context,int index){
                              return firstGroupCharts[index];
                            },
                          ),
                        ),
                      ),
                      Container(
                        height: size.width*0.8,
                        child: Center(
                          child: PageView.builder(
                            itemCount: secondGroupCharts.length,
                            controller: PageController(
                              initialPage: 0,
                              viewportFraction: 0.95,
                            ),
                            itemBuilder: (BuildContext context,int index){
                              return secondGroupCharts[index];
                            },
                          ),
                        ),
                      ),
                      Container(
                        height: size.width*0.8,
                        width:size.width,
                        child: Center(
                          child: PageView.builder(
                            controller: PageController(
                              initialPage: 0,
                              viewportFraction: 0.95
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: thirdGroupCharts.length,
                            itemBuilder: (BuildContext context,int index){
                              return thirdGroupCharts[index];
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 16*scaleFactor,),
//                      Material(
//                        borderRadius: BorderRadius.all(
//                          Radius.circular(10)
//                        ),
//                        elevation: 2,
//                        color: theme.backgroundColor,
//                        child: Container(
//                          padding: EdgeInsets.all(10),
//                          child: Column(
//                            children: [
//                              Row(
//                                children: [
//                                  Expanded(
//                                    child: Text(
//                                      lang.translate(kCasesLang),
//                                      textAlign:TextAlign.left,
//                                      style: TextStyle(
//                                        fontFamily: kQuickSand,
//                                        fontSize: 18*scaleFactor,
//                                        color: theme.accentColor,
//                                      ),
//                                    ),
//                                  ),
//                                  Expanded(
//                                    child: Text(
//                                      countryOne.iso3,
//                                      textAlign:TextAlign.center,
//                                      style: TextStyle(
//                                        fontFamily: kQuickSand,
//                                        fontSize: 18*scaleFactor,
//                                        color: theme.accentColor,
//                                      ),
//                                    ),
//                                  ),
//                                  Expanded(
//                                    child: Text(
//                                      "Diff.",
//                                      textAlign:TextAlign.center,
//                                      style: TextStyle(
//                                        fontFamily: kQuickSand,
//                                        fontSize: 18*scaleFactor,
//                                        color: theme.accentColor,
//                                      ),
//                                    ),
//                                  ),
//                                  Expanded(
//                                    child: Text(
//                                      countryTwo.iso3,
//                                      textAlign:TextAlign.center,
//                                      style: TextStyle(
//                                        fontFamily: kQuickSand,
//                                        fontSize: 18*scaleFactor,
//                                        color: theme.accentColor,
//                                      ),
//                                    ),
//                                  ),
//                                  Expanded(
//                                    child: Text(
//                                      "Diff.",
//                                      textAlign:TextAlign.center,
//                                      style: TextStyle(
//                                        fontFamily: kQuickSand,
//                                        fontSize: 18*scaleFactor,
//                                        color: theme.accentColor,
//                                      ),
//                                    ),
//                                  ),
//                                ],
//                              ),
//                              Divider(color: kGreyColor,),
//                              ListView.builder(
//                                shrinkWrap: true,
//                                physics: NeverScrollableScrollPhysics(),
//                                itemCount: caseModelLength,
//                                itemBuilder: (BuildContext context,int index){
//
//                                  bool one = countryOneCaseModel.length>index;
//                                  bool two = countryTwoCaseModel.length>index;
//
//                                  return Column(
//                                    children: [
//                                      Row(
//                                        children: [
//                                          Expanded(
//                                            child: Text(
//                                              caseModelLength==countryOneCaseModel.length?countryOneCaseModel[index].key:countryTwoCaseModel[index].key,
//                                              textAlign:TextAlign.left,
//                                              style: TextStyle(
//                                                fontFamily: kQuickSand,
//                                                fontSize: 16*scaleFactor,
//                                              ),
//                                            ),
//                                          ),
//                                          Expanded(
//                                            child: Text(
//                                              one?countryOneCaseModel[index].value.toString():"",
//                                              textAlign:TextAlign.center,
//                                              style: TextStyle(
//                                                fontFamily: kQuickSand,
//                                                fontSize: 16*scaleFactor,
//                                              ),
//                                            ),
//                                          ),
//                                          Expanded(
//                                            child: Text(
//                                              one?index==0?"${countryOneCaseModel[index].value}":"${countryOneCaseModel[index].value-countryOneCaseModel[index-1].value}":"",
//                                              textAlign: TextAlign.center,
//                                              style:TextStyle(
//                                                fontFamily: kQuickSand,
//                                                fontSize: 16*scaleFactor,
//                                              ),
//                                            ),
//                                          ),
//                                          Expanded(
//                                            child: Text(
//                                              two?countryTwoCaseModel[index].value.toString():"",
//                                              textAlign:TextAlign.center,
//                                              style: TextStyle(
//                                                fontFamily: kQuickSand,
//                                                fontSize: 16*scaleFactor,
//                                              ),
//                                            ),
//                                          ),
//                                          Expanded(
//                                            child: Text(
//                                              two?index==0?"${countryTwoCaseModel[index].value}":"${countryTwoCaseModel[index].value-countryTwoCaseModel[index-1].value}":"",
//                                              textAlign: TextAlign.center,
//                                              style:TextStyle(
//                                                fontFamily: kQuickSand,
//                                                fontSize: 16*scaleFactor,
//                                              ),
//                                            ),
//                                          ),
//                                        ],
//                                      ),
//                                      Divider(),
//                                    ],
//                                  );
//                                },
//                              ),
//                            ],
//                          ),
//                        ),
//                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _getLineChartLayout(String caseStr,List<FlSpot> spotsOne,List<FlSpot> spotsTwo,String valueOne, String valueTwo,String flagOne,String flagTwo,double total,int maxX,{bool more=false}){
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
                width: size.width-40,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      caseStr,
                      style: TextStyle(
                        fontFamily: kQuickSand,
                        fontSize: 24*scaleFactor,
                      ),
                    ),
                    SizedBox(height: 8*scaleFactor,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image(
                              height:24*scaleFactor,
                              image: NetworkImage(
                                flagOne,
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(
                              valueOne,
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 18*scaleFactor,
                                color: kGreenColor
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image(
                              height:24*scaleFactor,
                              image: NetworkImage(
                                flagTwo,
                              ),
                            ),
                            SizedBox(width: 5,),
                            Text(
                              valueTwo,
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 18*scaleFactor,
                                color: kRedColor
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20*scaleFactor,),
                    more?_getLineChartForMoreAnalysis(spotsOne,spotsTwo, total, maxX):_getLineChart(spotsOne,spotsTwo,total,maxX),
                  ],
                ),
              ),
            ),
          ),
        ]
    );
  }

  Widget _getLineChart(List<FlSpot> spotsOne,List<FlSpot> spotsTwo,double total,int maxX){

    //total<=10000?total<=5000?total<500?total<100?50:100:500:5000:total<=50000?10000:total<=100000?25000:total>500000?100000:50000;

    double bottomInterval = 1;
    double sideInterval = (total/8).roundToDouble();

    if(dataRange == DataRange.BEGINNING){
      bottomInterval = double.parse((maxX/10).toStringAsFixed(2));
    }else if(dataRange == DataRange.MONTH){
      bottomInterval = double.parse((maxX/10).toStringAsFixed(2));
    }else if(dataRange == DataRange.TWO_WEEK){
      bottomInterval = double.parse((maxX/7).toStringAsFixed(2));
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: AspectRatio(
        aspectRatio: 1.75,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBottomMargin: 20,
                tooltipBgColor: Colors.black.withOpacity(0.8),
                getTooltipItems: (List<LineBarSpot> list){
                  List<LineTooltipItem> tooltipItems = List();
                  list.forEach((element) {
                    DateTime date = DateTime(
                      2020,
                      1,
                      22+element.x.toInt(),
                    );
                    tooltipItems.add(
                      LineTooltipItem(
                        "${DateFormat("d MMM").format(date)}\n${element.y.toInt()}",
                        TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 14*scaleFactor,
                          fontWeight: FontWeight.bold,
                          color: element.bar.colors[0],
                        ),
                      ),
                    );
                  });
                  return tooltipItems;
                },
              ),
              touchCallback: (LineTouchResponse touchResponse) {},
              handleBuiltInTouches: true,
            ),
            maxY: total+100,
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
;
                    }
                ),
                bottomTitles: SideTitles(
                  showTitles: true,
                  rotateAngle: math.pi*90,
                  reservedSize: 15*scaleFactor,
                  interval: bottomInterval,
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
                colors: [kGreenColor],
                spots: spotsOne,
              ),
              LineChartBarData(
                dotData: FlDotData(
                  dotSize: dataRange == DataRange.BEGINNING?0:2,
                  strokeWidth: 0,
                ),
                isCurved: false,
                barWidth: 2,
                isStrokeCapRound: true,
                colors: [kRedColor],
                spots: spotsTwo,
              ),
            ],
          ),
        ),
      ),
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
                  getTooltipItem: (groupData,a,rodData,b){
                    return BarTooltipItem(
                      "${rodData.y}",
                      TextStyle(
                        fontFamily: kQuickSand,
                        color: theme.brightness == Brightness.light?Colors.white:Colors.black,
                      ),
                    );
                  },
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
                  reservedSize: 15*scaleFactor,
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
                    fontSize: 10*scaleFactor,
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
                    fontSize: 8*scaleFactor,
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

  Widget _getLineChartForMoreAnalysis(List<FlSpot> spotsOne,List<FlSpot> spotsTwo,double total,int maxX){
    int bottomTitleInterval = 0;
    double sideInterval = 2;
    double multiplier = 0;
    double maxY = 0;



    if(dataRange == DataRange.BEGINNING){
      bottomTitleInterval = (maxX/10).round();
    }else if(dataRange == DataRange.MONTH){
      bottomTitleInterval = (maxX/3).round();
    }else if(dataRange == DataRange.TWO_WEEK){
      bottomTitleInterval = (maxX/2).round();
    }

    sideInterval = (total/8);
    maxY = total;
//    if(total>3000){
//      sideInterval = 700;
//      maxY = total+500;
//    }else if(total>2000){
//      sideInterval = 500;
//      maxY = total+500;
//    }else if(total > 500){
//      sideInterval = 300;
//      maxY = total+250;
//    }else if(total >100){
//      sideInterval = 100;
//      maxY = total+50;
//    }else if(total > 50){
//      sideInterval = 20;
//      maxY = total+25;
//    }else if(total > 10){
//      sideInterval = 10;
//      maxY = total+5;
//    }else if(total > 6){
//      sideInterval = 1;
//      maxY = total+500+3;
//    }else if(total > 3){
//      sideInterval = 1;
//      maxY = total+1.5;
//    }else if (total > 1){
//      sideInterval = 0.5;
//      maxY = total+0.5;
//    }else if(sideInterval>0.5){
//      sideInterval = 0.1;
//      maxY = total+0.25;
//    }else{
//      sideInterval = 0.05;
//      maxY = total;
//    }


    return Padding(
      padding: const EdgeInsets.all(6),
      child: AspectRatio(
        aspectRatio: 1.75,
        child: LineChart(
          LineChartData(
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBottomMargin: 20,
                getTooltipItems: (List<LineBarSpot> list){
                  List<LineTooltipItem> tooltipItems = List();
                  list.forEach((element) {
                    DateTime date = DateTime(
                      2020,
                      1,
                      22+element.x.toInt(),
                    );
                    tooltipItems.add(
                      LineTooltipItem(
                        "${DateFormat("d MMM").format(date)}\n${element.y.toStringAsFixed(2)}",
                        TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 14*scaleFactor,
                          fontWeight: FontWeight.bold,
                          color: element.bar.colors[0],
                        ),
                      ),
                    );
                  });

                  return tooltipItems;
                },
                tooltipBgColor: Colors.black.withOpacity(0.8),
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
              horizontalInterval: sideInterval.toDouble(),
            ),
            titlesData: FlTitlesData(
                leftTitles: SideTitles(
                  showTitles: false,
                ),
                rightTitles: SideTitles(
                  showTitles: true,
                  interval: sideInterval.toDouble(),
                  reservedSize: 20*scaleFactor,
                  textStyle: TextStyle(
                    fontSize: 10*scaleFactor,
                    color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                    fontFamily: kNotoSansSc,
                  ),
                  getTitles: (double value){
                    String val = value.toString();

//                    if(value>0){
//                      if(val.length<4){
//                        val = value.toStringAsFixed(2);
//                      }else if(val.length>=6){
//                        val = value.toInt().toString();
//                      }if(val.length>=4){
//                        val = value.toInt().toString();
//                      }
//                    }else if(value<0){
//                      if(val.length<5){
//                        val = value.toInt().toString();
//                      }else if(val.length>=7){
//                        val = value.toInt().toString();
//                      }if(val.length>=5){
//                        val = value.toInt().toString();
//                      }
//                    }

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
                  interval: bottomTitleInterval.toDouble(),
                  margin: 15*scaleFactor,
                  reservedSize: 15*scaleFactor,
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
                      now.day-maxX+value.toInt(),
                    );
                    return DateFormat("d MMM").format(returnDate);
                  },
                )
            ),
            lineBarsData: [
              LineChartBarData(
                curveSmoothness: 0.1,
                dotData: FlDotData(
                  dotSize: 0,
                  strokeWidth: 0,
                ),
                isCurved: true,
                barWidth: 2,
                isStrokeCapRound: true,
                colors: [kGreenColor],
                spots: spotsOne,
              ),
              LineChartBarData(
                dotData: FlDotData(
                  dotSize: 0,
                  strokeWidth: 0,
                ),
                isCurved: true,
                barWidth: 2,
                isStrokeCapRound: true,
                colors: [kRedColor],
                spots: spotsTwo,
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class EntryData{
  int confirmed;
  int recovered;
  int deaths;

  EntryData.fromMap(Map map){
    this.confirmed = map[kConfirmed];
    this.recovered = map[kRecovered];
    this.deaths = map[kDeaths];
  }
}

class CaseModel{
  String key;
  int value;

  CaseModel(this.key,this.value);
}