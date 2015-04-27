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
  
  City currentCity;
  List<City> allCities = [];
  List<String> cities = ["Norrköping", "Norge", "Rimforsa"];
//  Map<String, bool> cityFilterMap;
  String cityName = "";
  
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
  
  //Constructor saves coorinates to member variables
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
  
  void sfunction(){

    findCoords().then((msg){
      
      smhiData.loadData(msg[0], msg[1]);
      
    });
    
  }
  
  void nameToCoords(String cityName){
  
    currentCity.name = cityName;
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
    
    String latitudeString = latitude.toStringAsPrecision(6);
    String longitudeString = longitude.toStringAsPrecision(6);
    
    //This is used to print current city
    //ifFirst is needed, because it's not needed to find cityName 
    //the second time
    if(ifFirst){

      for(int i = 0; i < 3; i++)
        allCities.add(new City(cities[i]));
      
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
        
        currentCity = new City(city); 
      });
    }
  }
    
  void setHeader()
  {
    String temp = smhiData.currentWeatherSet.time.substring(0,2);
    int theTime = int.parse(temp);
    print("tid:");
    print(theTime);
    
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
          currentCity.name = currentData["address"]["city"];
        }
        else if(currentData["address"]["village"] != null) {
          currentCity.name = currentData["address"]["village"];  
        }
        else {
          window.alert("something went wrong");
          currentCity.name = "Stockholm";
        }
        
      });
      
      return coordinates;
      
    }, onError: (error) => printError(error));
  }
  
  
  //Used by the filtering function
  String getCity(String typedCity){
    String city;
    
    //Set category so that the data can be filterd
    if(typedCity == "Norrköping")
      city = cities[0];     //Norrköping
    else if(typedCity == "Rimforsa")
      city = cities[1];     //Rimforsa
    else if(typedCity == "Lund")
      city = cities[2];     //Lund
    
    return city;
  }
  
//  //Primitive way of displaying lower Timeline.
//  void drawCanvas(){
//    
//    DateTime now = new DateTime.now();
//    
//    int hour = now.hour;
//    int minute = now.minute;
//    
//    String min;
//    
//    //Just so 17:9 -> 17:09 
//    min = (minute < 10 ? "0" + minute.toString() : minute.toString());
//    
//    CanvasElement can = querySelector("#myCanvas");
//    var ctx = can.getContext("2d");
//    
//    double height = can.getBoundingClientRect().height;
//    double width = can.getBoundingClientRect().width;
//    
//    //Draw timeline
//    ctx.beginPath();
//        ctx.moveTo(100,85);
//        ctx.lineTo(100, 1000);
//        ctx.lineWidth = 10;
//        ctx.stroke();
//    ctx.font = "15px serif";
//    ctx.fillText("$hour:$min", 85,40);
//    
//    ImageElement img = new ImageElement(src: 'http://www.i2symbol.com/images/symbols/weather/white_sun_with_rays_u263C_icon_256x256.png');
//    
//    img.onLoad.listen( (value) => /*ctx.drawImage(img, 0, 0)*/ ctx.drawImageScaled(img, 0, 0, 100, 100) );
//        for(int i=1; i < 10; i++){
//              
//              hour++;;
//              
//              if(hour > 24) hour = 0;
//              //Set text on canvas to hour:min at pos x,y
//              //fillText("String", pos x, pos y)
//              ctx.fillText("$hour:$min", 10, i * 100);
//              //ctx.drawImage(img, 0,i * 50);
//             
//              ctx.fillText("${weatherSets[i].temp} °C", 150,i *  100);
//              
//        }
//  }
  
  void printError(error) {
    print("It doesn't work, too bad! Error code: ${error.code}");
  }
}

class WeatherSet {
  double temp;
  String cloud, rain, wind, time;
  
  WeatherSet(this.temp, this.cloud, this.rain, this.wind, this.time);
  
}

class City {
  String name;
  
  City(this.name);
}
