import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/models/preventions_and_symptoms.dart';
import 'package:flutter/material.dart';

class PreventionsScreen extends StatefulWidget{
  @override
  _PreventionScreenState createState() {
    return _PreventionScreenState();
  }
}

class _PreventionScreenState extends State<PreventionsScreen>{

  @override
  Widget build(BuildContext context) {

    AppLocalizations lang = AppLocalizations.of(context);

    final List<PreventionAndSymptomsModel> _preventions = [
      PreventionAndSymptomsModel(
        title: lang.translate(kPrevention1Lang),
        des: lang.translate(kPrevention1DesLang),
        que: lang.translate(kPrevention1QueLang),
        imageLoc: 'assets/wash_hands.PNG',
      ),
      PreventionAndSymptomsModel(
        title: lang.translate(kPrevention2Lang),
        des: lang.translate(kPrevention2DesLang),
        que: lang.translate(kPrevention2QueLang),
        imageLoc: "assets/social_distance.png",
      ),
      PreventionAndSymptomsModel(
        title: lang.translate(kPrevention3Lang),
        des: lang.translate(kPrevention3DesLang),
        que: lang.translate(kPrevention3QueLang),
        imageLoc: "assets/avoid_touch.png",
      ),
      PreventionAndSymptomsModel(
        title: lang.translate(kPrevention4Lang),
        des: lang.translate(kPrevention4DesLang),
        que: lang.translate(kPrevention4QueLang),
        imageLoc: "assets/hygiene.png",
      ),
    ];
    
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.translate(kPreventionLang),
          style: TextStyle(
            fontFamily: kQuickSand,
            color: theme.brightness == Brightness.light?Colors.black:Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  lang.translate(kHowToProtectLang),
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 24,
                    color: theme.accentColor,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  lang.translate(kHowToProtectAnsLang),
                  style: TextStyle(
                    fontFamily: kQuickSand,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20,),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _preventions.length,
                  itemBuilder: (BuildContext context,int index){
                    return Container(
                      padding: EdgeInsets.all(10,),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              ClipOval(
                                child: Image(
                                  height: 75,
                                  width: 75,
                                  image:  AssetImage(
                                    _preventions[index].imageLoc,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10,),
                              Text(
                                _preventions[index].title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: kQuickSand,
                                  color: theme.accentColor
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          Text(
                            _preventions[index].des,
                            style:TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10,),
                          Text(
                            _preventions[index].que,
                            style:TextStyle(
                              fontFamily: kQuickSand,
                              fontSize: 16,
                            ),
                          ),
                        ],
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