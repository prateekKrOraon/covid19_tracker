/*
*
* Saves country wise data
* instance provided to global dashboard
*
*/


import 'package:covid19_tracker/utilities/helpers/network_handler.dart';

class CountryWiseData{

  static Future _data;
  static NetworkHandler _networkHandler = NetworkHandler.getInstance();

  static Future getInstance(){
    if(_data== null){

      _data = _networkHandler.getCountryWiseData();
    }

    return _data;
  }

  static Future refresh(){
    _data = _networkHandler.getCountryWiseData();
    return Future((){
      return null;
    });
  }

}