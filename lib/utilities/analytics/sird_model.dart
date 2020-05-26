import 'dart:collection';
import 'package:covid19_tracker/constants/api_constants.dart';

class SIRD{

  List<double> infectedTimeSeries;
  List<double> recoveredTimeSeries;
  List<double> deathsTimeSeries;
  List<DateTime> dateTimeSeries;

  double _susceptible;
  double _infectious;
  double _recovered;
  double _deaths;

  void parseData(Map data){

    List timeSeries = data[kCaseTimeSeries];

    infectedTimeSeries = List();
    recoveredTimeSeries = List();
    deathsTimeSeries = List();
    dateTimeSeries = List();

    int lastDate = int.parse(timeSeries[timeSeries.length-1][kDate].toString().substring(0,3));

    int max = 0;
    if(lastDate<=30){
      if((lastDate+1)%31 > DateTime.now().day){
        max = timeSeries.length-1;
      }else{
        max = timeSeries.length;
      }
    }else if(lastDate==31){
      if((lastDate+1)%32 > DateTime.now().day){
        max = timeSeries.length-1;
      }else{
        max = timeSeries.length;
      }
    }else{
      max = timeSeries.length;
    }

    for(int i = 0;i<max;i++){
      Map map = timeSeries[i];

      recoveredTimeSeries.add(double.parse(map[kTotalRecovered]));

      deathsTimeSeries.add(double.parse(map[kTotalDeaths]));

      double infected = double.parse(map[kTotalConfirmed])-recoveredTimeSeries[i]-deathsTimeSeries[i];
      infectedTimeSeries.add(infected);

      dateTimeSeries.add(DateTime(
        2020,
        getMonth(map[kDate].toString().substring(3).trim()),
        int.parse(map[kDate].toString().substring(0,2)),
      ));

    }

  }


  //prediction of cases
  List<Map<String,double>> predict(){
    _susceptible = 1.376e09;
    double alpha = 0.3;

    _infectious = infectedTimeSeries[0];
    _recovered = recoveredTimeSeries[0];
    _deaths = deathsTimeSeries[0];

    List<double> coefficients = estimateCoefficient(_susceptible,_infectious,_recovered,_deaths,infectedTimeSeries.length,alpha);

    _susceptible = coefficients[3];
    _infectious = coefficients[4];
    _recovered = coefficients[5];
    _deaths = coefficients[6];

    List<Map<String,double>> predictedCases = List();

    for(int i = 0;i<5;i++){
      predictedCases.add(
        predictOneDay(coefficients),
      );
    }

    return predictedCases;

  }


  // Estimates coefficients a,b,c
  List<double> estimateCoefficient(double S,double I,double R,double D,int timeSeriesLength,double alpha){
    double dI = I;
    double dR = R;
    double dD = D;

    double b = I==0?0.0:dR/I;
    double c = I==0?0.0:dD/I;
    double a = (S*I)==0?0.0:(dI+(b+c)*I)/S/I;

    double sb = b;
    double sc = c;
    double sa = a;

    for(int i = 1;i<timeSeriesLength;i++){

      I = infectedTimeSeries[i];
      R = recoveredTimeSeries[i];
      D = deathsTimeSeries[i];
      S = S - (a*S*infectedTimeSeries[i-1]).round();

      dI = infectedTimeSeries[i] - infectedTimeSeries[i-1];
      dR = recoveredTimeSeries[i] - recoveredTimeSeries[i-1];
      dD = deathsTimeSeries[i] - deathsTimeSeries[i-1];

      b = I==0?0:dR/I;
      c = I==0?0:dD/I;
      a = (S*I)==0?0.0:(dI+(b+c)*I)/S/I;

      sb = alpha*b + (1-alpha) * sb;
      sc = alpha*c + (1-alpha) * sc;
      sa = alpha*a + (1-alpha) * sa;

    }

    return [sa,sb,sc,S,I,R,D];
  }

  Map<String,double> predictOneDay(List<double> predictedValues){

    double sa = predictedValues[0];
    double sb = predictedValues[1];
    double sc = predictedValues[2];

    double dR = (sb*_infectious).round().toDouble();
    double dD = (sc*_infectious).round().toDouble();
    double dI = (sa*_susceptible*_infectious - (sb + sc)*_infectious);
    double dS = -(sa*_susceptible*_infectious);

    _susceptible = _susceptible+dS.toInt();
    _infectious = _infectious+dI.toInt();
    _recovered = _recovered+dR.toInt();
    _deaths = _deaths+dD.toInt();


    Map<String,double> map = HashMap();
    map[kTotalConfirmed] = _infectious+_recovered+_deaths;
    map[kTotalRecovered] = _recovered;
    map['totalactive'] = _infectious;
    map[kTotalDeaths] = _deaths;
    map[kDeltaConfirmed] = dI+dR+dD;
    map[kDeltaRecovered] = dR;
    map[kDeltaDeaths] = dD;
    map['deltaactive'] = dI;


    return map;

  }


  int getMonth(String month){
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