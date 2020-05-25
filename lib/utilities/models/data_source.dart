import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:flutter/cupertino.dart';

class Source {
  String name;
  List<String> sources;

  Source.fromMap(BuildContext context,Map map){
    this.name = AppLocalizations.of(context).translate(map[kRegion].toString().toLowerCase().replaceAll(" ", "_"));
    sources = List();
    if(map[kSource1] != ""){
      sources.add(map[kSource1]);
    }

    if(map[kSource2] != ""){
      sources.add(map[kSource2]);
    }

    if(map[kSource3] != ""){
      sources.add(map[kSource3]);
    }

    if(map[kSource4] != ""){
      sources.add(map[kSource4]);
    }

    if(map[kSource5] != ""){
      sources.add(map[kSource5]);
    }

    if(map[kSource6] != ""){
      sources.add(map[kSource6]);
    }
  }
}