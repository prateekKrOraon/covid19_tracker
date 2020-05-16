import 'package:covid19_tracker/constants/api_constants.dart';

class GlobalTimeSeries{
  int confirmed;
  int deaths;
  int recovered;
  DateTime date;

  initialize(){
    if(confirmed == null){
      confirmed = 0;
    }
    if(deaths == null){
      deaths = 0;
    }
    if(recovered == null){
      recovered = 0;
    }
    if(date == null){
      date = DateTime.now();
    }
  }

  GlobalTimeSeries.fromMap(Map map,String key){
    try{
      this.confirmed = map[kConfirmed];
      this.deaths = map[kDeaths];
      this.recovered = map[kRecovered];
      this.date = DateTime(
          int.parse(key.substring(0,4)),
          int.parse(key.substring(5,7)),
          int.parse(key.substring(8))
      );
    }catch(e){
      print(e.toString());
      initialize();
    }
  }

}