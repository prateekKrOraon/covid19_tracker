import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/data/raw_data.dart';
import 'package:covid19_tracker/screens/sources_list.dart';
import 'package:covid19_tracker/screens/state_data_screen.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/utilities/network_handler.dart';
import 'package:covid19_tracker/data/state_wise_data.dart';
import 'package:covid19_tracker/utilities/sorting.dart';
import 'package:covid19_tracker/utilities/state_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget{
  @override
  _DashboardState createState() {
    return _DashboardState();
  }
}

class _DashboardState extends State<Dashboard>{

  double textScaleFactor = 1;

  ThemeData theme;
  bool refresh = false;


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    if(size.width<=360.0){
      textScaleFactor = 0.75;
    }
    return FutureBuilder(
      future: StateWiseData.getInstance(),
      builder: (context,snapshot){
        if(snapshot.hasError){
          return SizedBox(height: 10.0,);
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(child: CircularProgressIndicator(),);
        }
        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
        }
        if(snapshot.hasError){
          return Center(
            child: Text(
              "Some Error Occurred",
              style: TextStyle(
                fontFamily: kNotoSansSc,
                fontSize: 20*textScaleFactor,
              ),
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

         List tested = map[kTested];
         Map latestTestedData = tested[tested.length-1];
         String dateStr = latestTestedData[kUpdateTimeStamp];
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
             StateInfo.fromMap(state),
           );
         }

         if(SortingOrder.checkOrder(SortingOrder.CNF_DEC)){
           stateList.sort((a,b) => b.confirmed.compareTo(a.confirmed));
         }else if(SortingOrder.checkOrder(SortingOrder.CNF_INC)){
           stateList.sort((a,b) => a.confirmed.compareTo(b.confirmed));
         }else if (SortingOrder.checkOrder(SortingOrder.STATE_DEC)){
           stateList.sort((a,b) => b.stateName.compareTo(a.stateName));
         }else if (SortingOrder.checkOrder(SortingOrder.STATE_INC)){
           stateList.sort((a,b) => a.stateName.compareTo(b.stateName));
         }else if (SortingOrder.checkOrder(SortingOrder.ACTV_DEC)){
           stateList.sort((a,b) => b.active.compareTo(a.active));
         }else if (SortingOrder.checkOrder(SortingOrder.ACTV_INC)){
           stateList.sort((a,b) => a.active.compareTo(b.active));
         }else if (SortingOrder.checkOrder(SortingOrder.REC_DEC)){
           stateList.sort((a,b) => b.recovered.compareTo(a.recovered));
         }else if (SortingOrder.checkOrder(SortingOrder.REC_INC)){
           stateList.sort((a,b) => a.recovered.compareTo(b.recovered));
         }else if (SortingOrder.checkOrder(SortingOrder.DET_DEC)){
           stateList.sort((a,b) => b.deaths.compareTo(a.deaths));
         }else if (SortingOrder.checkOrder(SortingOrder.DET_INC)){
           stateList.sort((a,b) => a.deaths.compareTo(b.deaths));
         }



        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                "COVID-19 TRACKER, INDIA",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30*textScaleFactor,
                                  fontFamily: kQuickSand,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10,),
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    print("starting refresh");
                                    RawData.refresh();
                                    StateWiseData.refresh();
                                    print("pressed");
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
                            ),
                          ],
                        ),
                        Text(
                          "Powered by api.covid19india.org",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kGreyColor,
                            fontFamily: kQuickSand,
                          ),
                        ),
                        SizedBox(height: 8,),
                        Text(
                          "Last updated at: ${DateFormat("d MMM, ").add_jm().format(lastUpdate)} IST",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kGreenColor,
                            fontSize: 16*textScaleFactor,
                            fontFamily: kQuickSand,
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
                            Expanded(
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Text(
                                          'TOTAL CONFIRMED CASES',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kRedColor,
                                            fontSize: 12*textScaleFactor,
                                            fontFamily: kQuickSand,
                                          ),
                                        ),
                                        SizedBox(height: 16,),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              map[kStateWise][0][kConfirmed],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: kRedColor,
                                                fontSize: 24*textScaleFactor,
                                                fontFamily: kQuickSand,
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Text(
                                              "(+${map[kStateWise][0][kDeltaConfirmed]})",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: kRedColor,
                                                fontSize: 16*textScaleFactor,
                                                fontFamily: kQuickSand,
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
                            SizedBox(width: 10,),
                            Expanded(
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
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Text(
                                          'TOTAL ACTIVE CASES',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kBlueColor,
                                            fontSize: 12*textScaleFactor,
                                            fontFamily: kQuickSand,
                                          ),
                                        ),
                                        SizedBox(height: 16,),
                                        Text(
                                          map[kStateWise][0][kActive],
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: kBlueColor,
                                              fontSize: 24*textScaleFactor,
                                            fontFamily: kQuickSand,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Expanded(
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Text(
                                          'TOTAL RECOVERED',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: kGreenColor,
                                            fontSize: 12*textScaleFactor,
                                            fontFamily: kQuickSand,
                                          ),
                                        ),
                                        SizedBox(height: 16,),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              map[kStateWise][0][kRecovered],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: kGreenColor,
                                                fontSize: 24*textScaleFactor,
                                                fontFamily: kQuickSand,
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Text(
                                              "(+${map[kStateWise][0][kDeltaRecovered]})",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: kGreenColor,
                                                fontSize: 16*textScaleFactor,
                                                fontFamily: kQuickSand,
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
                            SizedBox(width: 10,),
                            Expanded(
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
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Text(
                                          'TOTAL DEATHS',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                            fontSize: 12*textScaleFactor,
                                            fontFamily: kQuickSand,
                                          ),
                                        ),
                                        SizedBox(height: 16,),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              map[kStateWise][0][kDeaths],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 24*textScaleFactor,
                                                fontFamily: kQuickSand,
                                              ),
                                            ),
                                            SizedBox(width: 10,),
                                            Text(
                                              "(+${map[kStateWise][0][kDeltaDeaths]})",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 16*textScaleFactor,
                                                fontFamily: kQuickSand,
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
                          ],
                        )
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
                                      'TOTAL TESTED',
                                      style: TextStyle(
                                        fontFamily: kQuickSand,
                                        fontSize: 24*textScaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color: kDarkBlueColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      latestTestedData[kTotalIndividualTested],
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kDarkBlueColor,
                                        fontSize: 24*textScaleFactor,
                                        fontFamily: kQuickSand,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      'Last Updated at ${DateFormat("d MMM, ").add_jm().format(testedLastUpdate)}',
                                      style: TextStyle(
                                        fontFamily: kQuickSand,
                                        fontSize: 14*textScaleFactor,
                                        fontWeight: FontWeight.bold,
                                        color: kGreenColor,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: InkWell(
                                      onTap: (){
                                        NetworkHandler.getInstance().launchInBrowser(latestTestedData[kSource]);
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            "Source",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: kGreyColor,
                                              fontSize: 12*textScaleFactor,
                                              fontFamily: kNotoSansSc,
                                            ),
                                          ),
                                          SizedBox(width: 5,),
                                          Icon(
                                            Icons.launch,
                                            color: kGreyColor,
                                            size: 12*textScaleFactor,
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
                  SizedBox(height: 24,),
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
                            "STATE WISE DATA",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: kNotoSansSc,
                              color: kGreyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16*textScaleFactor,
                            ),
                          ),
                          SizedBox(height: 5,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "COMPILED FROM STATE GOVT. NUMBERS AND VERIFIED SOURCES",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: kNotoSansSc,
                                    color: kGreyColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12*textScaleFactor,
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
                                        size: 14*textScaleFactor,
                                      ),
                                      SizedBox(width: 5,),
                                      Text(
                                        "Know more",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: kGreyColor,
                                          fontSize: 12*textScaleFactor,
                                          fontFamily: kNotoSansSc,
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: kGreyColor,
                                        size: 14*textScaleFactor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16,),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: stateList.length+1,
                            itemBuilder: (BuildContext context,int index){
                              if(index == 0){
                                return Column(
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: InkWell(
                                              onTap:(){
                                                setState(() {
                                                  if(SortingOrder.checkOrder(SortingOrder.STATE_INC)){
                                                    SortingOrder.setOrder(SortingOrder.STATE_DEC);
                                                  }else if(SortingOrder.checkOrder(SortingOrder.STATE_DEC)){
                                                  SortingOrder.setOrder(SortingOrder.STATE_INC);
                                                  }else{
                                                    SortingOrder.setOrder(SortingOrder.STATE_INC);
                                                  }
                                                });
                                              },
                                              child: Row(
                                                children: <Widget>[
                                                  SortingOrder.checkOrder(SortingOrder.STATE_INC) ||
                                                      SortingOrder.checkOrder(SortingOrder.STATE_DEC)?
                                                  Material(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(6),
                                                    ),
                                                    elevation: 1,
                                                    color: theme.backgroundColor,
                                                    child: Container(
                                                      height: 12,
                                                      width: 12,
                                                      child: Center(
                                                        child: Icon(
                                                          SortingOrder.checkOrder(SortingOrder.STATE_DEC)?
                                                          AntDesign.arrowdown:
                                                          AntDesign.arrowup,
                                                          size: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  ):SizedBox(),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    "State/UT",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: kQuickSand,
                                                      fontSize: 14*textScaleFactor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap:(){
                                                setState(() {
                                                  if(SortingOrder.checkOrder(SortingOrder.CNF_INC)){
                                                    SortingOrder.setOrder(SortingOrder.CNF_DEC);
                                                  }else if(SortingOrder.checkOrder(SortingOrder.CNF_DEC)){
                                                    SortingOrder.setOrder(SortingOrder.CNF_INC);
                                                  }else{
                                                    SortingOrder.setOrder(SortingOrder.CNF_DEC);
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: <Widget>[
                                                  SortingOrder.checkOrder(SortingOrder.CNF_INC) ||
                                                      SortingOrder.checkOrder(SortingOrder.CNF_DEC)?
                                                  Material(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(6),
                                                    ),
                                                    elevation: 1,
                                                    color: theme.backgroundColor,
                                                    child: Container(
                                                      height: 12,
                                                      width: 12,
                                                      child: Center(
                                                        child: Icon(
                                                          SortingOrder.checkOrder(SortingOrder.CNF_DEC)?
                                                          AntDesign.arrowdown:
                                                          AntDesign.arrowup,
                                                          size: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  ):SizedBox(),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    "Confirmed",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: kRedColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: kQuickSand,
                                                      fontSize: 14*textScaleFactor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap:(){
                                                setState(() {
                                                  if(SortingOrder.checkOrder(SortingOrder.ACTV_INC)){
                                                    SortingOrder.setOrder(SortingOrder.ACTV_DEC);
                                                  }else if(SortingOrder.checkOrder(SortingOrder.ACTV_DEC)){
                                                    SortingOrder.setOrder(SortingOrder.ACTV_INC);
                                                  }else{
                                                    SortingOrder.setOrder(SortingOrder.ACTV_DEC);
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:MainAxisAlignment.end,
                                                children: <Widget>[
                                                  SortingOrder.checkOrder(SortingOrder.ACTV_INC) ||
                                                      SortingOrder.checkOrder(SortingOrder.ACTV_DEC)?
                                                  Material(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(6),
                                                    ),
                                                    elevation: 1,
                                                    color: theme.backgroundColor,
                                                    child: Container(
                                                      height: 12,
                                                      width: 12,
                                                      child: Center(
                                                        child: Icon(
                                                          SortingOrder.checkOrder(SortingOrder.ACTV_DEC)?
                                                          AntDesign.arrowdown:
                                                          AntDesign.arrowup,
                                                          size: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  ):SizedBox(),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    "Active",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: kBlueColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: kQuickSand,
                                                      fontSize: 14*textScaleFactor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap:(){
                                                setState(() {
                                                  if(SortingOrder.checkOrder(SortingOrder.REC_INC)){
                                                    SortingOrder.setOrder(SortingOrder.REC_DEC);
                                                  }else if(SortingOrder.checkOrder(SortingOrder.REC_DEC)){
                                                    SortingOrder.setOrder(SortingOrder.REC_INC);
                                                  }else{
                                                    SortingOrder.setOrder(SortingOrder.REC_DEC);
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:MainAxisAlignment.end,
                                                children: <Widget>[
                                                  SortingOrder.checkOrder(SortingOrder.REC_INC) ||
                                                      SortingOrder.checkOrder(SortingOrder.REC_DEC)?
                                                  Material(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(6),
                                                    ),
                                                    elevation: 1,
                                                    color: theme.backgroundColor,
                                                    child: Container(
                                                      height: 12,
                                                      width: 12,
                                                      child: Center(
                                                        child: Icon(
                                                          SortingOrder.checkOrder(SortingOrder.REC_DEC)?
                                                          AntDesign.arrowdown:
                                                          AntDesign.arrowup,
                                                          size: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  ):SizedBox(),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    "Recovered",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: kGreenColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: kQuickSand,
                                                      fontSize: 14*textScaleFactor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: InkWell(
                                              onTap:(){
                                                setState(() {
                                                  if(SortingOrder.checkOrder(SortingOrder.DET_INC)){
                                                    SortingOrder.setOrder(SortingOrder.DET_DEC);
                                                  }else if(SortingOrder.checkOrder(SortingOrder.DET_DEC)){
                                                    SortingOrder.setOrder(SortingOrder.DET_INC);
                                                  }else{
                                                    SortingOrder.setOrder(SortingOrder.DET_DEC);
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:MainAxisAlignment.end,
                                                children: <Widget>[
                                                  SortingOrder.checkOrder(SortingOrder.DET_INC) ||
                                                      SortingOrder.checkOrder(SortingOrder.DET_DEC)?
                                                  Material(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(6),
                                                    ),
                                                    elevation: 1,
                                                    color: theme.backgroundColor,
                                                    child: Container(
                                                      height: 12,
                                                      width: 12,
                                                      child: Center(
                                                        child: Icon(
                                                          SortingOrder.checkOrder(SortingOrder.DET_DEC)?
                                                          AntDesign.arrowdown:
                                                          AntDesign.arrowup,
                                                          size: 8,
                                                        ),
                                                      ),
                                                    ),
                                                  ):SizedBox(),
                                                  SizedBox(width: 5,),
                                                  Text(
                                                    "Deaths",
                                                    textAlign: TextAlign.end,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: kQuickSand,
                                                      fontSize: 14*textScaleFactor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    Container(height: 1,color: kGreyColor,),
                                    SizedBox(height: 5,),
                                  ],
                                );
                              }

                              if(stateList[index-1].confirmed == 0){
                                return SizedBox();
                              }

                              return InkWell(
                                onTap: (){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => StateData(
                                        name: stateList[index-1].stateName,
                                        stateCode: stateList[index-1].stateCode,
                                        confirmed: stateList[index-1].confirmed.toString(),
                                        recovered: stateList[index-1].recovered.toString(),
                                        active: stateList[index-1].active.toString(),
                                        deaths: stateList[index-1].deaths.toString(),
                                        deltaCnf: stateList[index-1].deltaCnf.toString(),
                                        deltaRec: stateList[index-1].deltaRec.toString(),
                                        deltaDet: stateList[index-1].deltaDet.toString(),
                                        lastUpdated: stateList[index-1].lastUpdated,
                                        stateNotes: stateList[index-1].stateNotes,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      width: size.width,
                                      constraints: BoxConstraints(
                                        minHeight: 32,
                                        maxHeight: 56,
                                      ),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Row(
                                              crossAxisAlignment:CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Material(
                                                  borderRadius: BorderRadius.all(
                                                    Radius.circular(6),
                                                  ),
                                                  elevation: 1,
                                                  color: theme.backgroundColor,
                                                  child: Container(
                                                    height: 12,
                                                    width: 12,
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 8,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Expanded(
                                                  child: Text(
                                                    stateList[index-1].stateName,
                                                    style: TextStyle(
                                                      fontFamily: kNotoSansSc,
                                                      fontSize: 12*textScaleFactor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  stateList[index-1].deltaCnf==0?"":"(+${stateList[index-1].deltaCnf})",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontFamily: kNotoSansSc,
                                                    fontSize: 12*textScaleFactor,
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Text(
                                                  stateList[index-1].confirmed.toString(),
                                                  style: TextStyle(
                                                    fontFamily: kNotoSansSc,
                                                    fontSize: 12*textScaleFactor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              stateList[index-1].active.toString(),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                fontFamily: kNotoSansSc,
                                                fontSize: 12*textScaleFactor,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  stateList[index-1].deltaRec==0?"":"(+${stateList[index-1].deltaRec})",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                    fontFamily: kNotoSansSc,
                                                    fontSize: 12*textScaleFactor,
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Text(
                                                  stateList[index-1].recovered.toString(),
                                                  style: TextStyle(
                                                    fontFamily: kNotoSansSc,
                                                    fontSize: 12*textScaleFactor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  stateList[index-1].deltaDet==0?"":"(+${stateList[index-1].deltaDet})",
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontFamily: kNotoSansSc,
                                                    fontSize: 12*textScaleFactor,
                                                  ),
                                                ),
                                                SizedBox(width: 5,),
                                                Text(
                                                  stateList[index-1].deaths.toString(),
                                                  style: TextStyle(
                                                    fontFamily: kNotoSansSc,
                                                    fontSize: 12*textScaleFactor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5,),
                                    Container(height: 1,color: theme.brightness == Brightness.light?kGreyColorLight:Colors.grey[800],),
                                    SizedBox(height: 5,),
                                  ],
                                ),
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
        );
      },
    );
  }

}