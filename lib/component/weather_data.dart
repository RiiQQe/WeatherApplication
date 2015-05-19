/*
 * Handles printing of weather data from SMHI and YR (comming soon)
 */



library weatherdata_component;

import 'package:angular/angular.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:js' as js;

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
  List<String> headerImages = ["https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkSVNjM1VzdGJxeUk", 
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_d185SXd5UzNkcTA",
                               "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkQTNqLXQ2eVl1cVE",
                               "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkeUk2YmJCM2FnRlk",
                               "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkQUR3UXh3UTJJME0",
                               "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkS3BGbjFFRXZHaEE",
                               "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkeGd0b2Jpc01UU0E",
                               "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkOHhwV3lxM2c0a2s",
                               "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkVTlXenJvVUx0ZzQ",
                               "https://drive.google.com/uc?export=download&id=0B9P7aDjkYEQkdVpoMlV5VDlPRHM",
                               "https://drive.google.com/uc?export=download&id=0ByV6jLc-sJc_TUFQSlNMdHE3SzA"];

  WeatherDataComponent() {
    
    findCoords().then((msg) {
         //Load smhi, then call _loadData
       smhiData = new LoadSmhi();
       yrData = new LoadYr();
       smhiData.loadData(latitude, longitude).then((msg){
         setSmhiHeader();
       });
       yrData.loadData(latitude, longitude).then((msg){
          setYrHeader();
       });
      
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
  
  //dropdown given search results when typing in the text field 
  //Google maps api used
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
    
      if(smhiData.currentWeatherSet.rain.substring(0,4) == "Duggregn"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[3]; //lite regn
      }
      if(smhiData.currentWeatherSet.rain.substring(0,4) == "Regn"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[0]; //mycket regn
      }
      if(smhiData.currentWeatherSet.rain.substring(0,4) == "Snö" && smhiData.currentWeatherSet.cloud == "Mulet"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[5];//snö
      } 
      if(smhiData.currentWeatherSet.rain.substring(0,4) == "Snö" && smhiData.currentWeatherSet.cloud == "Växlande molnighet"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[4];//snö och sol 
      } 
      if(smhiData.currentWeatherSet.rain == "Hagel" && smhiData.currentWeatherSet.cloud == "Mulet"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[5];//snö   
      }
      if(smhiData.currentWeatherSet.rain == "Hagel" && smhiData.currentWeatherSet.cloud == "Växlande molnighet"){
        (querySelector('#smhiID') as ImageElement).src = headerImages[4];//snö och sol 
      }
    }

    querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.temp.toString() + "°C";
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
     
       if(yrData.currentWeatherSet.rain.substring(0,4) == "Duggregn"){
         (querySelector('#yrID') as ImageElement).src = headerImages[3]; //lite regn
       }
       if(yrData.currentWeatherSet.rain.substring(0,4) == "Regn"){
         (querySelector('#yrID') as ImageElement).src = headerImages[0]; //mycket regn
       }
       if(yrData.currentWeatherSet.rain.substring(0,4) == "Snö" && yrData.currentWeatherSet.cloud == "Mulet"){
         (querySelector('#yrID') as ImageElement).src = headerImages[5];//snö
       } 
       if(yrData.currentWeatherSet.rain.substring(0,4) == "Snö" && yrData.currentWeatherSet.cloud == "Växlande molnighet"){
           (querySelector('#yrID') as ImageElement).src = headerImages[4];//snö och sol 
       } 
          
     }

     querySelector('#headerTextYr').text = yrData.currentWeatherSet.temp.toString() + "°C";
   }
  
  //Function to set the device's geocoordinates with the api Nominatim 
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
      
      //set currentCity
      var changePlaceholder = querySelector('weather-data::shadow #searchTextField') as InputElement;
      changePlaceholder.placeholder = currentCity;
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
      querySelector('#headerTextYr').text = yrData.currentWeatherSet.rain.toString();
      querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.rain.toString();
      return ws.rain; 
    }
    else if(currentParameter == 'temp'){
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.add('active');
      querySelector('#headerTextYr').text = yrData.currentWeatherSet.temp.toString() + "°C";
      querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.temp.toString() + "°C";
      return "${ws.temp} °C"; 
    }
    else if(currentParameter == 'wind'){
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.add('active');
      querySelector('#headerTextYr').text = yrData.currentWeatherSet.wind.toString();
      querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.wind.toString();
      return ws.wind; 
    }
    else if(currentParameter == 'cloud'){
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.add('active');
      querySelector('#headerTextYr').text = yrData.currentWeatherSet.cloud.toString();
      querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.cloud.toString();
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
}

class WeatherSet {
  double temp;
  String cloud, rain, wind, time;
  
  WeatherSet(this.temp, this.cloud, this.rain, this.wind, this.time);
  
}

