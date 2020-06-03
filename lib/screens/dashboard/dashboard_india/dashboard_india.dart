/*
*
* Dashboard for India only
*
*/

import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/error_screen.dart';
import 'package:covid19_tracker/screens/dashboard/dashboard_india/sources_list.dart';
import 'package:covid19_tracker/screens/dashboard/dashboard_india/state_data_screen.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/utilities/custom_widgets/custom_widgets.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:covid19_tracker/data/state_wise_data.dart';
import 'package:covid19_tracker/utilities/helpers/sorting.dart';
import 'package:covid19_tracker/utilities/models/state_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

class DashboardIndia extends StatefulWidget{
  @override
  _DashboardIndiaState createState() {
    return _DashboardIndiaState();
  }

}

class _DashboardIndiaState extends State<DashboardIndia>{

  double scaleFactor = 1;
  SortingOrder sortingOrder;

  ThemeData theme;
  bool refresh = false;


  @override
  void initState() {
    sortingOrder = SortingOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    AppLocalizations lang = AppLocalizations.of(context);
    theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    if(size.width<400){
      scaleFactor = 0.75;
    }else if(size.width<=450){
      scaleFactor = 0.9;
    }

    return FutureBuilder(
      future: StateWiseData.getIndiaDashboard(),
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
        String lastUpdateStr = map[kStateWise][0][kLastUpdated].toString();

        DateTime lastUpdate = DateTime(
          int.parse(lastUpdateStr.substring(6,10)),
          int.parse(lastUpdateStr.substring(3,5)),
          int.parse(lastUpdateStr.substring(0,2)),
          int.parse(lastUpdateStr.substring(11,13)),
          int.parse(lastUpdateStr.substring(14,16)),
          int.parse(lastUpdateStr.substring(17,19)),
        );

        Map tested = map[kTotalTested];
        String dateStr = tested[kUpdateTimeStamp];
        DateTime testedLastUpdate = DateTime(
          int.parse(dateStr.substring(6,10)),
          int.parse(dateStr.substring(3,5)),
          int.parse(dateStr.substring(0,2)),
          int.parse(dateStr.substring(11,13)),
          int.parse(dateStr.substring(14,16)),
          int.parse(dateStr.substring(17,19)),
        );

        List stateWise = map[kStateWise];
        List<StateInfo> stateList = List();
        for(int i = 1;i<stateWise.length;i++){
          Map state = stateWise[i];
          stateList.add(
            StateInfo.fromMap(context,state),
          );
        }



        if(sortingOrder.checkOrder(SortingOrder.CNF_DEC)){
          stateList.sort((a,b) => b.confirmed.compareTo(a.confirmed));
        }else if(sortingOrder.checkOrder(SortingOrder.CNF_INC)){
          stateList.sort((a,b) => a.confirmed.compareTo(b.confirmed));
        }else if (sortingOrder.checkOrder(SortingOrder.STATE_DEC)){
          stateList.sort((a,b) => b.stateName.compareTo(a.stateName));
        }else if (sortingOrder.checkOrder(SortingOrder.STATE_INC)){
          stateList.sort((a,b) => a.stateName.compareTo(b.stateName));
        }else if (sortingOrder.checkOrder(SortingOrder.ACTV_DEC)){
          stateList.sort((a,b) => b.active.compareTo(a.active));
        }else if (sortingOrder.checkOrder(SortingOrder.ACTV_INC)){
          stateList.sort((a,b) => a.active.compareTo(b.active));
        }else if (sortingOrder.checkOrder(SortingOrder.REC_DEC)){
          stateList.sort((a,b) => b.recovered.compareTo(a.recovered));
        }else if (sortingOrder.checkOrder(SortingOrder.REC_INC)){
          stateList.sort((a,b) => a.recovered.compareTo(b.recovered));
        }else if (sortingOrder.checkOrder(SortingOrder.DET_DEC)){
          stateList.sort((a,b) => b.deaths.compareTo(a.deaths));
        }else if (sortingOrder.checkOrder(SortingOrder.DET_INC)){
          stateList.sort((a,b) => a.deaths.compareTo(b.deaths));
        }


        return RefreshIndicator(
          onRefresh: (){
            setState(() {
              StateWiseData.refresh();
            });
            return Future(()=>null);
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "${lang.translate(kLastUpdatedAtLang)}: ${DateFormat("d MMM, ").add_jm().format(lastUpdate)} IST",
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: 16*scaleFactor,
                          fontFamily: kQuickSand,
                        ),
                      ),
                    ),
                    SizedBox(height: 16*scaleFactor,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              DashboardTile(
                                mainTitle: lang.translate(kTotalCnfLang),
                                value: map[kStateWise][0][kConfirmed],
                                delta: map[kStateWise][0][kDeltaConfirmed],
                                color: kRedColor,
                              ),
                              SizedBox(width: 10*scaleFactor,),
                              DashboardTile(
                                mainTitle: lang.translate(kTotalActvLang),
                                value: map[kStateWise][0][kActive],
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
                                value: map[kStateWise][0][kRecovered],
                                delta: map[kStateWise][0][kDeltaRecovered],
                                color: kGreenColor,
                              ),
                              SizedBox(width: 10*scaleFactor,),
                              DashboardTile(
                                mainTitle: lang.translate(kTotalDetLang),
                                value: map[kStateWise][0][kDeaths],
                                delta: map[kStateWise][0][kDeltaDeaths],
                                color: Colors.grey,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 10*scaleFactor,),
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
                                        tested[kTotalIndividualTested]==""?lang.translate(kTotalSampleTestedLang):lang.translate(kTotalTestedLang),
                                        style: TextStyle(
                                          fontFamily: kQuickSand,
                                          fontSize: 24*scaleFactor,
                                          color: kDarkBlueColor,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        tested[kTotalIndividualTested]==""?
                                        NumberFormat(",###").format(double.parse(tested[kTotalSamplesTested].toString())):
                                        NumberFormat(",###").format(double.parse(tested[kTotalIndividualTested].toString())),
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
                                        '${lang.translate(kLastUpdatedAtLang)} ${testedLastUpdate.millisecondsSinceEpoch>DateTime.now().millisecondsSinceEpoch?"\t--\t":DateFormat("d MMM, ").add_jm().format(testedLastUpdate)}',
                                        style: TextStyle(
                                          fontFamily: kQuickSand,
                                          fontSize: 14*scaleFactor,
                                          color: kGreyColor,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: (){
                                          NetworkHandler.getInstance().launchInBrowser(tested[kSource]);
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
                    ),
                    SizedBox(height: 24*scaleFactor,),
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
                            Text(
                              lang.translate(kMainTableTitleLang),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: kNotoSansSc,
                                color: kGreyColor,
                                fontSize: 18*scaleFactor,
                              ),
                            ),
                            SizedBox(height: 5*scaleFactor,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    lang.translate(kMainTableNoteLang),
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontFamily: kNotoSansSc,
                                      color: kGreyColor,
                                      fontSize: 12*scaleFactor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SourcesListScreen(),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          AntDesign.infocirlceo,
                                          color: kGreyColor,
                                          size: 14*scaleFactor,
                                        ),
                                        SizedBox(width: 5*scaleFactor,),
                                        Text(
                                          lang.translate(kKnowMoreLang),
                                          style: TextStyle(
                                            color: kGreyColor,
                                            fontSize: 12*scaleFactor,
                                            fontFamily: kNotoSansSc,
                                          ),
                                        ),
                                        SizedBox(width: 5*scaleFactor,),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: kGreyColor,
                                          size: 14*scaleFactor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            TableHeader(
                              dataFor: lang.translate(kStateUTLang),
                              onTap: (){
                                setState(() {
                                  if(sortingOrder.checkOrder(SortingOrder.STATE_INC)){
                                    sortingOrder.setOrder(SortingOrder.STATE_DEC);
                                  }else if(sortingOrder.checkOrder(SortingOrder.STATE_DEC)){
                                    sortingOrder.setOrder(SortingOrder.STATE_INC);
                                  }else{
                                    sortingOrder.setOrder(SortingOrder.STATE_INC);
                                  }
                                });
                              },
                              onTapCnf: (){
                                setState(() {
                                  if(sortingOrder.checkOrder(SortingOrder.CNF_INC)){
                                    sortingOrder.setOrder(SortingOrder.CNF_DEC);
                                  }else if(sortingOrder.checkOrder(SortingOrder.CNF_DEC)){
                                    sortingOrder.setOrder(SortingOrder.CNF_INC);
                                  }else{
                                    sortingOrder.setOrder(SortingOrder.CNF_DEC);
                                  }
                                });
                              },
                              onTapAct: (){
                                setState(() {
                                  if(sortingOrder.checkOrder(SortingOrder.ACTV_INC)){
                                    sortingOrder.setOrder(SortingOrder.ACTV_DEC);
                                  }else if(sortingOrder.checkOrder(SortingOrder.ACTV_DEC)){
                                    sortingOrder.setOrder(SortingOrder.ACTV_INC);
                                  }else{
                                    sortingOrder.setOrder(SortingOrder.ACTV_DEC);
                                  }
                                });
                              },
                              onTapRec: (){
                                setState(() {
                                  if(sortingOrder.checkOrder(SortingOrder.REC_INC)){
                                    sortingOrder.setOrder(SortingOrder.REC_DEC);
                                  }else if(sortingOrder.checkOrder(SortingOrder.REC_DEC)){
                                    sortingOrder.setOrder(SortingOrder.REC_INC);
                                  }else{
                                    sortingOrder.setOrder(SortingOrder.REC_DEC);
                                  }
                                });
                              },
                              onTapDet: (){
                                setState(() {
                                  if(sortingOrder.checkOrder(SortingOrder.DET_INC)){
                                    sortingOrder.setOrder(SortingOrder.DET_DEC);
                                  }else if(sortingOrder.checkOrder(SortingOrder.DET_DEC)){
                                    sortingOrder.setOrder(SortingOrder.DET_INC);
                                  }else{
                                    sortingOrder.setOrder(SortingOrder.DET_DEC);
                                  }
                                });
                              },
                              sortingOrder: sortingOrder,
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: stateList.length,
                              itemBuilder: (BuildContext context,int index){

                                if(stateList[index].confirmed == 0){
                                  return SizedBox();
                                }

                                return TableRows(
                                  onTouchCallback: (){
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => StateData(stateInfo: stateList[index],),
                                      ),
                                    );
                                  },
                                  stateInfo: stateList[index],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}