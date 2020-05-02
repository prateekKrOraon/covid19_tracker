import 'package:covid19_tracker/utilities/helpers/network_handler.dart';

class StateWiseData{

  static Future _data;
  static NetworkHandler _networkHandler = NetworkHandler.getInstance();

  static Future getInstance(){
    if(_data == null){
      _data = _networkHandler.getData();
    }
    return _data;
  }

  static void refresh(){
    _data = _networkHandler.getData();
  }
}