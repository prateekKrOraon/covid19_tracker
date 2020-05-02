import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/models/preventions_and_symptoms.dart';
import 'package:flutter/material.dart';

class SymptomsScreen extends StatefulWidget{
  @override
  _SymptomsScreenState createState() {
    return _SymptomsScreenState();
  }
}

class _SymptomsScreenState extends State<SymptomsScreen>{

  @override
  Widget build(BuildContext context) {

    AppLocalizations lang = AppLocalizations.of(context);

    final List<PreventionAndSymptomsModel> _symptoms = [
      PreventionAndSymptomsModel(
        title: lang.translate(kFeverLang),
        des: lang.translate(kFeverDesLang),
        que: lang.translate(kFeverQueLang),
        imageLoc: 'assets/covid_symptom_fever.png',
      ),
      PreventionAndSymptomsModel(
        title: lang.translate(kCoughLang),
        des: lang.translate(kCoughDesLang),
        que: lang.translate(kCoughQueLang),
        imageLoc: "assets/covid_symptom_cough.png",
      ),
      PreventionAndSymptomsModel(
        title: lang.translate(kBreathLang),
        des: lang.translate(kBreathDesLang),
        que: lang.translate(kBreathQueLang),
        imageLoc: "assets/covid_symptom_breath.png",
      ),
      PreventionAndSymptomsModel(
        title: lang.translate(kOtherSymptomsLang),
        des: lang.translate(kOtherSymptomsDesLang),
        que: lang.translate(kOtherSymptomsQueLang),
        imageLoc: "",
      ),
    ];

    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.translate(kSymptomsLang),
          style: TextStyle(
            fontFamily: kQuickSand,
            color: theme.brightness == Brightness.light?Colors.black:Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  lang.translate(kSymptomsOfCoronaVirusLang),
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 24,
                    color: theme.accentColor
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  lang.translate(kSymptomsOfCoronaAnsLang),
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20,),
                Text(
                  lang.translate(kMajorAndCommonSymptomsLang),
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 24,
                    color: theme.accentColor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _symptoms.length,
                  itemBuilder: (BuildContext context,int index){
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal:8.0,vertical: 4.0),
                      child: Container(
                        padding: EdgeInsets.all(10,),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                _symptoms[index].imageLoc != ""?
                                ClipOval(
                                  child: Image(
                                    height: 75,
                                    width: 75,
                                    image:  AssetImage(
                                      _symptoms[index].imageLoc,
                                    ),
                                  ),
                                ):
                                SizedBox(),
                                _symptoms[index].imageLoc != ""?
                                SizedBox(width: 10,):
                                SizedBox(),
                                Text(
                                  _symptoms[index].title,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: kQuickSand,
                                    color: theme.accentColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10,),
                            Text(
                              _symptoms[index].des,
                              style:TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: index == 3?16:20,
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text(
                              _symptoms[index].que,
                              style:TextStyle(
                                fontFamily: kQuickSand,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}