library WeatherData_component;

import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';
import 'package:di/annotations.dart';
import 'package:collection/collection.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:async';

@Component(
    selector: 'weather-data', 
    templateUrl: 'packages/weatherapplication/component/WeatherData.html')
  
    
class WeatherDataComponent {

  Map allData;
  double latitude, longitude, currentTemp;
  List<WeatherSet> weatherSets = [];
  List<String> categories = ["Idag", "Imorgon", "Kommande veckan"];
  Map<String, bool> categoryFilterMap;
  WeatherSet currentWeatherSet; 

  //Constructor saves coorinates to member variables
  WeatherDataComponent() {
    //var coord = findCoords();
    List<double> coord = [58.0, 16.0];
    latitude = coord[0];
    longitude = coord[1];
    _loadData();
  }
  

  //Load data and call all other functions that does anything with the data
  void _loadData() {
    print("Loading data");

    //Create URL to SMHI-API with longitude and latitude values
    var url = 'http://opendata-download-metfcst.smhi.se/api/category/pmp1.5g/version/1/geopoint/lat/$latitude/lon/$longitude/data.json';

    //Call SMHI-API
    HttpRequest.getString(url).then((String responseText) {

      //Parse response text
      allData = JSON.decode(responseText);
 
      setWeatherParameters();
      
      int timeIndex = getTimeIndex();
      currentWeatherSet = weatherSets[timeIndex];
     
      //Initilize categoryFilterMap with keys:categories and values:bools
      List<bool> defaultBools = [false, false, false];
      categoryFilterMap = new Map.fromIterables(categories, defaultBools);

    }, onError: (error) => printError(error));

  }

  void printError(error) {
    print("It doesn't work, too bad! Hej code: ${error.code}");
  }

  void setWeatherParameters() {
    String cloud, rain, wind, category;
    int cloudIndex, rainIndex;
    double windIndex, currentTemp;
    DateTime currentTime;

    for (int i = 0; i < allData["timeseries"].length; i++) {
      //Get all parameters to initialize a new WeatherSet
      currentTemp = allData["timeseries"][i]["t"];
      currentTime = DateTime.parse(allData["timeseries"][i]["validTime"]);
      category = getCategory(currentTime);
      
      cloudIndex = allData["timeseries"][i]["tcc"];
      rainIndex = allData["timeseries"][i]["pcat"];
      windIndex = allData["timeseries"][i]["gust"];
     

      //Get description of parameters from parameter index
      cloud = getCloud(cloudIndex);
      rain = getRain(rainIndex, i);
      wind = getWind(windIndex);

      //Add new WeatherSet to the list weatherSets
      weatherSets.add(new WeatherSet(currentTemp, cloud, rain, wind, currentTime, category));
    }
    
  }
  
  int getTimeIndex(){
     DateTime referenceTime = DateTime.parse(allData["referenceTime"]);
     DateTime now = new DateTime.now();
     
     //Difference in hours = timeIndex for current time in allData
     Duration difference = now.difference(referenceTime);
     return difference.inHours;
  }

  String getCloud(int cloudIndex) {
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

    if (windIndex <= 0.3)
      wind = "Vindstilla"; 
    else if (windIndex > 0.3 && windIndex <= 3.3) 
      wind = "Svag vind"; 
    else if (windIndex > 3.3 && windIndex <= 13.8) 
      wind = "Blåsigt"; 
    else if (windIndex > 13.8 && windIndex <= 24.4) 
      wind = "Mycket blåsigt"; 
    else if (windIndex > 24.4 && windIndex < 60) 
      wind = "Storm";

    return wind;
  }

  //Function to set the device's geocoordinates
  findCoords() {

    //Get the location of the device
    window.navigator.geolocation.getCurrentPosition().then((Geoposition pos) {

      double lat = pos.coords.latitude;
      double long = pos.coords.longitude;

      var coordinates = [lat, long];
      return coordinates;

    }, onError: (error) => printError(error));

  }
  
  
  String getCategory(DateTime currentTime){
    String category;
    DateTime now = new DateTime.now();
    Duration difference = currentTime.difference(now);
    
    //Set category so that the data can be filterd
    if(difference.inDays == 0)
      category = categories[0];     //Idag
    else if(difference.inDays == 1)
      category = categories[1];     //Imorgon
    else if(difference.inDays >= 1)
      category = categories[2];     //Resterande vecka
    
    return category;
  }
}

class WeatherSet {
  double temp;
  String cloud, rain, wind, category;
  DateTime time;

  WeatherSet(this.temp, this.cloud, this.rain, this.wind, this.time, this.category);
}




