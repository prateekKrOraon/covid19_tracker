import 'package:covid19_tracker/constants/api_constants.dart';

class GlobalTimeSeries{
  int confirmed;
  int deaths;
  int recovered;
  DateTime date;

  GlobalTimeSeries.fromMap(Map map,String key){
    this.confirmed = map[kConfirmed];
    this.deaths = map[kDeaths];
    this.recovered = map[kRecovered];
    this.date = DateTime(
      int.parse(key.substring(0,4)),
      int.parse(key.substring(5,7)),
      int.parse(key.substring(8))
    );
  }

}