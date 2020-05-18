/*
*
* Not in use anymore
* As size of the Raw data is increasing rapidly and complete information was not available
*
*/



import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/data/raw_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DemographicsScreen extends StatefulWidget{
  @override
  _DemographicsScreenState createState() {
    return _DemographicsScreenState();
  }
}

class _DemographicsScreenState extends State<DemographicsScreen>{

  double scaleFactor = 1;
  ThemeData theme;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    theme = Theme.of(context);

    if(size.width<400){
      scaleFactor = 0.75;
    }else if(size.width<=450){
      scaleFactor = 0.9;
    }

    return FutureBuilder(
      future: RawData.getInstance(),
      builder: (BuildContext context, snapshot){

        if(!snapshot.hasData){
          return Center(child: CircularProgressIndicator(),);
        }

        Map map = snapshot.data;
        List list = map[kRawData];

        int females = 0;
        int males = 0;
        int unknownGenders = 0;
        int unknownAge = 0;
        List<int> ageGroups = [0,0,0,0,0,0,0,0,0,0];
        List<String> ageGroupsStr = ['0-10','11-20','21-30','31-40','41-50','51-60','61-70','71-80','81-90','91-100'];

        for(int i = 0;i<list.length;i++){
          Map patient = list[i];
          if(patient[kGender] == ""){
            unknownGenders++;
          }else if(patient[kGender] == "F"){
            females++;
          }else if(patient[kGender] == "M"){
            males++;
          }
          if(patient[kAgeBracket] != ''){
            try{
              int age = int.parse(patient[kAgeBracket]);
              if(age>=0 && age<=10){
                ageGroups[0]++;
              }else if(age>10 && age<=20){
                ageGroups[1]++;
              }else if(age>20 && age<=30){
                ageGroups[2]++;
              }else if(age>30 && age<=40){
                ageGroups[3]++;
              }else if(age>40 && age<=50){
                ageGroups[4]++;
              }else if(age>50 && age<=60){
                ageGroups[5]++;
              }else if(age>60 && age<=70){
                ageGroups[6]++;
              }else if(age>70 && age<=80){
                ageGroups[7]++;
              }else if(age>80 && age<=90){
                ageGroups[8]++;
              }else if(age>90 && age<=100){
                ageGroups[9]++;
              }
            }catch(e){
              e.toString();
            }
          }else{
            unknownAge++;
          }
        }

        List<BarChartGroupData> ageGroupData = List();

        for(int i = 0;i<ageGroups.length;i++){
          ageGroupData.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  width: 15,
                  y: ageGroups[i].toDouble(),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                  color: theme.accentColor,
                ),
              ],
              showingTooltipIndicators: ageGroups,
            )
          );
        }


        return SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Material(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10)
                    ),
                    elevation: 2,
                    color: theme.backgroundColor,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Age Distribution',
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 25*scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Age unknown for $unknownAge patients',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontFamily: kQuickSand,
                                fontSize: 16*scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10,),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: AspectRatio(
                                  aspectRatio: 1.5,
                                  child: BarChart(
                                      BarChartData(
                                        maxY: 400,
                                        gridData: FlGridData(
                                          drawHorizontalLine: true,
                                          horizontalInterval: 50,
                                        ),
                                        borderData: FlBorderData(
                                            border: Border(
                                              left: BorderSide(
                                                width: 1,
                                                color: kGreyColor,
                                              ),
                                              bottom: BorderSide(
                                                width: 1,
                                                color: kGreyColor,
                                              ),
                                            )
                                        ),
                                        titlesData: FlTitlesData(
                                            leftTitles: SideTitles(
                                                showTitles: true,
                                                interval: 50,
                                                textStyle: TextStyle(
                                                  fontSize: 10*scaleFactor,
                                                  color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                                                ),
                                                getTitles: (double value){
                                                  return value.toInt().toString();
                                                }
                                            ),
                                            bottomTitles: SideTitles(
                                                showTitles: true,
                                                textStyle: TextStyle(
                                                  fontSize: 8*scaleFactor,
                                                  color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                                                ),
                                                getTitles: (double value){
                                                  switch(value.toInt()){
                                                    case 0:
                                                      return ageGroupsStr[0];
                                                      break;
                                                    case 1:
                                                      return ageGroupsStr[1];
                                                      break;
                                                    case 2:
                                                      return ageGroupsStr[2];
                                                      break;
                                                    case 3:
                                                      return ageGroupsStr[3];
                                                      break;
                                                    case 4:
                                                      return ageGroupsStr[4];
                                                      break;
                                                    case 5:
                                                      return ageGroupsStr[5];
                                                      break;
                                                    case 6:
                                                      return ageGroupsStr[6];
                                                      break;
                                                    case 7:
                                                      return ageGroupsStr[7];
                                                      break;
                                                    case 8:
                                                      return ageGroupsStr[8];
                                                      break;
                                                    case 9:
                                                      return ageGroupsStr[9];
                                                      break;
                                                    default:
                                                      return value.toInt().toString();
                                                  }
                                                }
                                            )
                                        ),
                                        barGroups: ageGroupData,
                                      )
                                  )
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20,),
                  Material(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    elevation: 2,
                    color: theme.backgroundColor,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              'Gender Distribution',
                              style: TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 25*scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Gender unknown for $unknownGenders patients',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontFamily: kQuickSand,
                                fontSize: 16*scaleFactor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10,),
                            AspectRatio(
                              aspectRatio: 1,
                              child: PieChart(
                                PieChartData(
                                  centerSpaceRadius: size.width*0.1,
                                  sectionsSpace: 0,
                                  borderData: FlBorderData(
                                    border: Border.all(
                                      width: 0,
                                    ),
                                  ),
                                  startDegreeOffset: 0,
                                  sections: [
                                    PieChartSectionData(
                                      value: females.toDouble(),
                                      color: Colors.pink,
                                      title: "Female",
                                      showTitle: true,
                                      radius: size.width*0.3,
                                    ),
                                    PieChartSectionData(
                                      value: males.toDouble(),
                                      color: kBlueColor,
                                      title: "Male",
                                      radius: size.width*0.3,
                                      showTitle: true,
                                    ),
                                    PieChartSectionData(
                                      value: unknownGenders.toDouble(),
                                      color: Colors.grey[700],
                                      title: "Unknown",
                                      radius: size.width*0.3,
                                      showTitle: true,
                                    ),
                                  ]
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


}