import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:flutter/material.dart';

class Country{

  String countryName;
  String countryNameHI;
  String continent;
  String flagLink;
  int id;
  String iso2;
  String iso3;
  int totalCases;
  int todayCases;
  int deaths;
  int todayDeaths;
  int recovered;
  int active;
  int critical;
  int mild;
  double casesPerOneMil;
  double deathsPerOneMil;
  int tests;
  double testPerOneMil;
  DateTime updated;
  List<double> cnfCasesSeries;
  List<double> recCasesSeries;
  List<double> detCasesSeries;

  initialize(){
    if(countryName == null){
      countryName = "";
    }
    if(countryNameHI == null){
      if(countryName != null){
        countryNameHI = countryName;
      }else{
        countryNameHI = "";
      }
    }
    if(continent == null){
      continent = "";
    }
    if(flagLink == null){
      flagLink = "";
    }
    if(id == null){
      id = 0;
    }
    if(iso2 == null){
      iso2 = "";
    }
    if(iso3 == null){
      iso3 = "";
    }
    if(totalCases == null){
      totalCases = 0;
    }
    if(todayCases == null){
      todayCases = 0;
    }
    if(recovered == null){
      recovered = 0;
    }
    if(deaths == null){
      deaths = 0;
    }
    if(todayDeaths == null){
      todayDeaths = 0;
    }
    if(active == null){
      active = 0;
    }
    if(critical == null){
      critical = 0;
    }
    if(mild == null){
      mild = 0;
    }
    if(casesPerOneMil == null){
      casesPerOneMil = 0.0;
    }
    if(deathsPerOneMil == null){
      deathsPerOneMil = 0.0;
    }
    if(tests == null){
      tests = 0;
    }
    if(testPerOneMil == null){
      testPerOneMil = 0;
    }
    if(updated == null){
      updated = DateTime.now();
    }
  }

  void generateList(Map map){
    cnfCasesSeries = List();
    recCasesSeries = List();
    detCasesSeries = List();

    map.forEach((key, value) {
      cnfCasesSeries.add(
        double.parse(value[kConfirmed].toString()),
      );
      recCasesSeries.add(
        double.parse(value[kRecovered].toString()),
      );
      detCasesSeries.add(
        double.parse(value[kDeaths].toString()),
      );
    });

  }

  Country.fromMap(BuildContext context, Map<String,dynamic> map){
    try{
      this.countryName = map[kCountry];
      this.continent = map[kCountryContinent];
      this.flagLink = map[kCountryInfo][kFlagLink];
      this.countryNameHI = map['country_hi'];
      this.updated = DateTime.fromMillisecondsSinceEpoch(map[kCountryUpdated]);
      this.id = map[kCountryInfo][kCountryID];
      this.iso2 = map[kCountryInfo][kISO2];
      this.iso3 = map[kCountryInfo][kISO3];
      this.totalCases = int.parse(map[kCountryTotalCases].toString());
      this.todayCases = int.parse(map[kCountryTodayCases].toString());
      this.deaths = int.parse(map[kCountryDeaths].toString());
      this.todayDeaths = int.parse(map[kCountryTodayDeaths].toString());
      this.recovered = int.parse(map[kCountryRecovered].toString());
      this.active = int.parse(map[kCountryActive].toString());
      this.critical = int.parse(map[kCountryCritical].toString());
      this.casesPerOneMil = double.parse(map[kCountryCasesPerOneMil].toString());
      this.deathsPerOneMil = double.parse(map[kCountryDeathsPerOneMil].toString());
      this.tests = int.parse(map[kCountryTests].toString());
      this.testPerOneMil = double.parse(map[kCountryTestsPerOneMil].toString());
      this.mild = active-critical;
    }catch(e){
      initialize();
    }
  }

}