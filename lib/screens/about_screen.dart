import 'package:covid19_tracker/constants/api_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/screens/open_source_licenses.dart';
import 'package:covid19_tracker/utilities/network_handler.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class AboutScreen extends StatefulWidget{
  @override
  _AboutScreenState createState() {
    return _AboutScreenState();
  }
}

class _AboutScreenState extends State<AboutScreen>{

  NetworkHandler _networkHandler;
  double textScaleFactor = 1;
  ThemeData theme;
  bool darkTheme;

  @override
  void initState() {
    _networkHandler = NetworkHandler.getInstance();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    theme = Theme.of(context);
    darkTheme = theme.brightness == Brightness.dark?true:false;

    if(MediaQuery.of(context).size.width<=360){
      textScaleFactor=0.75;
    }
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 10,),
              Text(
                "COVID-19 TRACKER, INDIA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30*textScaleFactor,
                  fontFamily: kQuickSand,
                ),
              ),
              Text(
                "Powered by api.covid19india.org",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: kGreyColor,
                  fontFamily: kQuickSand,
                ),
              ),
              SizedBox(height: 30,),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                elevation: 2,
                color: theme.backgroundColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Source',
                        style: TextStyle(
                          fontSize: 25*textScaleFactor,
                          fontFamily: kQuickSand,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          _networkHandler.launchInBrowser(crowdSourcedDatabaseLink);
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 30,),
                              Icon(
                                Icons.storage,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  'Croudsourced patient database',
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.launch,
                                color: theme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          _networkHandler.launchInBrowser(covid19IndiaAPILink);
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 30,),
                              Icon(
                                Icons.web_asset,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  'api.covid19india.org',
                                  style: TextStyle(
                                      fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.launch,
                                color: theme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                elevation: 2,
                color: theme.backgroundColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Developer',
                        style: TextStyle(
                          fontSize: 25*textScaleFactor,
                          fontFamily: kQuickSand,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          _networkHandler.launchInBrowser(developerPrateekGitHubLink);
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 30,),
                              Icon(
                                AntDesign.github,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  'Prateek Kumar Oraon',
                                  style: TextStyle(
                                      fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.launch,
                                color: theme.accentColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                elevation: 2,
                color: theme.backgroundColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Application',
                        style: TextStyle(
                          fontSize: 25*textScaleFactor,
                          fontFamily: kQuickSand,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        height: 56,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 30,),
                            Icon(
                              AntDesign.infocirlceo,
                              color: theme.accentColor,
                            ),
                            SizedBox(width: 30,),
                            Expanded(
                              child: Text(
                                'Version',
                                style: TextStyle(
                                  fontSize: 16*textScaleFactor,
                                ),
                              ),
                            ),
                            Text(
                              '1.0.0',
                              style: TextStyle(
                                fontSize: 16*textScaleFactor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 56,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 30,),
                            Icon(
                              darkTheme?Icons.brightness_2:Icons.brightness_5,
                              color: theme.accentColor,
                            ),
                            SizedBox(width: 30,),
                            Expanded(
                              child: Text(
                                darkTheme?'Light Theme':'Dark Theme',
                                style: TextStyle(
                                  fontSize: 16*textScaleFactor,
                                ),
                              ),
                            ),
                            Switch(
                              value: darkTheme,
                              activeColor: theme.accentColor,
                              onChanged: (bool value){
                                changeBrightness();
                                setState(() {
                                  darkTheme = value;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Material(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
                elevation: 2,
                color: theme.backgroundColor,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'License',
                        style: TextStyle(
                          fontSize: 25*textScaleFactor,
                          fontFamily: kQuickSand,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OpenSourceLicenses(),
                            ),
                          );
                        },
                        child: Container(
                          height: 56,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 30,),
                              Icon(
                                MaterialCommunityIcons.license,
                                color: theme.accentColor,
                              ),
                              SizedBox(width: 30,),
                              Expanded(
                                child: Text(
                                  'Open Source Licenses',
                                  style: TextStyle(
                                    fontSize: 16*textScaleFactor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void changeBrightness() {
    DynamicTheme.of(context).setBrightness(theme.brightness == Brightness.dark? Brightness.light: Brightness.dark);
  }
}