import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/utilities/helpers/network_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

import '../error_screen.dart';

class FAQsScreen extends StatefulWidget{
  @override
  _FAQsScreenState createState() {
    return _FAQsScreenState();
  }
}

class _FAQsScreenState extends State<FAQsScreen>{

  double scaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context);
    Size size = MediaQuery.of(context).size;

    if(size.width <= 400){
      scaleFactor = 0.75;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          lang.translate(kFAQs),
          style: TextStyle(
            fontFamily: kQuickSand,
            fontSize: 22*scaleFactor,
          ),
        ),
      ),
      body: FutureBuilder(
        future: NetworkHandler.getInstance().getFAQs(lang.locale.languageCode),
        builder: (BuildContext context,snapshot){

          if(snapshot.connectionState == ConnectionState.waiting){
            return Container(height:size.width,child: Center(child: CircularProgressIndicator(),));
          }
          if(snapshot.hasError){
            return Center(
              child: ErrorScreen(
                onClickRetry: (){
                  setState(() {

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

          List faqsList = snapshot.data;

          List<Widget> listTiles = List();
          faqsList.forEach((map){
            listTiles.add(
              _getListTile(map),
            );
          });

          return Container(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: listTiles.length,
                itemBuilder: (BuildContext context,int index){
                  return listTiles[index];
                },
              )
          );
        },
      ),
    );
  }

  Widget _getListTile(Map<String,dynamic> map){
    return ExpansionTile(
      title: Text(
        map[kCategory],
        style: TextStyle(
            fontFamily: kQuickSand,
            fontSize: 18*scaleFactor
        ),
      ),
      children: _getTileChildren(map[kFAQs]),
    );
  }

  List<Widget> _getTileChildren(List list){
    List<Widget> faqs = List();

    list.forEach((map){
      faqs.add(
        ExpansionTile(
          leading: Icon(
            AntDesign.plus,
            size: 16,
          ),
          title: Text(
            map[kQuestion],
            style: TextStyle(
                fontFamily: kQuickSand,
                fontSize: 18*scaleFactor
            ),
          ),
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                map[kAnswer],
                style: TextStyle(
                  fontFamily: kQuickSand,
                  fontSize: 16*scaleFactor,
                ),
              ),
            )
          ],
        ),
      );
    });

    return faqs;
  }
}