import 'dart:async';

import 'package:covid19_tracker/utilities/network_handler.dart';

class RawData{

  static Future _data;

  static Future getInstance(){
    if(_data == null){
      NetworkHandler _networkHandler = NetworkHandler.getInstance();
      _data = _networkHandler.getRawData();
    }
    return _data;
  }

  static void refresh(){
    NetworkHandler networkHandler = NetworkHandler.getInstance();
    _data = networkHandler.getRawData();
  }

}