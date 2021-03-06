import 'dart:collection';
import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/data/resources_data.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:covid19_tracker/utilities/models/resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import '../error_screen.dart';

class ResourcesScreen extends StatefulWidget{
  @override
  _ResourcesScreenState createState() {
    return _ResourcesScreenState();
  }
}

class _ResourcesScreenState extends State<ResourcesScreen>{

  NetworkHandler _networkHandler;
  double scaleFactor = 1;

  @override
  void initState() {
    _networkHandler = NetworkHandler.getInstance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if(size.width<400){
      scaleFactor = 0.75;
    }else if(size.width<=450){
      scaleFactor = 0.9;
    }

    ThemeData theme = Theme.of(context);
    return FutureBuilder(
      future: ResourcesList.getInstance(),
      builder: (BuildContext context, snapshot){

        if(snapshot.connectionState == ConnectionState.waiting){
          return Column(
            children: [
              LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: theme.scaffoldBackgroundColor,
              ),
              SizedBox(
                height: size.height*0.4,
              ),
              Text(
                AppLocalizations.of(context).translate(kLoadingMessageLang),
                style: TextStyle(
                  fontFamily: kQuickSand,
                ),
              ),
            ],
          );
        }
        if(snapshot.hasError){
          return Center(
            child: ErrorScreen(
              onClickRetry: (){
                setState(() {
                  ResourcesList.refresh();
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
                  ResourcesList.refresh();
                });
              },
            ),
          );
        }

        Map data = snapshot.data;
        List resources = data[kResources];

        Map<String,List<Resources>> stateWiseResources = HashMap();

        resources.forEach((map){
          if(stateWiseResources.containsKey(map[kState])){
            stateWiseResources[map[kState]].add(
              Resources.fromMap(map),
            );
          }else{
            stateWiseResources[map[kState]] = List();
            stateWiseResources[map[kState]].add(
              Resources.fromMap(map),
            );
          }
        });

        stateWiseResources.forEach((_,v){
          v.sort((a,b)=> a.city.compareTo(b.city));
        });

        return DefaultTabController(
          length: stateWiseResources.length,
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: TabBar(
              isScrollable: true,
              tabs: _getTabs(stateWiseResources),
            ),
            body: TabBarView(
              children: _getTabPages(stateWiseResources),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _getTabPages(Map<String,List<Resources>> map){

    List<Widget> list = List();

    AppLocalizations lang = AppLocalizations.of(context);
    List<String> keys = map.keys.toList()..sort();

    for(int i = 0; i<keys.length; i++){
      List<Resources> resources = map[keys[i]];

      list.add(
        Container(
          child: Scrollbar(
            child: ListView.builder(
              itemCount: map[keys[i]].length,
              itemBuilder: (BuildContext context,int index){
                String cityName = lang.translate(resources[index].city.toLowerCase().replaceAll(" ", "_"));
                String category = lang.translate(resources[index].category.toLowerCase().replaceAll(" ", "_"));
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                  child: Material(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    elevation: 2,
                    color: Theme.of(context).backgroundColor,
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
                              cityName==null?"${resources[index].city}":cityName,
                              style: TextStyle(
                                fontSize: 16*scaleFactor,
                                fontFamily: kNotoSansSc,
                                color: Theme.of(context).accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5*scaleFactor,),
                            Text(
                              category==null?"${resources[index].category}":category,
                              style: TextStyle(
                                fontSize: 18*scaleFactor,
                                fontFamily: kNotoSansSc,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10*scaleFactor,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  Icons.person_outline,
                                  size: 24*scaleFactor,
                                ),
                                SizedBox(width: 10*scaleFactor,),
                                Expanded(
                                  child: Text(
                                    resources[index].name,
                                    style: TextStyle(
                                      fontSize: 16*scaleFactor,
                                      fontFamily: kNotoSansSc,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10*scaleFactor,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  MaterialCommunityIcons.information_outline,
                                  size: 24*scaleFactor,
                                ),
                                SizedBox(width: 10*scaleFactor,),
                                Expanded(
                                  child: Text(
                                    resources[index].description,
                                    style: TextStyle(
                                      fontSize: 14*scaleFactor,
                                      fontFamily: kNotoSansSc,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20*scaleFactor,),
                              ],
                            ),
                            SizedBox(height: 10*scaleFactor,),
                            InkWell(
                              onTap: (){
                                _networkHandler.launchInBrowser(resources[index].contactWeb);
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    MaterialCommunityIcons.web,
                                    size: 24*scaleFactor,
                                  ),
                                  SizedBox(width: 10*scaleFactor,),
                                  Expanded(
                                    child: Text(
                                      resources[index].contactWeb,
                                      maxLines: 2,
                                      style: TextStyle(
                                        fontSize: 14*scaleFactor,
                                        fontFamily: kNotoSansSc,
                                        color: kBlueColor,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 20*scaleFactor,),
                                ],
                              ),
                            ),
                            SizedBox(height: 10*scaleFactor,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  MaterialCommunityIcons.phone_outline,
                                  size: 24*scaleFactor,
                                ),
                                SizedBox(width: 10*scaleFactor,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: _getPhoneNum(resources[index].phoneNo),
                                  ),
                                ),
                                SizedBox(width: 20*scaleFactor,),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        )
      );
    }

    return list;

  }

  List<Widget> _getPhoneNum(List<String> list){
    List<Widget> phoneNo = List();

    list.forEach((item){
      phoneNo.add(
        InkWell(
          onTap: (){
            _networkHandler.launchInBrowser("tel:$item");
          },
          child: Column(
            children: <Widget>[
              Text(
                item.toString(),
                maxLines: 2,
                style: TextStyle(
                  fontSize: 14*scaleFactor,
                  fontFamily: kNotoSansSc,
                  color: kBlueColor,
                  fontStyle: FontStyle.italic
                ),
              ),
              SizedBox(height: 5*scaleFactor,),
            ],
          ),
        ),
      );
    });

    return phoneNo;
  }

  List<Widget> _getTabs(Map map){

    List<Widget> list = List();
    List<String> keys = map.keys.toList()..sort();

    for(int i = 0; i<keys.length;i++){
      String name = AppLocalizations
          .of(context)
          .translate(keys[i].toString().toLowerCase().replaceAll(" ", "_"),);

      if(name == null){
        name = keys[i].toString();
      }
      try{
        list.add(
          Tab(
            text: name,
          ),
        );
      }catch(e){
        e.toString();
      }
    }

    return list;
  }
}