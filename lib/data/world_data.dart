import 'package:covid19_tracker/utilities/helpers/network_handler.dart';

class WorldData{

  static Future _data;
  static NetworkHandler _networkHandler = NetworkHandler.getInstance();

  static Future getInstance(){
    if(_data== null){

      _data = _networkHandler.getWorldData();
    }

    return _data;
  }

  static Future refresh(){
    _data = _networkHandler.getWorldData();
    return Future((){
      return null;
    });
  }

}