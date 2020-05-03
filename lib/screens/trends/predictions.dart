import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/data/sird_model.dart';
import 'package:covid19_tracker/data/state_wise_data.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

import '../error_screen.dart';

class Predictions extends StatefulWidget{
  @override
  _PredictionState createState() {
    return _PredictionState();
  }
}

class _PredictionState extends State<Predictions>{
  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    AppLocalizations lang = AppLocalizations.of(context);
    ThemeData theme = Theme.of(context);

    return FutureBuilder(
      future: StateWiseData.getInstance(),
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

        SIRD sird = SIRD();
        Map map = snapshot.data;

        String lastUpdateStr = map[kStateWise][0][kLastUpdated].toString();
        print(lastUpdateStr);

        DateTime lastUpdate = DateTime(
          int.parse(lastUpdateStr.substring(6,10)),
          int.parse(lastUpdateStr.substring(3,5)),
          int.parse(lastUpdateStr.substring(0,2)),
          int.parse(lastUpdateStr.substring(11,13)),
          int.parse(lastUpdateStr.substring(14,16)),
          int.parse(lastUpdateStr.substring(17,19)),
        );

        //print(map);
        sird.parseData(map);

        List<Map<String,double>> predictedValues = sird.predict();
        List<Prediction> predictions = List();
        predictedValues.forEach((element) {
          predictions.add(
            Prediction.fromMap(element),
          );
        });

        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
            width: size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's actual cases",
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 24,
                  ),
                ),
                Text(
                  "Last Updated at: ${DateFormat("d MMM, ").add_jm().format(lastUpdate)}",
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 14,
                    color: kGreenColor,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              lang.translate(kConfirmedLang),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 16,
                                color: kRedColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              lang.translate(kActiveLang),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 16,
                                color: kBlueColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              lang.translate(kRecoveredLang),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 16,
                                color: kGreenColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              lang.translate(kDeathsLang),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  map[kStateWise][0][kConfirmed],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 24,
                                    color: kRedColor,
                                  ),
                                ),
                                Text(
                                  "(+${map[kStateWise][0][kDeltaConfirmed]})",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 16,
                                    color: kRedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  map[kStateWise][0][kActive],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 24,
                                    color: kBlueColor,
                                  ),
                                ),
                                Text(
                                  "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 16,
                                    color: kBlueColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  map[kStateWise][0][kRecovered],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 24,
                                    color: kGreenColor,
                                  ),
                                ),
                                Text(
                                  "(+${map[kStateWise][0][kDeltaRecovered]})",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 16,
                                    color: kGreenColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  map[kStateWise][0][kDeaths],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 24,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  "(+${map[kStateWise][0][kDeltaDeaths]})",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24,),
                Text(
                  "5 Days Prediction",
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 8,),
                Text(
                  "The values are estimated as per SIRD epidemic model. These numbers are not accurate and are subjected to change over time.",
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 16,
                    color: kGreyColor,
                  ),
                ),
                SizedBox(height: 8,),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: (){

                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            SimpleLineIcons.info,
                            size: 14,
                            color: kGreyColor,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            "Know how it works.",
                            style: TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 16,
                              color: kGreyColor,
                            ),
                          ),
                          SizedBox(width: 5,),
                          Icon(
                            Icons.launch,
                            size: 14,
                            color: kGreyColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8,),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: predictions.length,
                  itemBuilder: (BuildContext context,int index){

                    String date = DateFormat("d MMM y").format(
                      DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day+index,
                      ),
                    );

                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: Material(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        elevation: 4,
                        color: theme.backgroundColor,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 20,
                                    color: theme.accentColor,
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lang.translate(kConfirmedLang),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: kQuickSand,
                                          fontSize: 16,
                                          color: kRedColor,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        lang.translate(kActiveLang),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: kQuickSand,
                                          fontSize: 16,
                                          color: kBlueColor,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        lang.translate(kRecoveredLang),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: kQuickSand,
                                          fontSize: 16,
                                          color: kGreenColor,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        lang.translate(kDeathsLang),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: kQuickSand,
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: kGreyColor,
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            predictions[index].confirmed.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: kQuickSand,
                                              fontSize: 24,
                                              color: kRedColor,
                                            ),
                                          ),
                                          Text(
                                            "(+${predictions[index].deltaConfirmed})",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: kQuickSand,
                                              fontSize: 16,
                                              color: kRedColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            predictions[index].active.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: kQuickSand,
                                              fontSize: 24,
                                              color: kBlueColor,
                                            ),
                                          ),
                                          Text(
                                            "(+${predictions[index].deltaActive})",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: kQuickSand,
                                              fontSize: 16,
                                              color: kBlueColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            predictions[index].recovered.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: kQuickSand,
                                              fontSize: 24,
                                              color: kGreenColor,
                                            ),
                                          ),
                                          Text(
                                            "(+${predictions[index].deltaRecovered})",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: kQuickSand,
                                              fontSize: 16,
                                              color: kGreenColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            predictions[index].deaths.toString(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: kQuickSand,
                                              fontSize: 24,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            "(+${predictions[index].deltaDeaths})",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: kQuickSand,
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Prediction{

  int confirmed;
  int active;
  int recovered;
  int deaths;
  int deltaConfirmed;
  int deltaRecovered;
  int deltaDeaths;
  int deltaActive;

  Prediction.fromMap(Map<String,double> map){
    this.active = map['totalactive'].toInt();
    this.recovered = map[kTotalRecovered].toInt();
    this.deaths = map[kTotalDeaths].toInt();
    this.confirmed = active+recovered+deaths;
    this.deltaActive = map['deltaactive'].toInt();
    this.deltaConfirmed = map[kDeltaConfirmed].toInt();
    this.deltaDeaths = map[kDeltaDeaths].toInt();
    this.deltaRecovered = map[kDeltaRecovered].toInt();
  }

}