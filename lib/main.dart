import 'package:covid19_tracker/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:covid19_tracker/data/theme_data.dart';
import 'package:covid19_tracker/localization/app_localization.dart';
import 'package:covid19_tracker/screens/splash_screen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }

}

class _MyAppState extends State<MyApp>{

  SpecifiedLocalizationDelegate _localeOverrideDelegate;

  @override
  void initState() {
    initLocale();
    super.initState();
    _localeOverrideDelegate = SpecifiedLocalizationDelegate(null);
  }


  // function to save current locale information in shared preferences
  onLocaleChange(Locale locale)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _localeOverrideDelegate = SpecifiedLocalizationDelegate(locale);
    });
    await prefs.setString(kLangCode, locale.languageCode);
    await prefs.setString(kCountryCode,locale.countryCode);
  }

  // get current saved locale from shared preferences
  initLocale()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String langCode = prefs.getString("language_code");
    String countryCode = prefs.getString("country_code");
    if(countryCode != null && langCode != null){
      onLocaleChange(Locale(langCode,countryCode));
    }
  }

  @override
  Widget build(BuildContext context) {

    return DynamicTheme(
      defaultBrightness: Brightness.light,
      data: (brightness) => getTheme(brightness),
      themedWidgetBuilder: (context,theme){
        return MaterialApp(
          title: 'Covid-19 Tracker',
          theme: theme,
          //List of app supported locales here
          supportedLocales: [
            Locale('en','US'),
            Locale('hi','IN'),
          ],
          //These delegates makes sure that the localization data for the proper language is loaded
          localizationsDelegates: [
            _localeOverrideDelegate,
            // A class which loads the translations from JSON files
            AppLocalizations.delegate,
            //Built-in localization of basic text for material widgets
            GlobalMaterialLocalizations.delegate,
            //Built in localization for text direction LTR/RTL
            GlobalWidgetsLocalizations.delegate,
          ],
          //Returns a local which will be used by the app
          localeResolutionCallback: (locale, supportedLocales){
            //check if the current device locale is supported
            for(var supportedLocale in supportedLocales){
              if(supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode){
                return supportedLocale;
              }
            }
            //if the locale of the device is not supported, use the first one
            //from the list (English, in this case).
            return supportedLocales.first;
          },
          home: SplashScreen(onLocaleChange: onLocaleChange,),

        );
      },
    );
  }
}