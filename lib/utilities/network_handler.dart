import 'dart:collection';
import 'dart:convert';
import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart' as browser;


class NetworkHandler{


  static NetworkHandler _instance;

  static NetworkHandler getInstance(){
    if(_instance == null){
      _instance = NetworkHandler();
    }

    return _instance;
  }

  Future<void> launchInBrowser(String url)async{
    if(await browser.canLaunch(url)){
      await browser.launch(
        url,
        forceWebView: false,
      );
    }else{
      throw 'Could not launch $url';
    }
  }

  Future getData()async{
    var res = await http.get(stateWiseLink);
    return jsonDecode(res.body);
  }

  Future getStateData(String name)async{
    var res = await http.get(districtWiseLink);
    List list = jsonDecode(res.body);
    Map state;
    for(int i=0;i<list.length;i++){
      Map map = list[i];
      if(map[kState].toString() == name){
        state = map;
      }else{
        map = HashMap();
      }
    }
    return state;
  }

  Future getRawData()async{
    var res = await http.get(rawDataLink);
    return jsonDecode(res.body);
  }

  Future getStatesDaily()async{
    var res = await http.get(stateWiseDailyLink);
    return jsonDecode(res.body);
  }

  Future getStateTestedDaily(String name)async{
    var res = await http.get(stateWiseTestLink);
    Map statesTestedData = jsonDecode(res.body);
    List list = statesTestedData[kStatesTestedData];
    Map stateData;
    for(int i = list.length;i<list.length; i++){
      Map map = list[i];
      if(map[kState] == name){
        stateData = map;
        break;
      }
    }
    return stateData;
  }

  Future getSourceList()async{
    var res = await http.get(sourcesLink);
    return jsonDecode(res.body);
  }
  
  Future getResourcesList()async{
    var res = await http.get(resourcesListLink);
    return jsonDecode(res.body);
  }

}