import 'package:covid19_tracker/utilities/helpers/network_handler.dart';

class ZonesData{

  static Future _data;
  static NetworkHandler _networkHandler = NetworkHandler.getInstance();

//  static Future getInstance(){
//    if(_data == null){
//      _data = _networkHandler.getZonesData();
//    }
//
//    return _data;
//  }
//
//  static void refresh(){
//    _data = _networkHandler.getZonesData();
//  }

}