import 'package:covid19_tracker/utilities/network_handler.dart';

class UpdateLog{

  static Future _data;
  static NetworkHandler _networkHandler = NetworkHandler.getInstance();

  static Future getInstance(){
    if(_data == null){
      _data = _networkHandler.getUpdateLogs();
    }
    return _data;
  }

  static void refresh(){
    _data = _networkHandler.getUpdateLogs();
  }

}