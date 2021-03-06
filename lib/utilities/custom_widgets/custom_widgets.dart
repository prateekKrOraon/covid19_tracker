import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/models/country.dart';
import 'package:covid19_tracker/utilities/helpers/sorting.dart';
import 'package:covid19_tracker/utilities/models/state_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

double scaleFactor = 1;

class DashboardTile extends StatelessWidget{

  final String mainTitle;
  final String value;
  final String delta;
  final Color color;

  DashboardTile({this.mainTitle,this.value,this.delta,this.color});



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if(size.width<400){
      scaleFactor = 0.75;
    }else if(size.width<=450){
      scaleFactor = 0.8;
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
            color: Theme.of(context).brightness == Brightness.light?color.withOpacity(0.2):Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  mainTitle,
                  style: TextStyle(
                    color: color,
                    fontSize: 14*scaleFactor,
                    fontFamily: kQuickSand,
                  ),
                ),
                SizedBox(height: 16*scaleFactor,),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        value == ""?"0":NumberFormat(",##,###","hi_IN").format(double.parse(value)),
                        style: TextStyle(
                          color: color,
                          fontSize: 24*scaleFactor,
                          fontFamily: kQuickSand,
                        ),
                      ),
                    ),
                    SizedBox(width: 10*scaleFactor,),
                    Text(
                      delta == ""?"":"(+${NumberFormat(",##,###","hi_IN").format(int.parse(delta))})",
                      style: TextStyle(
                        color: color,
                        fontSize: 16*scaleFactor,
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
          SizedBox(height: 16*scaleFactor,),
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
                                size: 8*scaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 4*scaleFactor,),
                        Text(
                          dataFor,
                          style: TextStyle(
                            fontFamily: kQuickSand,
                            fontSize: 14*scaleFactor,
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
                                size: 8*scaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 4*scaleFactor,),
                        Text(
                          lang.translate(kConfirmedLang),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: kRedColor,
                            fontFamily: kQuickSand,
                            fontSize: 14*scaleFactor,
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
                                size: 8*scaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 4*scaleFactor,),
                        Text(
                          lang.translate(kActiveLang),
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: kBlueColor,
                            fontFamily: kQuickSand,
                            fontSize: 14*scaleFactor,
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
                                size: 8*scaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 4*scaleFactor,),
                        Text(
                          lang.translate(kRecoveredLang),
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: kGreenColor,
                            fontFamily: kQuickSand,
                            fontSize: 14*scaleFactor,
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
                                size: 8*scaleFactor,
                              ),
                            ),
                          ),
                        ):SizedBox(),
                        SizedBox(width: 4*scaleFactor,),
                        Text(
                          lang.translate(kDeathsLang),
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: kQuickSand,
                            fontSize: 14*scaleFactor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5*scaleFactor,),
          Container(height: 1,color: kGreyColor,),
          SizedBox(height: 5*scaleFactor,),
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
        SizedBox(height: 5*scaleFactor,),
        InkWell(
          onTap: onTouchCallback,
          child: Container(
            width: size.width,
            constraints: BoxConstraints(
              minHeight: 32*scaleFactor,
              maxHeight: 56*scaleFactor,
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
                          height: 12*scaleFactor,
                          width: 12*scaleFactor,
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 8*scaleFactor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2*scaleFactor,),
                      Expanded(
                        child: Text(
                          countryData?
                          AppLocalizations.of(context).locale.languageCode=="en"?
                            country.countryName:
                            country.countryNameHI:
                          AppLocalizations.of(context).locale.languageCode=="en"?
                            stateInfo.stateName:
                            stateInfo.stateNameHI,
                          style: TextStyle(
                            fontFamily: kNotoSansSc,
                            fontSize: 12*scaleFactor,
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
                          fontSize: 14*scaleFactor,
                        ),
                      ),
                      SizedBox(height: 2*scaleFactor,),
                      Text(
                        countryData?country.todayCases==0?"":"(+${country.todayCases})":stateInfo.deltaCnf==0?"":"(${stateInfo.deltaCnf<0?"":"+"}${stateInfo.deltaCnf})",
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: kNotoSansSc,
                          fontSize: 12*scaleFactor,
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
                      fontSize: 14*scaleFactor,
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
                          fontSize: 14*scaleFactor,
                        ),
                      ),
                      SizedBox(height: 2*scaleFactor,),
                      Text(
                        countryData?"":stateInfo.deltaRec==0?"":"(${stateInfo.deltaRec<0?"":"+"}${stateInfo.deltaRec})",
                        style: TextStyle(
                          color: Colors.green,
                          fontFamily: kNotoSansSc,
                          fontSize: 12*scaleFactor,
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
                          fontSize: 14*scaleFactor,
                        ),
                      ),
                      SizedBox(width: 2*scaleFactor,),
                      Text(
                        countryData?"(+${country.todayDeaths})":stateInfo.deltaDet==0?"":"(${stateInfo.deltaDet<0?"":"+"}${stateInfo.deltaDet})",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: kNotoSansSc,
                          fontSize: 12*scaleFactor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 5*scaleFactor,),
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
              SizedBox(width: 8*scaleFactor,),
              Expanded(
                child: Text(
                  dataFor,
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 14*scaleFactor,
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
                    fontSize: 14*scaleFactor,
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
                    fontSize: 14*scaleFactor,
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
                    fontSize: 14*scaleFactor,
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
                    fontSize: 14*scaleFactor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 5*scaleFactor,),
        Container(height: 1,color: kGreyColor,),
        SizedBox(height: 5*scaleFactor,),
      ],
    );
  }
}

