import 'package:covid19_tracker/utilities/helpers/network_handler.dart';

class StatesDailyChanges{

  static Future _data;
  static NetworkHandler _networkHandler = NetworkHandler.getInstance();

  static Future getInstance(){
    if(_data == null){
      _data = _networkHandler.getStatesDailyChanges();
    }

    return _data;
  }

  static void refresh(){

  }

}