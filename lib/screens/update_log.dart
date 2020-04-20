import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/data/update_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

class UpdatesScreen extends StatefulWidget{
  @override
  _UpdatesScreenState createState() {
    return _UpdatesScreenState();
  }
}

class _UpdatesScreenState extends State<UpdatesScreen>{

  double textScaleFactor = 1;

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);

    if(size.width <= 360){
      textScaleFactor = 0.75;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder(
        future: Future.wait([UpdateLog.getInstance()]),
        builder: (BuildContext context,snapshot){

          if(!snapshot.hasData){
            return Container(
              height: double.infinity,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if(snapshot.hasError){
            return Container(
              height: double.infinity,
              child: Text(
                'Some Error Occurred',
                style: TextStyle(
                  fontFamily: kNotoSansSc,
                  color: theme.accentColor,
                ),
              ),
            );
          }

          List updatesData = snapshot.data[0];
          List<UpdateModel> updates = List();

          int today = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            2
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
                'No new updates for today',
                style: TextStyle(
                  fontFamily: kNotoSansSc,
                  fontWeight: FontWeight.bold,
                  color: theme.accentColor,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        "Recent Updates",
                        style: TextStyle(
                          fontFamily: kQuickSand,
                          fontWeight: FontWeight.bold,
                          fontSize: 18*textScaleFactor,
                        ),
                      ),
                      Text(
                        "As per covid19india.org",
                        style: TextStyle(
                          fontFamily: kQuickSand,
                          fontSize: 12*textScaleFactor,
                        ),
                      ),
                    ],
                  ),
                ),
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
                                    fontFamily: kNotoSansSc,
                                    fontSize: 16*textScaleFactor,
                                    fontWeight: FontWeight.bold,
                                    color: theme.accentColor,
                                  ),
                                ),
                                Divider(color: kGreyColor,),
                                Text(
                                  updates[index].update,
                                  style: TextStyle(
                                    fontFamily: kNotoSansSc,
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