/* 
 * Handles reading from SMHI, and stores the weatherparameters 
 * in a List containing WeatherSets.
 */

library load_smhi;


import 'dart:html';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:weatherapplication/component/weather_data.dart';

import 'dart:async';

///Loads the smhi data and creates a [List] of [WeatherSet]
class LoadSmhi {
  List<WeatherSet> weatherSets = [];
  Map allData;
  WeatherSet currentWeatherSet;
  final DateFormat formatter = new DateFormat('HH.mm');//HH:mm d/M
 
  ///Load function that calls [smhi api](http://www.smhi.se/klimatdata/oppna-data/meteorologiska-data)
  Future loadData(double latitude, double longitude) {
    print("Loading SMHI-data");
    String latitudeString = latitude.toStringAsPrecision(6);
    String longitudeString = longitude.toStringAsPrecision(6);

    //Create URL to SMHI-API with longitude and latitude values
    var url = 'http://opendata-download-metfcst.smhi.se/api/category/pmp1.5g/version/1/geopoint/lat/$latitudeString/lon/$longitudeString/data.json';

    //Call SMHI-API
    return HttpRequest.getString(url).then((String responseText) {

      //Parse response text
      allData = JSON.decode(responseText);

      setWeatherParameters();

      int timeIndex = getTimeIndex() + 1;
      currentWeatherSet = weatherSets[timeIndex];
        
      print("Loading SMHI done");
      
    }, onError: (error) => printError(error));

  }
  
  ///Returns the index of the Map generated in [loadData] that correspond to the weather right now
  int getTimeIndex() {
    DateTime referenceTime = DateTime.parse(allData["referenceTime"]);
    DateTime now = new DateTime.now();

    //Difference in hours = timeIndex for current time in allData
    Duration difference = now.difference(referenceTime);
    return difference.inHours;
  }

  ///Convert all parameters from the [api](http://www.smhi.se/klimatdata/oppna-data/meteorologiska-data) to [String] and puts them in a [List] of [WeatherSet]
  void setWeatherParameters() {
    String cloud, rain, wind, timeFormatted;
    int cloudIndex, rainIndex;
    double windIndex, currentTemp, rainValue, cloudValue;
    DateTime currentTime;

    weatherSets.clear();


    for (int i = 0; i < allData["timeseries"].length; i++) {
          
          //Get all parameters to initialize a new WeatherSet
          currentTemp = allData["timeseries"][i]["t"];
          currentTime = DateTime.parse(allData["timeseries"][i]["validTime"]);
          //category = getCategory(currentTime);
          timeFormatted = formatter.format(currentTime);

          cloudIndex = allData["timeseries"][i]["tcc"];
          rainIndex = allData["timeseries"][i]["pcat"];
          windIndex = allData["timeseries"][i]["gust"];
          rainValue = allData["timeseries"][i]["pit"];
          cloudValue = (cloudIndex/8)*10;
          
          //Get description of parameters from parameter index
          cloud = getCloud(cloudIndex);
          rain = getRain(rainIndex, i);
          wind = getWind(windIndex);
          

          //Add new WeatherSet to the list
          weatherSets.add(new WeatherSet(currentTemp, cloud, rain, wind, timeFormatted, rainValue, windIndex, cloudValue, currentTime, currentTemp));

      }
    
  }

  ///Primitive way of translating the cloud parameter from [int] to [String]
  String getCloud(int cloudIndex) {
    String cloud;

    if (cloudIndex <= 1) cloud = "Sol"; 
    else if (cloudIndex <= 3 && cloudIndex > 1) cloud = "Lite moln"; 
    else if (cloudIndex <= 6 && cloudIndex > 3) cloud = "Växlande molnighet"; 
    else cloud = "Mulet";
    

    return cloud;
  }


  ///Primitive way of translating the rain parameter from [int] to [String]
  String getRain(int rainIndex, int timeIndex) {

    String rain;
    double howMuch;

    switch (rainIndex) {
      case 0:
        rain = "Inget regn";
        break;
      case 1:
        howMuch = allData["timeseries"][timeIndex]["pis"];
        rain = "Snö";
        break;
      case 2:
        howMuch = allData["timeseries"][timeIndex]["pis"] + allData["timeseries"][timeIndex]["pit"];
        rain = "Snöblandat regn";
        break;
      case 3:
        howMuch = allData["timeseries"][timeIndex]["pit"];
        rain = "Regn";
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


  ///Primitive way of translating the wind parameter from [int] to [String]
  String getWind(double windIndex) {
    String wind = "";

    if (windIndex <= 0.3) wind = "Vindstilla"; else if (windIndex > 0.3 && windIndex <= 3.3) wind = "Svag vind"; else if (windIndex > 3.3 && windIndex <= 13.8) wind = "Blåsigt"; else if (windIndex > 13.8 && windIndex <= 24.4) wind = "Mycket blåsigt"; else if (windIndex > 24.4 && windIndex < 60) wind = "Storm";

    return wind;
  }

  ///Primitive way of displaying an error message
  void printError(error) {
    setWeatherParameters();
    //print("It doesn't work, too bad! Error code: " + error); // ${error.code}");
    
  }
}
