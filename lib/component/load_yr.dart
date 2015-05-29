/* 
 * Handles reading from SMHI, and stores the weatherparameters 
 * in a List containing WeatherSets.
 */

library load_yr;

import 'package:xml/xml.dart';
import 'dart:html';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:xml/xml.dart';


import 'package:weatherapplication/component/weather_data.dart';

class LoadYr {
  List<WeatherSet> weatherSets = [];
  var allData;
  WeatherSet currentWeatherSet;
  final DateFormat formatter = new DateFormat('HH:mm');
  

  Future loadData(double latitude, double longitude) {
    print("Loading YR2-data");

    String latitudeString = latitude.toStringAsPrecision(4);
    String longitudeString = longitude.toStringAsPrecision(4);
    
    //Url to proxy server that calls yr API with passed parameters
    var url = 'http://xn--petrahlin-47a.se/proxy.php?lon=$longitudeString&lat=$latitudeString';
    url = 'http://xn--petrahlin-47a.se/proxy.php?lon=9.58&lat=60.10';
    

    
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
    String cloud, rain, wind, timeFormatted, currentWeather;
    double currentTemp, currentWind, currentCloud, currentRain;
    DateTime currentTime;
    bool readRain = false;
    
    weatherSets.clear();
   
    //List<XmlElement> temperatures = allData.findAllElements('temperature');
    //List<XmlNode> times = allData.findAllElements('time');
    //List<XmlNode> winds = allData.findAllElements('windSpeed');
    //List<XmlNode> clouds = allData.findAllElements('cloudiness');
    //List<XmlNode> rains = allData.findAllElements('precipitation');
    //List<XmlNode> weather = allData.findAllElements('symbol');
  
    List<XmlElement> times = allData.findAllElements("time");
    
    /*while( i < times.length ){
      var date = times.elementAt(i).attributes.elementAt(1).value;
        
      print("date: " + date.toString());
      
      var location = times.elementAt(i).children;
        
      print("location: " + location.toString());
      
      
      
      print("===================================");
      i++;
    }*/
    
    
    times.forEach((time){
      print("=================== new date ==========================");
      if(time.findAllElements("temperature").length != 0){
        var date = time.attributes.elementAt(1).value; // This date will be fucked
        print("date: " + date.toString());
        var currentTemp = time.findAllElements("temperature").elementAt(0).attributes.elementAt(2).value;
        print("temp: " + currentTemp.toString());
        
        var currentWind = time.findAllElements("windSpeed").elementAt(0).attributes.elementAt(1).value;
        
        var currentCloud = time.findAllElements("cloudiness").elementAt(0).attributes.elementAt(1).value;
        readRain = true;
      }else{
        if(readRain){
          var date = time.attributes.elementAt(1).value; // This date will be fucked
          var currentRain = time.findAllElements("precipitation").elementAt(0).attributes.elementAt(1).value;
          
          print("rain: " + currentRain.toString());
          
          readRain = false;
        }
      }
      
      
     // print("date: " + time.toString());
     // print("length: " + time.children.length.toString());
      
      
     // print("child: " + children.toString());
      
    //  print("child length: " + children.length.toString());
      
      /*if(temp.toList().length != 0){
        window.alert("temp is");
        var tempString = temp.elementAt(0).attributes.elementAt(2);
        print("temp " + tempString.toString());
      }else{
        
      }*/
    });

    //print("temp.length = " + temperatures.length.toString());
    //print("times.length = " + times.length.toString());
    //print("winds.length = " + winds.length.toString());
    //print("clouds.length = " + clouds.length.toString());
    //print("rains.length = " + rains.length.toString());


    


   /*

    for(int i = 0; i < temperatures.length; i++){
        temps.add(double.parse(temperatures.elementAt(i).attributes.elementAt(2).value));
        windsR.add(double.parse(winds.elementAt(i).attributes.elementAt(1).value));
        cloudsR.add(double.parse(clouds.elementAt(i).attributes.elementAt(1).value));
    }
    int i = 0, rainCounter = 0;
    print("rain");
    while(i < rains.length){
      rainsR.add(double.parse(rains.elementAt(i).attributes.elementAt(1).value)); 
      weatherSymbols.add(weather.elementAt(i).attributes.elementAt(0).value); 

      rainCounter++;
      if(i < 2) i = i + 3;
      else if(i < 250) i = i + 4;
      else i++;
    }
    print("dates");
    for(int i = 0; i < 60; i++){
      dates.add(DateTime.parse(times.elementAt(i*5).attributes.elementAt(2).value));
    }
    print("after dates");
    i = 0;
    while(i < rainsR.length && i < temps.length && i < dates.length){
      print(" ");
      print("==========================");

      print("time: " +dates[i].toString());
      print("temp: " +temps[i].toString());
      print("cloud: " +cloudsR[i].toString());
      print("wind: " +windsR[i].toString());
      print("rain: " +rainsR[i].toString());
      i++;
    }

    print("lengths after: ");
    print("temps  " + temps.length.toString());
    print("rainsR " + rainsR.length.toString());

*/
/*
    int timeCounter = 0;
    int rainCounter = 0;
    for(int i=0; i < temperatures.length ;i++){
      if(i < 58){
          timeCounter = i * 5;
          rainCounter = i * 4;
      }else{
          timeCounter++;
          rainCounter++;
      }

      currentTime = DateTime.parse(times.elementAt(timeCounter).attributes.elementAt(2).value);
      currentRain = double.parse(rains.elementAt(rainCounter).attributes.elementAt(1).value);
      currentWeather = weather.elementAt(rainCounter).attributes.elementAt(0).value;

      currentTemp = double.parse(temperatures.elementAt(i).attributes.elementAt(2).value);
      currentWind = double.parse(winds.elementAt(i).attributes.elementAt(1).value);
      currentCloud = double.parse(clouds.elementAt(i).attributes.elementAt(1).value);
        
      print("===============================");
      print("currentTime: " + currentTime.toString());

      print("currentRain: " + currentRain.toString());
      print("currentTemp: " + currentTemp.toString());
      print("currentWind: " + currentWind.toString());
      print("currentCloud: " + currentCloud.toString());

      
      
      wind = getWind(currentWind);
      cloud = getCloud(currentCloud);
      rain = getRain(currentRain, currentWeather);
            
      timeFormatted = formatter.format(currentTime);      
      
      weatherSets.add(new WeatherSet(currentTemp, cloud, rain, wind, timeFormatted, currentRain, currentWind, currentCloud, currentTime, currentTemp));

    }*/
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

  //TODO: Make a default alternative with a new image
  String getRain(double rainIndex, String currentWeather) {

    String rain;

    if(currentWeather == "Sun" || currentWeather == "LightCloud" || currentWeather == "PartlyCloud"
        || currentWeather == "Cloud")
      rain = "Inget regn"; 
    else if(currentWeather == "Snow")
      rain = "Snö, " + rainIndex.toString() + "mm";
    else if(currentWeather == "Sleet")
          rain = "Snöblandat Regn, " + rainIndex.toString() + "mm";
    else if(currentWeather == "Rain")
      rain = "Regn, "+ rainIndex.toString() + "mm"; 
    else if(currentWeather == "Drizzle")
           rain = "Duggregn, "+ rainIndex.toString() + "mm"; 

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