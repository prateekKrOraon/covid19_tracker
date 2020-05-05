import 'dart:collection';
import 'dart:math';
import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:intl/intl.dart';

class MathFunctions{

  List<double> confirmedTimeSeries;
  List<double> infectedTimeSeries;
  List<double> recoveredTimeSeries;
  List<double> deathsTimeSeries;
  List<DateTime> dateTimeSeries;

  void parseData(Map data){
    List timeSeries = data[kCaseTimeSeries];

    confirmedTimeSeries = List();
    infectedTimeSeries = List();
    recoveredTimeSeries = List();
    deathsTimeSeries = List();
    dateTimeSeries = List();

    for(int i = 0;i<timeSeries.length;i++){
      Map map = timeSeries[i];

      confirmedTimeSeries.add(double.parse(map[kTotalConfirmed]));
      recoveredTimeSeries.add(double.parse(map[kTotalRecovered]));

      deathsTimeSeries.add(double.parse(map[kTotalDeaths]));

      infectedTimeSeries.add(
          double.parse(map[kTotalConfirmed])
              -recoveredTimeSeries[i]
              -deathsTimeSeries[i]
      );

      dateTimeSeries.add(DateTime(
        2020,
        _getMonth(map[kDate].toString().substring(3).trim()),
        int.parse(map[kDate].toString().substring(0,2)),
      ));

    }
  }

  List<double> gradient(List<double> list){

    List<double> gradient = List();

    for(int i = 0; i<list.length;i++){
      if(i == 0){
        double value = list[i+1] - list[i];
        gradient.add(value);
      }else if(i == list.length-1){
        double value = list[i] - list[i-1];
        gradient.add(value);
      }else{
        double value = (list[i+1] - list[i-1])/2;
        gradient.add(value);
      }
    }

    return gradient;

  }

  List<double> mortalityRate(){
    List<double> mortalityRates = List();

    for(int i = 0;i<confirmedTimeSeries.length;i++){
      double numerator;
      double denominator;

      numerator = deathsTimeSeries[i];
      denominator = confirmedTimeSeries[i];

      if(denominator == 0){
        denominator = 1;
      }

      double mr = (numerator/denominator)*100;

      mortalityRates.add(mr);

    }

    return mortalityRates;

  }

  List<double> recoveryRate(){
    List<double> recoveryRates = List();

    for(int i = 0;i<confirmedTimeSeries.length;i++){
      double numerator;
      double denominator;

      numerator = recoveredTimeSeries[i];
      denominator = confirmedTimeSeries[i];

      if(denominator == 0){
        denominator = 1;
      }

      double rr = (numerator/denominator)*100;

      recoveryRates.add(rr);

    }

    return recoveryRates;

  }

  Map<String,int> getCases(){
    Map<String,int> map = HashMap();

    for(int i = 0;i<confirmedTimeSeries.length;i++){
      String key = getKey(confirmedTimeSeries[i]);
      if(key == "NONE"){
        continue;
      }

      map.putIfAbsent(key, () => i);
    }

    print(map);
    return map;
  }

  String getKey(double n){
    if(n>=900000){
      return "900000";
    }else if(n>=800000){
      return "00000";
    }else if(n>=700000){
      return "700000";
    }else if(n>=600000){
      return "600000";
    }else if(n>=500000){
      return "500000";
    }else if(n>=400000){
      return "400000";
    }else if(n>=300000){
      return "300000";
    }else if(n>=200000){
      return "200000";
    }else if(n>=100000){
      return "100000";
    }else if(n>=90000){
      return "90000";
    }else if(n>=80000){
      return "80000";
    }else if(n>=70000){
      return "70000";
    }else if(n>=60000){
      return "60000";
    }else if(n>=50000){
      return "50000";
    }else if(n>=40000){
      return "40000";
    }else if(n>=30000){
      return "30000";
    }else if(n>=20000){
      return "20000";
    }else if(n>=10000){
      return "10000";
    }else if(n>=1000){
      return "1000";
    }else if(n>=100){
      return "100";
    }else{
      return "NONE";
    }
  }

  List<double> growthRatio(List<double> list){
    List<double> growthRatios = List();

    for(int i = 0;i<list.length;i++){
      double numerator;
      double denominator;

      if(i==0){
        numerator = list[i];
        denominator = 1;
      }else{
        numerator = list[i];
        denominator = list[i-1];
      }

      if(denominator == 0){
        denominator = 1;
      }
      double gr = numerator/denominator;
      growthRatios.add(gr);
    }

    return growthRatios;
  }

  List<double> growthFactor(List<double> list){
    List<double> growthFactors = List();

    for(int i = 0; i<list.length;i++){
      double numerator;
      double denominator;

      if(i==0){
        numerator = list[i];
        denominator = 1;
      }else if(i == 1){
        numerator = list[i] - list[i-1];
        denominator = list[i-1];
      }else{
        numerator = list[i] - list[i-1];
        denominator = list[i-1] - list[i-2];
      }

      if(denominator == 0){
        denominator = 1;
      }

      double gf = numerator/denominator;
      growthFactors.add(gf);
    }

    return growthFactors;

  }

  List<double> getLog(List<double> list){
    List<double> logs = List();
    list.forEach((element) {
      logs.add(
        element==0?log(1):log(element),
      );
    });
    return logs;
  }

  int _getMonth(String month){
    switch(month){
      case "January":
        return 1;
        break;
      case "February":
        return 2;
        break;
      case "March":
        return 3;
        break;
      case "April":
        return 4;
        break;
      case "May":
        return 5;
        break;
      case "June":
        return 6;
        break;
      case "July":
        return 7;
        break;
      case "August":
        return 8;
        break;
      case "September":
        return 9;
        break;
      case "October":
        return 10;
        break;
      case "November":
        return 11;
        break;
      case "December":
        return 12;
        break;
      default:
        return 12;
    }
  }

}