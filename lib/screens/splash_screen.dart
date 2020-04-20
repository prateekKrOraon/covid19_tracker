import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:covid19_tracker/constants/colors.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget{
  @override
  _SplashScreenState createState() {
    return _SplashScreenState();
  }
}

class _SplashScreenState extends State<SplashScreen>{

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3)).then((value){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (route) => false);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(),
            Text(
              'COVID-19 Tracker',
              style: TextStyle(
                  fontFamily: kQuickSand,
                  fontSize: 30,
                  fontWeight: FontWeight.bold
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Text(
                    'Powered by api.covid19india.org',
                    style: TextStyle(
                      color: kGreyColor,
                      fontFamily: kQuickSand,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}