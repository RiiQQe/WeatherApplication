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

///Loads the smhi data and creates a [List] of [WeatherSet]
class LoadYr {
  List<WeatherSet> weatherSets = [];
  var allData;
  WeatherSet currentWeatherSet;
  final DateFormat formatter = new DateFormat('HH:mm');
  
  ///Load function that calls [yr api](http://api.yr.no/weatherapi/locationforecast/1.9/documentation)
  Future loadData(double latitude, double longitude) {
    print("Loading YR-data");

    String latitudeString = latitude.toStringAsPrecision(4);
    String longitudeString = longitude.toStringAsPrecision(4);
    
    //Url to proxy server that calls yr API with passed parameters
    var url = 'http://xn--petrahlin-47a.se/proxy.php?lon=$longitudeString&lat=$latitudeString';
    //url = 'http://xn--petrahlin-47a.se/proxy.php?lon=9.58&lat=60.10';
    

    
    //Call proxy
    return HttpRequest.getString(url).then((String responseText) {

      //Parse response text
      allData = parse(responseText);

      setWeatherParameters();

      currentWeatherSet = weatherSets[1];
        
    }, onError: (error) => printError(error));
  }

  ///Convert all parameters from the [api](http://api.yr.no/weatherapi/locationforecast/1.9/documentation) to [String] and puts them in a [List] of [WeatherSet]
  void setWeatherParameters() {
    var cloud, rain, wind, timeFormatted, currentWeather;
    var currentTemp, currentWind, currentCloud, currentRain;
    DateTime currentTimeTemp, currentTimeRain;
    bool readRain = false;
    var currentSymbol;
    
    weatherSets.clear();
   
  
    List<XmlElement> times = allData.findAllElements("time");
    
    var tempDate, rainDate;
    var boothDone = false;
    //var currentTemp, currentWind, currentCloud, currentRain;
    
    
    times.forEach((time){
      if(time.findAllElements("temperature").length != 0){
        tempDate = time.attributes.elementAt(1).value; 
        currentTimeTemp = DateTime.parse(tempDate);
        //print("date: " + date.toString());
        currentTemp = double.parse(time.findAllElements("temperature").elementAt(0).attributes.elementAt(2).value);
        currentWind = double.parse(time.findAllElements("windSpeed").elementAt(0).attributes.elementAt(1).value);
        currentCloud = double.parse(time.findAllElements("cloudiness").elementAt(0).attributes.elementAt(1).value);

        wind = getWind(currentWind);
        cloud = getCloud(currentCloud);
        rain = getRain(currentRain, currentWeather);
              
        timeFormatted = formatter.format(currentTimeTemp);
        
        readRain = true;
    
      }else{
        if(readRain){
          //rainDate = time.attributes.elementAt(2).value; 
          //currentTimeRain = DateTime.parse(rainDate);
          currentRain = double.parse(time.findAllElements("precipitation").elementAt(0).attributes.elementAt(1).value);
          currentSymbol = time.findAllElements("symbol").elementAt(0).attributes.elementAt(0).value;
          

          rain = getRain(currentRain, currentSymbol);

          readRain = false;
          boothDone = true;
        }
      }
        if(boothDone){
          //To print and see that both works properly
          /*print("====NEW DATE======");
          print("tempDate: " + tempDate.toString());
          print("rainDate: " + rainDate.toString());
          print("======VALUES======");
          print("temp: " + currentTemp.toString());
          print("wind: " + currentWind.toString());
          print("cloud: " + currentCloud.toString());
          print("rain: " + currentRain.toString());*/
          
          weatherSets.add(new WeatherSet(currentTemp, cloud, rain, wind, timeFormatted, currentRain, currentWind, currentCloud, currentTimeTemp, currentTemp));

          boothDone = false;
            
            
        }
    });
    print("loading YR done!");
    
  }
  
  ///Primitive way of translating the cloud parameter from [int] to [String]
  String getCloud(double cloudIndex) {
    String cloud;

    if (cloudIndex == 12.5) cloud = "Sol"; 
    else if (cloudIndex <= 37.5 && cloudIndex > 12.5) cloud = "Lite moln"; 
    else if (cloudIndex < 75 && cloudIndex > 37.5) cloud = "Växlande molnighet"; 
    else cloud = "Mulet";


    return cloud;
  }

  //TODO: Make a default alternative with a new image
  ///Primitive way of translating the rain parameter from [int] to [String]
  String getRain(double rainIndex, String currentWeather) {

    String rain;

    if(currentWeather == "Sun" || currentWeather == "LightCloud" || currentWeather == "PartlyCloud"
        || currentWeather == "Cloud")
      rain = "Inget regn"; 
    else if(currentWeather == "Snow" || currentWeather == "LightSnow" || currentWeather == "HeavySnow")
      rain = "Snö, " + rainIndex.toString() + "mm";
    else if(currentWeather == "LightSnowSun" || currentWeather == "HeaveSnowSun")
      rain = "Sol och snö, " + rainIndex.toString() + "mm";
    else if(currentWeather == "Sleet")
          rain = "Snöblandat Regn";
    else if(currentWeather == "Rain")
      rain = "Regn"; 
    else if(currentWeather == "Drizzle")
           rain = "Duggregn"; 
    else rain = "Odefinierad"; // utveckla denna!

    return rain;
  }

  ///Primitive way of translating the wind parameter from [int] to [String]
  String getWind(double windIndex) {
    String wind = "";

    if (windIndex <= 0.3) wind = "Vindstilla"; 
    else if (windIndex > 0.3 && windIndex <= 3.3) wind = "Svag vind"; 
    else if (windIndex > 3.3 && windIndex <= 13.8) wind = "Blåsigt"; 
    else if (windIndex > 13.8 && windIndex <= 24.4) wind = "Mycket blåsigt"; 
    else if (windIndex > 24.4 && windIndex < 60) wind = "Storm";

    return wind;
  }
  
  ///Primitive way of displaying an error message
  void printError(error) {
    print("It doesn't work, too bad! Error code: ${error.code}");
  }
}