import 'package:angular/application_factory.dart';
import 'package:di/annotations.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:async';

class WeatherData{
  
  Map allData;
  double latitude, longitude;
  int timeIndex;
  
  //Constructor saves coorinates to member variables
  WeatherData(this.latitude, this.longitude);
  
  //Load data and call all other functions that does anything with the data
  loadData() {
    print("Loading data");
    
    //Create URL to SMHI-API with longitude and latitude values
    var url = 'http://opendata-download-metfcst.smhi.se/api/category/pmp1.5g/version/1/geopoint/lat/$latitude/lon/$longitude/data.json';

    //Call SMHI-API 
    HttpRequest.getString(url).then((String responseText){
     
     //Parse response text
     allData = JSON.decode(responseText); 
     
     DateTime referenceTime = DateTime.parse(allData["referenceTime"]);
     DateTime now = new DateTime.now();
     
     //Difference in hours = timeIndex for current time in allData
     Duration difference = now.difference(referenceTime);
     timeIndex = difference.inHours;
     
     //Get parameters or parameter index
     double currentTemp = allData["timeseries"][timeIndex]["t"];
     int cloudIndex = allData["timeseries"][timeIndex]["tcc"];
     int rainIndex = allData["timeseries"][timeIndex]["pcat"];
     double windIndex = allData["timeseries"][timeIndex]["gust"];
     
     //Get description of parameters from parameter index
     String cloud = getCloud(cloudIndex);
     String rain = getRain(rainIndex);
     String wind = getWind(windIndex);
     
     //Everything we want to do with the data ---- DO IT HERE ----
     querySelector("#start-temp").text = "$currentTemp grader";
     querySelector("#start-cloud").text = cloud;
     querySelector("#start-rain").text = rain;
     querySelector("#start-wind").text = wind;

  }, onError: (error) => printError(error));

  }
  
  void printError(error){
    print("It doesn't work, too bad! Error code: ${error.code}");
  }
  
  String getCloud(int cloudIndex){
     String cloud;
     
     if(cloudIndex < 3)
       cloud = "Lite moln";
     else if(cloudIndex < 6 && cloudIndex > 2)
       cloud = "Växlande molnighet";
     else
       cloud = "Mulet";
       
    return cloud;
  }
  
  String getRain(int rainIndex){
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
  
  String getWind(double windIndex){
    String wind = "";
    
    if(windIndex <= 0.3)
      wind = "Vindstilla";
    else if(windIndex > 0.3 && windIndex <= 3.3)
      wind = "Svag vind";
    else if(windIndex > 3.3 && windIndex <= 13.8)
          wind = "Blåsigt";
    else if(windIndex > 13.8 && windIndex <= 24.4)
          wind = "Mycket blåsigt";
    else if(windIndex > 24.4 && windIndex < 60)
          wind = "Storm";
    
    return wind;
  }
  
 
  
  
}



