
/*
*
* Error screen shown in case of snapshot error
* or if snapshot is empty
*
*/

import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/language_constants.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatefulWidget{

  final Function onClickRetry;

  ErrorScreen({this.onClickRetry});

  @override
  _ErrorScreenState createState() {
    return _ErrorScreenState();
  }
}

class _ErrorScreenState extends State<ErrorScreen>{
  @override
  Widget build(BuildContext context) {

    AppLocalizations lang = AppLocalizations.of(context);

    Size size = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image(
            width: size.width*0.4,
            image: AssetImage(
              'assets/network_error_2_512.png'
            ),
          ),
          SizedBox(height: 10,),
          Text(
            lang.translate(kSnapshotErrorLang),
            style: TextStyle(
              fontSize: 18,
              fontFamily: kQuickSand,
            ),
          ),
          SizedBox(height: 40,),
          RaisedButton(
            elevation: 2,
            color: theme.accentColor,
            onPressed: widget.onClickRetry,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20,),),
            ),
            child: Text(
              lang.translate(kRetryLang),
              style: TextStyle(
                fontSize: 16,
                fontFamily: kQuickSand,
                color: theme.brightness == Brightness.light?Colors.white:Colors.black,
              ),
            ),
          )
        ],
      ),
    );
  }
}