import 'package:covid19_tracker/constants/api_constants.dart';

class Source {
  String name;
  List<String> sources;

  Source.fromMap(Map map){
    this.name = map[kRegion];
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