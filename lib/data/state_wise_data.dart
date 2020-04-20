import 'dart:async';

import 'package:covid19_tracker/utilities/network_handler.dart';
import 'package:async/async.dart';


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