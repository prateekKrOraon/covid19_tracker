import 'package:covid19_tracker/constants/api_constants.dart';

class Resources{
  String name;
  String state;
  String category;
  String city;
  String contactWeb;
  String description;
  List<String> phoneNo;

  Resources.fromMap(Map map){
    this.name = map[kOrganisationName];
    this.state = map[kState];
    this.city = map[kCity];
    this.category = map[kCategory];
    this.contactWeb = map[kContact];
    this.description = map[kDescription];
    this.phoneNo = map[kPhoneNo].toString().split(",\n");
  }
}