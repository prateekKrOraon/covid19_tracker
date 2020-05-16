import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/models/country.dart';
import 'package:covid19_tracker/utilities/helpers/sorting.dart';
import 'package:covid19_tracker/utilities/models/state_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

double textScaleFactor = 1;

class DashboardTile extends StatelessWidget{

  final String mainTitle;
  final String value;
  final String delta;
  final Color color;

  DashboardTile({this.mainTitle,this.value,this.delta,this.color});



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if(size.width <= 360){
      textScaleFactor = 0.75;
    }

    return Expanded(
      child: Material(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        elevation: 2,
        color: Theme.of(context).backgroundColor,
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
                  mainTitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 14*textScaleFactor,
                    fontFamily: kQuickSand,
                  ),
                ),
                SizedBox(height: 16*textScaleFactor,),
                Row(
                  children: <Widget>[
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 24*textScaleFactor,
                        fontFamily: kQuickSand,
                      ),
                    ),
                    SizedBox(width: 10*textScaleFactor,),
                    Text(
                      delta == ""?"":"(+$delta)",
                      style: TextStyle(
                        color: color,
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
    );
  }
}



class TableHeader extends StatelessWidget{

  final String dataFor;
  final Function onTap;
  final Function onTapCnf;
  final Function onTapRec;
  final Function onTapAct;
  final Function onTapDet;
  final SortingOrder sortingOrder;

  TableHeader({
    this.dataFor,
    this.onTap,
    this.onTapCnf,
    this.onTapAct,
    this.onTapRec,
    this.onTapDet,
    this.sortingOrder,
  });

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context);
    ThemeData theme = Theme.of(context);
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(height: 16*textScaleFactor,),
          Container(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: Row(
                      mainAxisAlignment:MainAxisAlignment.start,
                      children: <Widget>[
                        sortingOrder.checkOrder(SortingOrder.STATE_INC) ||
                            sortingOrder.checkOrder(SortingOrder.STATE_DEC)?
                        Material(
                          borderRadius: BorderRadius.all(
                            Radius.circular(6),
                          ),
                          elevation: 1,
                          color: Theme.of(context).backgroundColor,
                          child: Container(
                            height: 12,
                            width: 12,
                            child: Center(
                              child: Icon(
                                sortingOrder.checkOrder(SortingOrder.STATE_DEC)?
                                AntDesign.arrowdown:
                                AntDesign.arrowup,
                                size: 8*textScaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 5*textScaleFactor,),
                        Text(
                          dataFor,
                          style: TextStyle(
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
                    onTap: onTapCnf,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        sortingOrder.checkOrder(SortingOrder.CNF_INC) ||
                            sortingOrder.checkOrder(SortingOrder.CNF_DEC)?
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
                                sortingOrder.checkOrder(SortingOrder.CNF_DEC)?
                                AntDesign.arrowdown:
                                AntDesign.arrowup,
                                size: 8*textScaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 5*textScaleFactor,),
                        Text(
                          lang.translate(kConfirmedLang),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: kRedColor,
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
                    onTap: onTapAct,
                    child: Row(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: <Widget>[
                        sortingOrder.checkOrder(SortingOrder.ACTV_INC) ||
                            sortingOrder.checkOrder(SortingOrder.ACTV_DEC)?
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
                                sortingOrder.checkOrder(SortingOrder.ACTV_DEC)?
                                AntDesign.arrowdown:
                                AntDesign.arrowup,
                                size: 8*textScaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 5*textScaleFactor,),
                        Text(
                          lang.translate(kActiveLang),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: kBlueColor,
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
                    onTap:onTapRec,
                    child: Row(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: <Widget>[
                        sortingOrder.checkOrder(SortingOrder.REC_INC) ||
                            sortingOrder.checkOrder(SortingOrder.REC_DEC)?
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
                                sortingOrder.checkOrder(SortingOrder.REC_DEC)?
                                AntDesign.arrowdown:
                                AntDesign.arrowup,
                                size: 8*textScaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 5*textScaleFactor,),
                        Text(
                          lang.translate(kRecoveredLang),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: kGreenColor,
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
                    onTap: onTapDet,
                    child: Row(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: <Widget>[
                        sortingOrder.checkOrder(SortingOrder.DET_INC) ||
                            sortingOrder.checkOrder(SortingOrder.DET_DEC)?
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
                                sortingOrder.checkOrder(SortingOrder.DET_DEC)?
                                AntDesign.arrowdown:
                                AntDesign.arrowup,
                                size: 8*textScaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 5*textScaleFactor,),
                        Text(
                          lang.translate(kDeathsLang),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.grey,
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
          SizedBox(height: 5*textScaleFactor,),
          Container(height: 1,color: kGreyColor,),
          SizedBox(height: 5*textScaleFactor,),
        ],
      ),
    );
  }
}

class TableRows extends StatelessWidget{

  final Function onTouchCallback;
  final StateInfo stateInfo;
  final Country country;


  TableRows({
    this.onTouchCallback,
    this.stateInfo,
    this.country,
  });

  bool countryData = false;

  @override
  Widget build(BuildContext context) {

    countryData = country != null;
    Size size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    return Column(
      children: <Widget>[
        SizedBox(height: 5*textScaleFactor,),
        InkWell(
          onTap: onTouchCallback,
          child: Container(
            width: size.width,
            constraints: BoxConstraints(
              minHeight: 32*textScaleFactor,
              maxHeight: 56*textScaleFactor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                          height: 12*textScaleFactor,
                          width: 12*textScaleFactor,
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 8*textScaleFactor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2*textScaleFactor,),
                      Expanded(
                        child: Text(
                          countryData?country.displayName==null?country.countryName:country.displayName:stateInfo.displayName==null?stateInfo.stateName:stateInfo.displayName,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        countryData?country.totalCases.toString():stateInfo.confirmed.toString(),
                        style: TextStyle(
                          fontFamily: kNotoSansSc,
                          fontSize: 14*textScaleFactor,
                        ),
                      ),
                      SizedBox(height: 2*textScaleFactor,),
                      Text(
                        countryData?country.todayCases==0?"":"(+${country.todayCases})":stateInfo.deltaCnf==0?"":"(+${stateInfo.deltaCnf})",
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: kNotoSansSc,
                          fontSize: 12*textScaleFactor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    countryData?country.active==0?"N/A":country.active.toString():stateInfo.active.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: kNotoSansSc,
                      fontSize: 14*textScaleFactor,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        countryData?country.recovered==0?"N/A":country.recovered.toString():stateInfo.recovered.toString(),
                        style: TextStyle(
                          fontFamily: kNotoSansSc,
                          fontSize: 14*textScaleFactor,
                        ),
                      ),
                      SizedBox(height: 2*textScaleFactor,),
                      Text(
                        countryData?"":stateInfo.deltaRec==0?"":"(+${stateInfo.deltaRec})",
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: kNotoSansSc,
                          fontSize: 12*textScaleFactor,
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
                        countryData?country.deaths.toString():stateInfo.deaths.toString(),
                        style: TextStyle(
                          fontFamily: kNotoSansSc,
                          fontSize: 14*textScaleFactor,
                        ),
                      ),
                      SizedBox(width: 2*textScaleFactor,),
                      Text(
                        countryData?"(+${country.todayDeaths})":stateInfo.deltaDet==0?"":"(+${stateInfo.deltaDet})",
                        style: TextStyle(
                          color: Colors.grey,
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
        ),
        SizedBox(height: 5*textScaleFactor,),
        Container(height: 1,color: theme.brightness == Brightness.light?kGreyColorLight:Colors.grey[800],),
      ],
    );
  }
}

class TableHeaderStatic extends StatelessWidget{

  final String dataFor;

  TableHeaderStatic(this.dataFor);

  @override
  Widget build(BuildContext context) {

    AppLocalizations lang = AppLocalizations.of(context);

    return Column(
      children: <Widget>[
        Container(
          child: Row(
            children: <Widget>[
              SizedBox(width: 8*textScaleFactor,),
              Expanded(
                child: Text(
                  dataFor,
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 14*textScaleFactor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  lang.translate(kConfirmedLang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kRedColor,
                    fontFamily: kQuickSand,
                    fontSize: 14*textScaleFactor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  lang.translate(kActiveLang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kBlueColor,
                    fontFamily: kQuickSand,
                    fontSize: 14*textScaleFactor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  lang.translate(kRecoveredLang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kGreenColor,
                    fontFamily: kQuickSand,
                    fontSize: 14*textScaleFactor,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  lang.translate(kDeathsLang),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: kQuickSand,
                    fontSize: 14*textScaleFactor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5*textScaleFactor,),
        Container(height: 1,color: kGreyColor,),
        SizedBox(height: 5*textScaleFactor,),
      ],
    );;
  }
}

