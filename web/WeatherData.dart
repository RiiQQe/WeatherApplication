import 'package:angular/application_factory.dart';
import 'package:di/annotations.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:async';

class WeatherData{
  
  Map allData;
  double latitude, longitude;
  
  WeatherData(this.latitude, this.longitude);
  
  loadData() {
    print("Loading data");
    
    //create URL to SMHI-API with longitude and latitude values
    var url = 'http://opendata-download-metfcst.smhi.se/api/category/pmp1.5g/version/1/geopoint/lat/$latitude/lon/$longitude/data.json';

    //call SMHI-API and catch error if any
    //pass request content to onDataLoaded
    HttpRequest.getString(url).then((String responseText){
     
     //parse response text
     allData = JSON.decode(responseText); 
     
     //debug check if the right data is printed
     print(allData["referenceTime"]); 
     print(allData["timeseries"][0]["ws"]); 
     
     
     //everything we want to do with the data - DO IT HERE
     querySelector("#start-temp").text = "${allData["timeseries"][0]["t"]} grader";
     printData();


  }, onError: (error) => printError(error));

  }
  
  void printError(error){
    print("It doesn't work, too bad! Error code: ${error.code}");
  }
  
  
  printData(){
    print(allData["referenceTime"]);
  }
  
}


