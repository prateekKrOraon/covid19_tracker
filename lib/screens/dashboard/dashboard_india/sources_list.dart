/*
*
* This screen shows the information of all the
* verified sources of from where data is fed to
* the crowdsourced database
*
*/

import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';

import 'package:covid19_tracker/utilities/models/data_source.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../error_screen.dart';

class SourcesListScreen extends StatefulWidget{
  @override
  _SourcesListScreen createState() {
    return _SourcesListScreen();
  }

}

class _SourcesListScreen extends State<SourcesListScreen>{

  double textScaleFactor = 1;
  ThemeData theme;

  @override
  Widget build(BuildContext context) {

    theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;

    AppLocalizations lang = AppLocalizations.of(context);

    if(size.width<=360){
      textScaleFactor = 0.75;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          lang.translate(kSourcesLang),
          style: TextStyle(
            fontFamily: kQuickSand,
            color: theme.brightness == Brightness.light?Colors.black:Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: FutureBuilder(
            future: NetworkHandler.getInstance().getSourceList(),
            builder: (BuildContext context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return Container(height:size.width,child: Center(child: CircularProgressIndicator(),));
              }
              if(snapshot.hasError){
                return Center(
                  child: ErrorScreen(
                    onClickRetry: (){
                      setState(() {
                        //Future builder will rebuild itself and check for future
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
                        //Future builder will rebuild itself and check for future
                      });
                    },
                  ),
                );
              }

              if(snapshot.hasError){
                return Center(
                  child: Text(
                    lang.translate(kSnapshotErrorLang),
                    style: TextStyle(
                      fontFamily: kNotoSansSc,
                      fontSize: 20*textScaleFactor,
                    ),
                  ),
                );
              }

              Map data = snapshot.data;

              List sourceList = data[kSourceList];

              List<Source> stateSources = List();

              for(int i=0;i<sourceList.length;i++){
                Map map = sourceList[i];
                if(map[kRegion] == kGeneralSource || map[kRegion] == kTestingSource){
                  stateSources.add(
                    Source.fromMap(context,map),
                  );
                }
              }

              sourceList.forEach((map){
                if(map[kRegion] != kGeneralSource && map[kRegion] != kTestingSource){
                  stateSources.add(
                    Source.fromMap(context,map),
                  );
                }
              });


              return ListView.builder(
                  itemCount: stateSources.length,
                  itemBuilder:(BuildContext context, int index){
                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: Material(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: theme.backgroundColor,
                        elevation: 2,
                        child: Container(
                          decoration:BoxDecoration(
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
                                  stateSources[index].name,
                                  style: TextStyle(
                                    fontFamily: kNotoSansSc,
                                    fontSize: 20*textScaleFactor,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: _getSources(stateSources[index]),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
              );
            },
          )
        ),
      ),
    );
  }
  List<Widget> _getSources(Source source){
    List<Widget> list = List();
    for(int i=0;i<source.sources.length;i++){
      list.add(
        InkWell(
          onTap: (){
            if(source.sources[i].substring(0,4) == 'http' || source.sources[i].substring(0,5) == 'https'){
              NetworkHandler.getInstance().launchInBrowser(source.sources[i]);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${AppLocalizations.of(context).translate("source_${i+1}")}:",
                  style: TextStyle(
                    fontFamily: kNotoSansSc,
                    color: kGreyColor,
                    fontSize: 14*textScaleFactor,
                  ),
                ),
                SizedBox(width: 8,),
                Expanded(
                  child: Text(
                    source.sources[i],
                    style: TextStyle(
                      fontFamily: kNotoSansSc,
                      fontStyle: FontStyle.italic,
                      color: kBlueColor,
                      fontSize: 14*textScaleFactor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return list;
  }
}

