/* 
 * Handles reading from SMHI, and stores the weatherparameters 
 * in a List containing WeatherSets.
 */

library load_yr;

import 'package:xml/xml.dart';
import 'dart:html';
//import 'dart:convert';
import 'package:intl/intl.dart';


import 'dart:convert';

import 'package:weatherapplication/component/weather_data.dart';

class LoadYr {
  List<WeatherSet> weatherSets = [];
  var allData;
  WeatherSet currentWeatherSet;
  final DateFormat formatter = new DateFormat('HH:mm d/M');

  LoadYr(double latitude, double longitude) {
    _loadData(latitude, longitude);
  }
  

  _loadData(double latitude, double longitude) {
    print("Loading YR2-data");

    String latitudeString = latitude.toStringAsPrecision(4);
    String longitudeString = longitude.toStringAsPrecision(4);
    
    
    
    //Create URL to YR-API with longitude and latitude values
    //var url = 'http://api.yr.no/weatherapi/locationforecast/1.9/?lat=$latitudeString;lon=$longitudeString';
    //var url = 'http://api.yr.no/weatherapi/locationforecast/1.9/?lat=16.0;lon=58.0';
    var url = 'http://xn--petrahlin-47a.se/proxy.php?lon=$longitudeString&lat=$latitudeString';
    
    var request = new HttpRequest();
      
    request.open('GET', url);
//    request.setRequestHeader('Content-Type', 'text/plain');
    request.onLoad.listen((event) {
      allData = parse(event.target.responseText);
      
      //print(allData);
      
      setWeatherParameters();
      
    });
    request.send();
  }

  /*int getTimeIndex() {
    DateTime referenceTime = DateTime.parse(allData["referenceTime"]);
    DateTime now = new DateTime.now();

    //Difference in hours = timeIndex for current time in allData
    Duration difference = now.difference(referenceTime);
    return difference.inHours;
  }*/

  void setWeatherParameters() {
    String cloud, rain, wind, timeFormatted;
    int cloudIndex, rainIndex;
    double windIndex, currentTemp;
    DateTime currentTime;
    
    weatherSets.clear();
//    print("!!!!!!!!!!!!!!!!!!!!!!");
//    print("!!!!!!!!!!!!!!!!!!!!!!: " + allData.findElement("temperature").single.text);
//    
    List<XmlNode> temperatures = allData.findAllElements('temperature');
    List<XmlNode> times = allData.findAllElements('time');
    //List<XmlNode> temperatures = allData.findAllElements('temperature');
    
    //print(total);
    
    for(int i=0; i < temperatures.length;i++){
      
      currentTemp = double.parse(temperatures.elementAt(i).attributes.elementAt(2).value);
      currentTime = DateTime.parse(times.elementAt(i).attributes.elementAt(1).value);
            
      timeFormatted = formatter.format(currentTime);
            
      cloudIndex = 1;
      windIndex = 1.0;
      rainIndex = 1;
      //print();
      
      
      
      
      weatherSets.add(new WeatherSet(currentTemp, cloud, rain, wind, timeFormatted));
    }
    
   
    
    
    //total .map((node) => node.text) .forEach(print);
    
    //print("temp: " + total[0].text);
    
    //print("temp: " + total.toString());
    
/*    
    print("Bellow");
    for(int i = 0; i < calle.length; i++){
      
       var c = calle.elementAt(i);
        print("c : "  + c.toString()); 
    }
  */  
   
    
  }

  //Primitive way of translating parameters from numbers to Strings
  /*String getCloud(int cloudIndex) {
    String cloud;

    if (cloudIndex < 3) cloud = "Lite moln"; else if (cloudIndex < 6 && cloudIndex > 2) cloud = "Växlande molnighet"; else cloud = "Mulet";

    return cloud;
  }


  String getRain(int rainIndex, int timeIndex) {

    String rain;
    double howMuch;

    switch (rainIndex) {
      case 0:
        rain = "Inget regn";
        break;
      case 1:
        howMuch = allData["timeseries"][timeIndex]["pis"];
        rain = "Snö, $howMuch mm/h";
        break;
      case 2:
        howMuch = allData["timeseries"][timeIndex]["pis"] + allData["timeseries"][timeIndex]["pit"];
        rain = "Snöblandat regn, $howMuch mm/h";
        break;
      case 3:
        howMuch = allData["timeseries"][timeIndex]["pit"];
        rain = "Regn, $howMuch mm/h";
        break;
      case 4:
        rain = "Duggregn";
        break;
      case 5:
        rain = "Hagel";
        break;
      case 6:
        rain = "Smått hagel";
        break;
      default:
        rain = "";
    }

    return rain;
  }

  String getWind(double windIndex) {
    String wind = "";

    if (windIndex <= 0.3) wind = "Vindstilla"; else if (windIndex > 0.3 && windIndex <= 3.3) wind = "Svag vind"; else if (windIndex > 3.3 && windIndex <= 13.8) wind = "Blåsigt"; else if (windIndex > 13.8 && windIndex <= 24.4) wind = "Mycket blåsigt"; else if (windIndex > 24.4 && windIndex < 60) wind = "Storm";

    return wind;
  }
  */
  void printError(error) {
    print("It doesn't work, too bad! Error code: ${error.code}");
  }
}