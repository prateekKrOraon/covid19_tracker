/*
*
* Dashboard for India only
*
*/

import 'dart:math';

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

class _DashboardIndiaState extends State<DashboardIndia> with SingleTickerProviderStateMixin{

  double scaleFactor = 1;
  SortingOrder sortingOrder;

  ThemeData theme;
  bool refresh = false;

  Future _data;
  DateTime _selectedDate = DateTime.now();
  DateTime _todayDate = DateTime.now();
  List<DateTime> _dateList;
  int _initialPage;
  PageController pageController;

  double _dateSelectorHeight = 0;
  Animation _dateSelectorAnimation;
  AnimationController _dateSelectorAnimationController;


  Map map;
  String lastUpdateStr;

  @override
  void initState() {
    sortingOrder = SortingOrder();
    _createDateList();
    _getData();
    _dateSelectorAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    )..addListener(() {
      setState(() {
        _dateSelectorHeight = _dateSelectorAnimationController.value*50;
      });
    });
    _dateSelectorAnimation = CurvedAnimation(
      parent: _dateSelectorAnimationController,
      curve: Curves.easeInOutBack,
    );
    super.initState();
  }

  _createDateList(){
    _dateList = List();
    DateTime currentDate = DateTime(2020,1,30,0,0,0,0,0);
    while(currentDate.millisecondsSinceEpoch < _todayDate.millisecondsSinceEpoch){
      _dateList.add(
        currentDate,
      );
      currentDate = DateTime(currentDate.year,currentDate.month,currentDate.day+1,0,0,0,0,0);
    }
    _initialPage = _dateList.length-1;
    pageController = PageController(
      initialPage: _initialPage,
      viewportFraction: 0.3,
      keepPage: true,
    );
  }

  _getData()async{
    _data = StateWiseData.getIndiaDashboard();
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
      future: _data,
      builder: (context,snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Column(
            children: [
              LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
              SizedBox(
                height: size.height*0.4,
              ),
              Text(
                lang.translate(kLoadingLang),
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
                  StateWiseData.refresh();
                  _getData();
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
                  _getData();
                });
              },
            ),
          );
        }



        if(_selectedDate.day == _todayDate.day &&
            _selectedDate.month == _todayDate.month &&
            _selectedDate.year == _todayDate.year){
          map = snapshot.data;
          lastUpdateStr = map[kStateWise][0][kLastUpdated].toString();
        }

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
        DateTime testedLastUpdate;
        if(dateStr != ""){
          testedLastUpdate = DateTime(
            int.parse(dateStr.substring(6,10)),
            int.parse(dateStr.substring(3,5)),
            int.parse(dateStr.substring(0,2)),
            int.parse(dateStr.substring(11,13)),
            int.parse(dateStr.substring(14,16)),
            int.parse(dateStr.substring(17,19)),
          );
        }

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
              _selectedDate = _todayDate;
              _data = null;
              StateWiseData.refresh();
              _getData();
            });
            return Future(()=>null);
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                refresh?LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: theme.primaryColor,
                ):SizedBox(height: 3,),
                Container(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8*scaleFactor,vertical: 8*scaleFactor),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: (){
                            if(_dateSelectorAnimationController.value == 1){
                              _dateSelectorAnimationController.reverse();
                            }else{
                              _dateSelectorAnimationController.forward();
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${lang.translate(kLastUpdatedAtLang)}: ${DateFormat("d MMM, ").add_jm().format(lastUpdate)} IST",
                                  style: TextStyle(
                                    color: theme.accentColor,
                                    fontSize: 16*scaleFactor,
                                    fontFamily: kQuickSand,
                                  ),
                                ),
                              ),
                              Transform.rotate(
                                angle: pi*_dateSelectorAnimationController.value*0.5,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12*scaleFactor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8*scaleFactor,),
                        Container(
                          height: _dateSelectorHeight,
                          width: size.width,
                          child: PageView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _dateList.length,
                            controller: pageController,
                            itemBuilder: (BuildContext context,int index){
                              Color color;
                              if(_dateList[index].day == _selectedDate.day &&
                                  _dateList[index].month == _selectedDate.month &&
                                  _dateList[index].year == _selectedDate.year
                              ){
                                color = theme.accentColor;
                              }else{
                                color = kGreyColor;
                              }
                              bool today = false;
                              if(_dateList[index].day == _todayDate.day &&
                                  _dateList[index].month == _todayDate.month &&
                                  _dateList[index].year == _todayDate.year){
                                today = true;
                              }
                              if(_dateSelectorHeight<25){
                                return SizedBox();
                              }
                              return InkWell(
                                onTap: (){
                                  setState(() {
                                    _selectedDate = _dateList[index];
                                    _initialPage = index;
                                    pageController.animateToPage(_initialPage, duration: Duration(milliseconds: 500), curve: Curves.easeOut);
                                    refresh = true;
                                  });
                                  if(today){
                                    setState(() {
                                      refresh = false;
                                    });
                                  }else{
                                    int year = _dateList[index].year;
                                    int month = _dateList[index].month;
                                    int day = _dateList[index].day;
                                    String date = "$year-${month<10?"0$month":month}-${day<10?"0$day":day}";
                                    StateWiseData.onDate = NetworkHandler.getInstance().getCasesOnDate(date)
                                    .then((value){
                                      setState(() {
                                        refresh = false;
                                        try{
                                          map = value;
                                          lastUpdateStr = map[kStateWise][0][kLastUpdated].toString();
                                        }catch(e){
                                          _selectedDate = _todayDate;
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              duration: Duration(seconds: 2),
                                              content: Text(
                                                lang.translate(kDataNotAvailableLang),
                                                style: TextStyle(
                                                  fontFamily: kQuickSand,
                                                  color: theme.brightness==Brightness.light?Colors.white:Colors.black,
                                                ),
                                              ),
                                              backgroundColor: theme.accentColor,
                                            ),
                                          );
                                        }
                                      });
                                    });
                                  }
                                },
                                child: Container(
                                  width: size.width/3,
                                  height: _dateSelectorHeight,
                                  child: Center(
                                    child: Text(
                                      today?lang.translate(kTodayLang):DateFormat("d MMM yyyy").format(_dateList[index]),
                                      style: TextStyle(
                                        fontFamily: kQuickSand,
                                        fontSize: 14*scaleFactor,
                                        color: color,
                                      ),
                                    )
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 8*scaleFactor,),
                        Container(
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
                                    color: kGreyColor,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10*scaleFactor,),
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
                                          tested[kTotalSamplesTested]==""?
                                            "N/A":
                                            NumberFormat(",##,###","hi_IN").format(double.parse(tested[kTotalSamplesTested].toString())):
                                          NumberFormat(",##,###","hi_IN").format(double.parse(tested[kTotalIndividualTested].toString())),
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
                                          '${lang.translate(kLastUpdatedAtLang)} ${testedLastUpdate==null?"--/--/----":testedLastUpdate.millisecondsSinceEpoch>DateTime.now().millisecondsSinceEpoch?"\t--\t":DateFormat("d MMM, ").add_jm().format(testedLastUpdate)}',
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
                        SizedBox(height: 10*scaleFactor,),
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
                                        if(_selectedDate.day == _todayDate.day &&
                                            _selectedDate.month == _todayDate.month &&
                                            _selectedDate.year == _todayDate.year){
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) => StateData(stateInfo: stateList[index],),
                                            ),
                                          );
                                        }else{
                                          Scaffold.of(context).showSnackBar(
                                            SnackBar(
                                              duration: Duration(seconds: 2),
                                              content: Text(
                                                lang.translate(kSnackBarInfoLang),
                                                style: TextStyle(
                                                  fontFamily: kQuickSand,
                                                  color: theme.brightness==Brightness.light?Colors.white:Colors.black,
                                                ),
                                              ),
                                              backgroundColor: theme.accentColor,
                                            ),
                                          );
                                        }
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
              ],
            ),
          ),
        );
      },
    );
  }
}