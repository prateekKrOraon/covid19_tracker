import 'dart:collection';
import 'dart:convert';
import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
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

  Future getUpdateLogs(String langCode)async{
    Map<String,String> header = {"Accept":"application/json"};
    var res = await http.post(updateLogLink,headers: header,body: {kLangCode:langCode});
    return jsonDecode(res.body);
  }

  Future getCountryWiseData()async{
    var res = await http.get(countryWiseDataUrl);
    return jsonDecode(res.body);
  }

  Future getWorldData()async{
    var res = await http.get(worldDataUrl);
    return jsonDecode(res.body);
  }

  Future getCountryTimeSeries(String iso3)async{
    var res = await http.get("$countryDataUrl$iso3");
    return jsonDecode(res.body);
  }

  Future getCountryData(String iso3)async{
    var res = await http.get("$countryDataUrl2$iso3");
    return jsonDecode(res.body);
  }

  Future getGlobalTimeSeriesData()async{
    var res = await http.get(globalTimeSeriesLink);
    return jsonDecode(res.body);
  }

  Future getFAQs(String langCode)async{
    Map<String,String> header = {"Accept":"application/json"};
    var res = await http.post(faqsLink,headers: header,body: {kLangCode:langCode});
    return jsonDecode(res.body);
  }

  Future checkForUpdates(String version)async{
    Map<String,String> header = {"Accept":"application/json"};
    var res = await http.post(checkForUpdateLink,headers: header,body: {kVersion:version});
    return jsonDecode(res.body);
  }

  Future getZonesData(String stateCode)async{
    Map<String,String> header = {"Accept":"application/json"};
    var res = await http.post(zonesDataLink,headers: header,body: {'state_code':stateCode});
    return jsonDecode(res.body);
  }

  Future getStatesDailyChanges()async{
    var res = await http.get(statesDailyChangesLink);
    return jsonDecode(res.body);
  }

}