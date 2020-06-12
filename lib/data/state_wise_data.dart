import 'package:covid19_tracker/utilities/helpers/network_handler.dart';

class StateWiseData{

  static Future _data;
  static Future _dashboard;
  static Future onDate;
  static NetworkHandler _networkHandler = NetworkHandler.getInstance();

  static Future getIndiaTimeSeries(){
    if(_data == null){
      _data = _networkHandler.getNationalTimeSeries();
    }
    return _data;
  }

  static Future getIndiaDashboard()async{
    if(_dashboard == null){
      _dashboard = _networkHandler.getIndiaDashboard();
    }
    return _dashboard;
  }

  static Future refresh()async{
    _data = _networkHandler.getNationalTimeSeries();
    _dashboard = _networkHandler.getIndiaDashboard();
  }
}