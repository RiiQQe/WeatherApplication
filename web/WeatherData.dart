import 'package:angular/application_factory.dart';
import 'package:di/annotations.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:async';

class WeatherData{
  
  Map allData;
  double latitude, longitude;
  
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
     
     //Debug check if the right data is printed
     print(allData["referenceTime"]); 
     print(allData["timeseries"][0]["ws"]); 
     
     
     //Everything we want to do with the data ---- DO IT HERE ----
     querySelector("#start-temp").text = "${allData["timeseries"][0]["t"]} grader";
     printData();


  }, onError: (error) => printError(error));

  }
  
  void printError(error){
    print("It doesn't work, too bad! Error code: ${error.code}");
  }
  
  //Testfunction 
  printData(){
    print(allData["referenceTime"]);
  }
  
}


