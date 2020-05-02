import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:flutter/cupertino.dart';

class District{
  String name;
  int confirmed;
  int deltaCnf;
  int recovered;
  int deltaRec;
  int deaths;
  int deltaDet;
  int active;

  District(this.name, this.confirmed, this.deltaCnf);

  District.fromMap(BuildContext context, Map map){
    AppLocalizations lang = AppLocalizations.of(context);
    String distName = lang.translate(map[kDistrict].toString().toLowerCase().replaceAll(" ", "_"));
    this.name = distName==null?"${map[kDistrict]}":distName;
    this.confirmed = map[kConfirmed];
    this.deltaCnf = map[kDelta][kConfirmed];
    this.active = map[kActive];
    this.recovered = map[kRecovered];
    this.deltaRec = map[kDelta][kRecovered];
    this.deaths = map['deceased'];
    this.deltaDet = map[kDelta]['deceased'];
  }

}