import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class District{
  String districtNameHI;
  String districtName;
  int confirmed;
  int deltaCnf;
  int recovered;
  int deltaRec;
  int deaths;
  int deltaDet;
  int active;
  //Color zone;



  District.fromMap(BuildContext context, Map map){
    this.districtNameHI = map['district_hi'];
    this.districtName = map[kDistrict];
    this.confirmed = map[kConfirmed];
    this.deltaCnf = map[kDelta][kConfirmed];
    this.active = map[kActive];
    this.recovered = map[kRecovered];
    this.deltaRec = map[kDelta][kRecovered];
    this.deaths = map['deceased'];
    this.deltaDet = map[kDelta]['deceased'];

//    String key = districtName.toLowerCase().replaceAll(" ", "_");
//    if(zones[key].toString().toUpperCase() == "GREEN"){
//      this.zone = Colors.green;
//    }else if(zones[key].toString().toUpperCase() ==  "ORANGE"){
//      this.zone = Colors.orange;
//    }else if(zones[key].toString().toUpperCase() == "RED"){
//      this.zone = Colors.red;
//    }else{
//      this.zone = kGreyColor;
//    }
  }

}