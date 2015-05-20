/* 
 * Handles reading from SMHI, and stores the weatherparameters 
 * in a List containing WeatherSets.
 */

library load_yr;

import 'package:xml/xml.dart';
import 'dart:html';
import 'package:intl/intl.dart';
import 'dart:async';


import 'package:weatherapplication/component/weather_data.dart';

class LoadYr {
  List<WeatherSet> weatherSets = [];
  var allData;
  WeatherSet currentWeatherSet;
  final DateFormat formatter = new DateFormat('HH:mm d/M');
  

  Future loadData(double latitude, double longitude) {
    print("Loading YR2-data");

    String latitudeString = latitude.toStringAsPrecision(4);
    String longitudeString = longitude.toStringAsPrecision(4);
    
    //Url to proxy server that calls yr API with passed parameters
    var url = 'http://xn--petrahlin-47a.se/proxy.php?lon=$longitudeString&lat=$latitudeString';

    
    //Call proxy
    return HttpRequest.getString(url).then((String responseText) {

      //Parse response text
      allData = parse(responseText);

      setWeatherParameters();

      currentWeatherSet = weatherSets[1];
        
      print("Loading YR done");
      
    }, onError: (error) => printError(error));
  }


  void setWeatherParameters() {
    String cloud, rain, wind, timeFormatted;
    double currentTemp, currentWind, currentCloud, currentRain;
    DateTime currentTime;
    
    weatherSets.clear();
   
    List<XmlNode> temperatures = allData.findAllElements('temperature');
    List<XmlNode> times = allData.findAllElements('time');
    List<XmlNode> winds = allData.findAllElements('windSpeed');
    List<XmlNode> clouds = allData.findAllElements('cloudiness');
    List<XmlNode> rains = allData.findAllElements('precipitation');
    
    for(int i=0; i < temperatures.length;i++){
      
      if(i < 65)
      {
        currentTime = DateTime.parse(times.elementAt(i*5).attributes.elementAt(2).value);
        currentRain = double.parse(rains.elementAt(i*4).attributes.elementAt(1).value);
      }
      else
      {
        break;
      }
              
      currentTemp = double.parse(temperatures.elementAt(i).attributes.elementAt(2).value);
      currentWind = double.parse(winds.elementAt(i).attributes.elementAt(1).value);
      currentCloud = double.parse(clouds.elementAt(i).attributes.elementAt(1).value);
      
      
      wind = getWind(currentWind);
      cloud = getCloud(currentCloud);
      rain = getRain(currentRain);
            
      timeFormatted = formatter.format(currentTime);      
      
      weatherSets.add(new WeatherSet(currentTemp, cloud, rain, wind, timeFormatted, currentTime));
      
    }  
    
    print("Loading YR done");
    
  }
  
  //Primitive way of translating parameters from numbers to Strings
  String getCloud(double cloudIndex) {
    String cloud;

    if (cloudIndex == 12.5) cloud = "Sol"; 
    else if (cloudIndex <= 37.5 && cloudIndex > 12.5) cloud = "Lite moln"; 
    else if (cloudIndex < 75 && cloudIndex > 37.5) cloud = "Växlande molnighet"; 
    else cloud = "Mulet";


    return cloud;
  }

  //TODO: Check if it is snow etc..
  String getRain(double rainIndex) {

    String rain;
    
    if(rainIndex != 0)
      rain = "Regn,"+ rainIndex.toString() + "mm/h"; 
    else
      rain = "Inget regn";

    return rain;
  }

  String getWind(double windIndex) {
    String wind = "";

    if (windIndex <= 0.3) wind = "Vindstilla"; 
    else if (windIndex > 0.3 && windIndex <= 3.3) wind = "Svag vind"; 
    else if (windIndex > 3.3 && windIndex <= 13.8) wind = "Blåsigt"; 
    else if (windIndex > 13.8 && windIndex <= 24.4) wind = "Mycket blåsigt"; 
    else if (windIndex > 24.4 && windIndex < 60) wind = "Storm";

    return wind;
  }
  
  void printError(error) {
    print("It doesn't work, too bad! Error code: ${error.code}");
  }
}