/*
*
* Used for translating the app from the language
* JSON file present in lang package
*
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations{
  final Locale locale;

  AppLocalizations(this.locale);

  //Helper method to keep the code in the widgets concise
  //Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizations of(BuildContext context){
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  Map<String,String> _localizedStrings;

  Future<bool> load()async{
    //Load the language JSON file from the "lang" folder
    String jsonString = await rootBundle.loadString('lang/${locale.languageCode}-${locale.countryCode.toUpperCase()}.json');
    Map<String,dynamic> jsonMap = jsonDecode(jsonString);

    _localizedStrings = jsonMap.map((key,value){
      return MapEntry(key,value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs the localized text
  String translate(String key){
    return _localizedStrings[key];
  }

 }

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be getting an AppLocalizations object
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations>{
  // This delegate instance will never change
  // It can be provided a constant constructor
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Includes all of the supported language codes here
    return ['en','hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async{
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(LocalizationsDelegate old) {
    return false;
  }
}

class SpecifiedLocalizationDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  final Locale overriddenLocale;

  const SpecifiedLocalizationDelegate(this.overriddenLocale);

  @override
  bool isSupported(Locale locale) => overriddenLocale != null;

  @override
  Future<AppLocalizations> load(Locale locale) async{
   AppLocalizations localizations = AppLocalizations(overriddenLocale);
   await localizations.load();
   return localizations;
  }

  @override
  bool shouldReload(SpecifiedLocalizationDelegate old) => true;
}