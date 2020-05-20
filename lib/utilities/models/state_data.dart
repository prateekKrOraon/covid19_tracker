import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:flutter/cupertino.dart';

class StateInfo{

  String stateName;
  String displayName;
  String stateCode;
  int active = 0;
  int confirmed = 0;
  int deltaCnf = 0;
  int recovered = 0;
  int deltaRec = 0;
  int deaths = 0;
  int deltaDet = 0;
  DateTime lastUpdated;
  String stateNotes;

  StateInfo.fromMap(BuildContext context,Map map){
    this.stateName = map[kState];
    this.displayName = AppLocalizations.of(context).translate(map[kState].toString().toLowerCase().replaceAll(" ", "_"));
    if(this.displayName == null){
      displayName = stateName;
    }
    this.stateCode = map[kStateCode];
    this.active = int.parse(map[kActive]);
    this.confirmed = int.parse(map[kConfirmed]);
    this.recovered = int.parse(map[kRecovered]);
    this.deaths = int.parse(map[kDeaths]);
    this.deltaCnf = int.parse(map[kDeltaConfirmed]);
    this.deltaRec = int.parse(map[kDeltaRecovered]);
    this.deltaDet = int.parse(map[kDeltaDeaths]);
    this.stateNotes = map[kStateNotes];
    this.lastUpdated = DateTime(
      int.parse(map[kLastUpdated].substring(6,10)),
      int.parse(map[kLastUpdated].substring(3,5)),
      int.parse(map[kLastUpdated].substring(0,2)),
      int.parse(map[kLastUpdated].substring(11,13)),
      int.parse(map[kLastUpdated].substring(14,16)),
      int.parse(map[kLastUpdated].substring(17,19)),
    );
  }

}