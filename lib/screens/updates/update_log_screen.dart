import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/data/update_log.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../error_screen.dart';

class UpdatesScreen extends StatefulWidget{
  @override
  _UpdatesScreenState createState() {
    return _UpdatesScreenState();
  }
}

class _UpdatesScreenState extends State<UpdatesScreen>{

  double scaleFactor = 1;

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context);

    if(size.width <= 400){
      scaleFactor = 0.75;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title:Container(
          padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                lang.translate(kRecentUpdatesLang),
                style: TextStyle(
                  fontFamily: kQuickSand,
                  fontSize: 18*scaleFactor,
                  color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                ),
              ),
              Text(
                lang.translate(kRecentUpdatesSubTitleLang),
                style: TextStyle(
                  fontFamily: kQuickSand,
                  fontSize: 12*scaleFactor,
                  color: theme.brightness == Brightness.light?Colors.black:Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder(
        future: UpdateLog.getInstance(lang.locale.languageCode),
        builder: (BuildContext context,snapshot){

          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          if(snapshot.hasError){
            return Center(
              child: ErrorScreen(
                onClickRetry: (){
                  setState(() {
                    UpdateLog.refresh(lang.locale.languageCode);
                  });
                },
              ),
            );
          }
          if(!snapshot.hasData){
            return Center(
              child: ErrorScreen(
                onClickRetry: (){
                  setState(() {
                    UpdateLog.refresh(lang.locale.languageCode);
                  });
                },
              ),
            );
          }

          List updatesData = snapshot.data;
          List<UpdateModel> updates = List();

          int today = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            0,
            0,
            0,
            0,
            0,
          ).millisecondsSinceEpoch;

          for(int i = (updatesData.length-1);i>=0;i--){
            Map map = updatesData[i];
            if(map[kTimestamp]*1000 < today){
              break;
            }

            updates.add(
              UpdateModel.fromMap(map),
            );
          }

          if(updates.isEmpty){
            return Center(
              child: Text(
                lang.translate(kNoUpdatesLang),
                style: TextStyle(
                  fontFamily: kQuickSand,
                  fontSize: 16*scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: theme.accentColor,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: updates.length,
                  itemBuilder: (BuildContext context, int index){
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 10),
                      child: Material(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10)
                        ),
                        color: theme.backgroundColor,
                        elevation: 2,
                        child: Container(
                          width: size.width*0.7,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  DateFormat("d MMM").add_jm().format(updates[index].timestamp),
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 16*scaleFactor,
                                    fontWeight: FontWeight.bold,
                                    color: theme.accentColor,
                                  ),
                                ),
                                Divider(color: kGreyColor,),
                                Text(
                                  updates[index].update,
                                  style: TextStyle(
                                    fontFamily: kQuickSand,
                                    fontSize: 16*scaleFactor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class UpdateModel{
  DateTime timestamp;
  String update;

  UpdateModel.fromMap(Map map){
    this.update = map[kUpdate];
    this.timestamp = DateTime.fromMillisecondsSinceEpoch(map[kTimestamp]*1000);
  }

}