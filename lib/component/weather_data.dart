/*
 * Handles printing of weather data from SMHI and YR (comming soon)
 */



library weatherdata_component;

import 'package:angular/angular.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:js' as js;
import 'dart:math';

import 'dart:html';

import 'package:google_maps/google_maps_places.dart';

import 'package:weatherapplication/component/load_smhi.dart';
import 'package:weatherapplication/component/load_yr.dart';


@Component(
    selector: 'weather-data', 
    templateUrl: 'packages/weatherapplication/component/weather_data.html',
    cssUrl: 'packages/weatherapplication/component/weather_data.css'    
)
  
    
class WeatherDataComponent {
    
  double latitude, longitude;
  List<WeatherSet> smhiWeatherSets = [];
  LoadSmhi smhiData;
  LoadYr yrData;
  
  Map<String, bool> cityFilterMap;
  String currentParameter = "temp";
  String currentCity;
  var input, options;
  
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
       smhiData = new LoadSmhi();
       yrData = new LoadYr();
       smhiData.loadData(latitude, longitude).then((msg){
         setSmhiHeader();
         //drawCanvas();
       });
       yrData.loadData(latitude, longitude).then((msg){
          setYrHeader();
          drawCanvas();
       });
       
       //drawCanvas();
      
    });
    
  }
  
  void findDevicePosision(){

    findCoords().then((coords){

      smhiData.loadData(coords[0], coords[1]);
      yrData.loadData(coords[0], coords[1]);
      
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
        setSmhiHeader();
      });
      
      yrData.loadData(latitude, longitude).then((msg){
        setYrHeader();
      });
    });    
  
  }
  
  void searchDropDown(){ 
    
    final input = querySelector("weather-data::shadow #searchTextField") as InputElement;
    
    AutocompleteOptions ao = new AutocompleteOptions();
        
    ao.$unsafe['ComponentRestrictions'] = new js.JsObject.jsify({
      'country': 'se'
    });
        
        
    final autocomplete = new Autocomplete(input, ao);
    
    autocomplete.onPlaceChanged.listen((_) {
     
        final place = autocomplete.place;
        
        nameToCoords(place.name);
      });
  }

  
  //Set header image and parameters depending on currentWeatherSet
  void setSmhiHeader()
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
        else if(smhiData.currentWeatherSet.cloud == "Lite moln"){
          (querySelector('#smhiID') as ImageElement).src = headerImages[6]; //sol + lite moln + fåglar
        }
        else if(smhiData.currentWeatherSet.cloud == "Växlande molnighet"){
          (querySelector('#smhiID') as ImageElement).src = headerImages[7];
        }
        else if(smhiData.currentWeatherSet.cloud == "Mulet"){
          (querySelector('#smhiID') as ImageElement).src = headerImages[9]; //moln
        }
      }
    
      if(smhiData.currentWeatherSet.rain == "Duggregn"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[3]; //lite regn
      }
      if(smhiData.currentWeatherSet.rain.substring(0,4) == "Regn"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[0]; //mycket regn
      }
      if(smhiData.currentWeatherSet.rain == "Snö" && smhiData.currentWeatherSet.cloud == "Mulet"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[5];//snö
      } 
      if(smhiData.currentWeatherSet.rain == "Snö" && smhiData.currentWeatherSet.cloud == "Växlande molnighet"){
          (querySelector('#smhiID') as ImageElement).src = headerImages[4];//snö och sol 
      } 
         
    }

    querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.temp.toString();

  }
  
  //Set header image and parameters depending on currentWeatherSet
   void setYrHeader()
   {
     String time = yrData.currentWeatherSet.time.substring(0,2);
     int theTime = int.parse(time);
     
     if(theTime > 21 || theTime < 05){
       (querySelector('#yrID') as ImageElement).src = headerImages[1];//natt
     }
    
     else{
       //TODO lägg till vindstyrka och bedöm åskväder och om det är natt
       if(yrData.currentWeatherSet.rain == "Inget regn"){
         if(yrData.currentWeatherSet.cloud == "Sol"){
            (querySelector('#yrID') as ImageElement).src = headerImages[2];//sol + fåglar
         }
         else if(yrData.currentWeatherSet.cloud == "Lite moln"){
           (querySelector('#yrID') as ImageElement).src = headerImages[6]; //sol + lite moln + fåglar
         }
         else if(yrData.currentWeatherSet.cloud == "Växlande molnighet"){
           (querySelector('#yrID') as ImageElement).src = headerImages[7]; 
         }
         else if(yrData.currentWeatherSet.cloud == "Mulet"){
           (querySelector('#yrID') as ImageElement).src = headerImages[9]; //moln
         }
       }
     
       if(yrData.currentWeatherSet.rain == "Duggregn"){
         (querySelector('#yrID') as ImageElement).src = headerImages[3]; //lite regn
       }
       if(yrData.currentWeatherSet.rain.substring(0,4) == "Regn"){
         (querySelector('#yrID') as ImageElement).src = headerImages[0]; //mycket regn
       }
       if(yrData.currentWeatherSet.rain == "Snö" && yrData.currentWeatherSet.cloud == "Mulet"){
         (querySelector('#yrID') as ImageElement).src = headerImages[5];//snö
       } 
       if(yrData.currentWeatherSet.rain == "Snö" && yrData.currentWeatherSet.cloud == "Växlande molnighet"){
           (querySelector('#yrID') as ImageElement).src = headerImages[4];//snö och sol 
       } 
          
     }

     querySelector('#headerTextYr').text = yrData.currentWeatherSet.temp.toString();
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
    
    if(currentParameter == 'rain'){
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.add('active');
      return ws.rain; 
    }
    else if(currentParameter == 'temp'){
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.add('active');
      return "${ws.temp} °C"; 
    }
    else if(currentParameter == 'wind'){
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.add('active');
      return ws.wind; 
    }
    else if(currentParameter == 'cloud'){
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.add('active');
      return ws.cloud; 
    }
    
    return "Not found";
      
  }
  
  String isRainClicked(){
    print("IsrainChecked??   " + currentParameter);
    if(currentParameter == 'rain')
      return 'clicked';
    else
      return 'notClicked';
  }
  
  void printError(error) {
    print("It doesn't work, too bad! Error code: ${error.code}");
  }
  
  
  void drawCanvas(){
    
    CanvasElement canvas = document.querySelector('#today');
    CanvasElement canvas1 = document.querySelector('#today');
    var circle_smhi = canvas.getContext('2d');
    var circle_yr = canvas1.getContext('2d');
    
    String temp_smhi = smhiData.currentWeatherSet.temp.toString();
    String temp_yr = yrData.currentWeatherSet.temp.toString();
    print(temp_smhi);
    print(temp_yr);
    
    var centerX = canvas.width / 2;
    var centerY = canvas.height / 2;
    var radius = 100;
    var radius1 = 70;
    
    circle_smhi.beginPath();
    circle_smhi.arc(centerX, centerY, radius, 0, 2 * PI, false);
    circle_smhi.fillStyle = 'green';
    circle_smhi.fill();
    //circle_smhi.strokeStyle = '#003300';
    circle_smhi.stroke(); 
    
    circle_yr.beginPath();
    circle_yr.arc(centerX, centerY, radius1, 0, 2 * PI, false);
    circle_yr.fillStyle = 'red';
    circle_yr.fill();
    //circle_yr.strokeStyle = '#003300';
    circle_yr.stroke(); 
    
  }
}

class WeatherSet {
  double temp;
  String cloud, rain, wind, time;
  
  WeatherSet(this.temp, this.cloud, this.rain, this.wind, this.time);
  
}

