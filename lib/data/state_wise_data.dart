import 'package:covid19_tracker/utilities/helpers/network_handler.dart';

class StateWiseData{

  static Future _data;
  static Future _dashboard;
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

  static void refresh(){
    _data = _networkHandler.getNationalTimeSeries();
    _dashboard = _networkHandler.getIndiaDashboard();
  }
}