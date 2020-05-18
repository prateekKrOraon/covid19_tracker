/*
*
* Complete list of countries
*
*/

import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/models/country.dart';
import 'package:covid19_tracker/utilities/custom_widgets/custom_widgets.dart';
import 'package:covid19_tracker/utilities/helpers/sorting.dart';
import 'package:flutter/material.dart';

import 'country_data_screen.dart';

class FullGlobalList extends StatefulWidget{
  final List<Country> countries;


  FullGlobalList(this.countries);

  @override
  _FullGlobalList createState() {
    return _FullGlobalList(this.countries);
  }
}

class _FullGlobalList extends State<FullGlobalList>{

  final List<Country> countries;

  double scaleFactor = 1;
  _FullGlobalList(this.countries);

  SortingOrder sortingOrder;

  @override
  void initState() {
    sortingOrder = SortingOrder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;

    AppLocalizations lang = AppLocalizations.of(context);

    if(size.width<400){
      scaleFactor = 0.75;
    }else if(size.width<=450){
      scaleFactor = 0.9;
    }

    if(sortingOrder.checkOrder(SortingOrder.CNF_DEC)){
      countries.sort((a,b) => b.totalCases.compareTo(a.totalCases));
    }else if(sortingOrder.checkOrder(SortingOrder.CNF_INC)){
      countries.sort((a,b) => a.totalCases.compareTo(b.totalCases));
    }else if (sortingOrder.checkOrder(SortingOrder.STATE_DEC)){
      countries.sort((a,b) => b.countryName.compareTo(a.countryName));
    }else if (sortingOrder.checkOrder(SortingOrder.STATE_INC)){
      countries.sort((a,b) => a.countryName.compareTo(b.countryName));
    }else if (sortingOrder.checkOrder(SortingOrder.ACTV_DEC)){
      countries.sort((a,b) => b.active.compareTo(a.active));
    }else if (sortingOrder.checkOrder(SortingOrder.ACTV_INC)){
      countries.sort((a,b) => a.active.compareTo(b.active));
    }else if (sortingOrder.checkOrder(SortingOrder.REC_DEC)){
      countries.sort((a,b) => b.recovered.compareTo(a.recovered));
    }else if (sortingOrder.checkOrder(SortingOrder.REC_INC)){
      countries.sort((a,b) => a.recovered.compareTo(b.recovered));
    }else if (sortingOrder.checkOrder(SortingOrder.DET_DEC)){
      countries.sort((a,b) => b.deaths.compareTo(a.deaths));
    }else if (sortingOrder.checkOrder(SortingOrder.DET_INC)){
      countries.sort((a,b) => a.deaths.compareTo(b.deaths));
    }

    return Scaffold(
      body: SafeArea(
        child: Material(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          elevation: 2,
          color: theme.backgroundColor,
          child: Container(
            height: size.height,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  height: size.height*0.085,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        lang.translate(kCountryWiseDataLang),
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: kNotoSansSc,
                          color: kGreyColor,
                          fontSize: 18*scaleFactor,
                        ),
                      ),
                      TableHeader(
                        dataFor: lang.translate(kCountryLang),
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
                    ],
                  ),
                ),
                Container(
                  height: size.height*0.855,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: countries.length,
                    itemBuilder: (BuildContext context,int index){

                      if(countries[index].totalCases == 0){
                        return SizedBox();
                      }

                      return TableRows(
                        onTouchCallback: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => CountryDataScreen(countries[index]),
                            ),
                          );
                        },
                        country: countries[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}