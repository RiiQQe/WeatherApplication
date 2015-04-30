/*
 * Handles printing of weather data from SMHI and YR (comming soon)
 */



library weatherdata_component;

import 'package:angular/angular.dart';
import 'dart:convert';
import 'dart:async';

import 'dart:html';

import 'package:google_maps/google_maps_places.dart';

import 'package:weatherapplication/component/load_smhi.dart';

@Component(
    selector: 'weather-data', 
    templateUrl: 'packages/weatherapplication/component/weather_data.html',
    cssUrl: 'packages/weatherapplication/component/weather_data.css'    
)
  
    
class WeatherDataComponent {
  
  var input, options;
  
  double latitude, longitude;
  List<WeatherSet> smhiWeatherSets = [];
  LoadSmhi smhiData;
  
  Map<String, bool> cityFilterMap;
  String currentParameter = "temp";
  String currentCity;
  
  //Explanations of the List of images
  //0: mycket regn
  //1: natt
  //2: sol + fåglar
  //3: lite regn
  //4: snö och sol
  //5: snö
  //6: sol + lite moln + fåglar
  //7: sol + moln
  //8: sol + lite moln
  //9: moln
  //10: åska
  List<String> headerImages = ["https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_Z09oUHpjZGlWekU", 
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_d185SXd5UzNkcTA",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_RmJwQmFEajBZQTQ",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_bmZvR3ZQc25kWXM",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_aXpOdlpnN1lva3M",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_c0x5djJmeHpLQ1E",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_NHEzX0xqSUJtMkk",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_TllaS1BKeUpMUk0",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_TF9fdURkZUtLUn",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_YVZadkxGckhFX3M",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_TUFQSlNMdHE3SzA"];
  
  WeatherDataComponent() {
    
    findCoords().then((msg) {
         //Load smhi, then call _loadData
         smhiData = new LoadSmhi(latitude, longitude);
         smhiData.loadData(latitude, longitude).then((msg){
         setHeader();
       });
       _loadData(true);
      
    });
    
  }
  
  void findDevicePosision(){

    findCoords().then((msg){
      
      smhiData.loadData(msg[0], msg[1]);
      
    });
    
  }
  
  //Translate city names to coordinates 
  void nameToCoords(String cityName){
  
    cityName = cityName.toLowerCase();
    
    var url = 'http://nominatim.openstreetmap.org/search?q=$cityName&format=json';
    
    HttpRequest.getString(url).then((String responseText){
      Map citySearch = JSON.decode(responseText);
      
      latitude = double.parse(citySearch[1]["lat"]);
      longitude = double.parse(citySearch[1]["lon"]);


      smhiData.loadData(latitude, longitude).then((msg){
        setHeader();

      });
      _loadData(false);
    });    
  
  }
  
  void searchDropDown(){ 
    
    final input = querySelector("weather-data::shadow #searchTextField") as InputElement;
    
    final autocomplete = new Autocomplete(input);
    
    autocomplete.onPlaceChanged.listen((_) {
     
        final place = autocomplete.place;
        
        nameToCoords(place.name);
      });
  }

  //Load data and call all other functions that does anything with the data
  void _loadData(bool ifFirst) {
    
    //This is used to print current city
    //ifFirst is needed, because it's not needed to find cityName 
    //the second time
    if(ifFirst){
      
      var currentCityUrl = 'http://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';
      
      HttpRequest.getString(currentCityUrl).then((String responseText) {
        Map currentData = JSON.decode(responseText);
        String city;
        if(currentData["address"]["city"] != null) {
           city = currentData["address"]["city"];
        }
        else if(currentData["address"]["village"] != null) {
          city = currentData["address"]["village"];  
        }
        else {
          window.alert("something went wrong");
          city = "Stockholm";
        }
 
      });
    }
  }
  
  //Set header image and parameters depending on currentWeatherSet
  void setHeader()
  {
    String time = smhiData.currentWeatherSet.time.substring(0,2);
    int theTime = int.parse(time);    
    
    if(theTime > 21 || theTime < 05){
      (querySelector('#smhiID') as ImageElement).src = headerImages[1];//natt
    }
   
    else{
      //TODO lägg till vindstyrka och bedöm åskväder och om det är natt
      if(smhiData.currentWeatherSet.rain == "Inget regn"){
        if(smhiData.currentWeatherSet.cloud == "Sol"){
           (querySelector('#smhiID') as ImageElement).src = headerImages[2];//sol + fåglar
        }
        else if(smhiData.currentWeatherSet.cloud == "lite moln"){
          (querySelector('#smhiID') as ImageElement).src = headerImages[6]; //sol + lite moln + fåglar
        }
        else if(smhiData.currentWeatherSet.cloud == "Växlande molnighet"){
          (querySelector('#smhiID') as ImageElement).src = headerImages[7];
        }
        else if(smhiData.currentWeatherSet.cloud == "Mulet"){
          (querySelector('#smhiID') as ImageElement).src = headerImages[9];
        }
      }
    
      if(smhiData.currentWeatherSet.rain == "Duggregn"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[3]; //lite regn
      }
      if(smhiData.currentWeatherSet.rain == "Regn"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[0]; //mycket regn
      }
      if(smhiData.currentWeatherSet.rain == "Snö"){
        if(smhiData.currentWeatherSet.cloud == "Växlande molnighet"){
          (querySelector('#smhiID') as ImageElement).src = headerImages[4];//snö och sol 
        }
        else if(smhiData.currentWeatherSet.cloud == "Mulet"){
          (querySelector('#smhiID') as ImageElement).src = headerImages[5];//snö
        }  
      }   
    }
    //TODO fixa samma för YR
    (querySelector('#yrID') as ImageElement).src = headerImages[2]; //satt till sol så länge
    
    querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.temp.toString();
    querySelector('#headerTextYr').text = smhiData.currentWeatherSet.temp.toString();
    
  }
  
  //Function to set the device's geocoordinates 
  Future findCoords() {

    //Get the location of the device
    return window.navigator.geolocation.getCurrentPosition().then((Geoposition pos) {

      latitude = pos.coords.latitude;
      longitude = pos.coords.longitude;

      var coordinates = [latitude, longitude];

      var currentCityUrl = 'http://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';
      
      HttpRequest.getString(currentCityUrl).then((String responseText) {
        Map currentData = JSON.decode(responseText);

        if(currentData["address"]["city"] != null) {
          currentCity = currentData["address"]["city"];
        }
        else if(currentData["address"]["village"] != null) {
          currentCity = currentData["address"]["village"];  
        }
        else {
          window.alert("something went wrong");
          currentCity = "Stockholm";
        }
        
      });
      
      return coordinates;
      
    }, onError: (error) => printError(error));
  }
  
  //Function that changes the printed values in the timeline
  String getCurrentParameter(WeatherSet ws){
    
    if(currentParameter == 'rain')
      return ws.rain;
    else if(currentParameter == 'temp')
      return "${ws.temp} °C";
    else if(currentParameter == 'wind')
      return ws.wind;
    else if(currentParameter == 'cloud')
      return ws.cloud;
    
    return "Not found";
      
  }
  void printError(error) {
    print("It doesn't work, too bad! Error code: ${error.code}");
  }
}

class WeatherSet {
  double temp;
  String cloud, rain, wind, time;
  
  WeatherSet(this.temp, this.cloud, this.rain, this.wind, this.time);
  
}

