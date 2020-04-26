import 'package:covid19_tracker/utilities/network_handler.dart';

class UpdateLog{

  static Future _data;
  static NetworkHandler _networkHandler = NetworkHandler.getInstance();

  static Future getInstance(String langCode){
    if(_data == null){
      _data = _networkHandler.getUpdateLogs(langCode);
    }
    return _data;
  }

  static void refresh(String langCode){
    _data = _networkHandler.getUpdateLogs(langCode);
  }

}