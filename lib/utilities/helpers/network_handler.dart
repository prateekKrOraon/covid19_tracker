import 'dart:convert';
import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/data/state_wise_data.dart';
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

  Future getStateData(String stateCode)async{
    var res = await http.get("$BASE_API/india/state_data/$stateCode",);
    return jsonDecode(res.body);
  }

  Future getNationalTimeSeries()async{
    var res = await http.get("$BASE_API/india/time_series");
    return jsonDecode(res.body);
  }

  Future getIndiaDashboard()async{
    var res = await http.get("$BASE_API/india/state_wise");
    return jsonDecode(res.body);
  }

  Future getCasesOnDate(String date)async{
    var res = await http.get("$BASE_API/india/on_date/$date");
    if(res.statusCode != 200){
      return jsonDecode("{\"message\": \"Data Not Available\"}");
    }
    return jsonDecode(res.body);
  }

  // Deprecated
  Future getRawData()async{
    var res = await http.get(rawDataLink);
    return jsonDecode(res.body);
  }

  Future getSourceList()async{
    var res = await http.get("$BASE_API/sources");
    return jsonDecode(res.body);
  }
  
  Future getResourcesList()async{
    var res = await http.get('$BASE_API/resources');
    return jsonDecode(res.body);
  }

  Future getUpdateLogs(String langCode)async{
    var res = await http.get("$BASE_API/update_logs/$langCode");
    return jsonDecode(res.body);
  }

  Future getWorldData()async{
    //var res = await http.get(worldDataUrl);
    var res = await http.get("$BASE_API/global_data");
    return jsonDecode(res.body);
  }

  Future getCountryTimeSeries(String iso3)async{
    var res = await http.get("$BASE_API/country/${iso3.toUpperCase()}");
    return jsonDecode(res.body);
  }

  Future getGlobalTimeSeriesData()async{
    var res = await http.get("$BASE_API/global_time_series");
    return jsonDecode(res.body);
  }

  Future getFAQs(String langCode)async{
    var res = await http.get('$BASE_API/faqs/$langCode');
    return jsonDecode(res.body);
  }

  Future checkForUpdates(String version)async{
    Map<String,String> header = {"Content-Type":"application/json"};
    var res = await http.post("$BASE_API/check_for_updates",headers: header,body: jsonEncode({kVersion:version}));
    return jsonDecode(res.body);
  }

  Future getStatesDailyChanges()async{
    var res = await http.get("$BASE_API/india/states_time_series");
    return jsonDecode(res.body);
  }

  Future getCompareResult(String countryOne, String countryTwo)async{
    var res = await http.get("$BASE_API/compare?country_one=$countryOne&country_two=$countryTwo");
    return jsonDecode(res.body);
  }

}