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
  

/// Handles printing of weather data from SMHI and YR
class WeatherDataComponent {
    
  double latitude, longitude;
  LoadSmhi smhiData;
  LoadYr yrData;
  
  ///Stores the current [WeatherSet], default is temperature
  String currentParameter = "temp";
  String currentCity;
  var input, options;
  
  bool ifFirst = true;
  bool smhiDone = false, 
      yrDone = false;
    
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
  
  ///Declare [LoadSmhi] and [LoadYr] objects and calls [createWeatherData]
  WeatherDataComponent() {

    smhiData = new LoadSmhi();
    yrData = new LoadYr();
    
    findCoords().then((_) => createWeatherData());
    
  }
  
  ///Calls load functions for [LoadSmhi] and [LoadYr]
  void createWeatherData(){
    yrDone = smhiDone = false;
    smhiData.loadData(latitude, longitude).then((msg) { 
      smhiDone = true;
      setSmhiHeader();
      if(yrDone) {
        setCurrentParameters();
      }

    });
    yrData.loadData(latitude, longitude).then((msg) { 
      yrDone = true;
      setYrHeader();
      if(smhiDone) {
        setCurrentParameters();
      }
      
    });     
    
  }

  void setCurrentParameters(){

    int i = 0;
            
    int smhiLength = smhiData.weatherSets.length;
    int yrLength = yrData.weatherSets.length;
    while(i < smhiLength){
      getCurrentParameter(smhiData.weatherSets[i]);
      i++;
    }
    i = 0;
    while( i < yrLength){
      getCurrentParameter(yrData.weatherSets[i]);
      i++;
    }
    
   //call method in js file that creates the graph
   js.context.callMethod("setParameters", [smhiData.weatherSets, yrData.weatherSets, currentParameter]);

  }
  
  void findDevicePosision(){

    findCoords().then((_) => createWeatherData());
    
  }
  
  ///Translate city names to coordinates 
  void nameToCoords(String cityName){
  
    cityName = cityName.toLowerCase();
    
    var url = 'http://nominatim.openstreetmap.org/search?q=$cityName&format=json';
    
    HttpRequest.getString(url).then((String responseText){
      Map citySearch = JSON.decode(responseText);
      
      latitude = double.parse(citySearch[1]["lat"]);
      longitude = double.parse(citySearch[1]["lon"]);

      

      createWeatherData();
    });    
  
  }

  ///Handles the input of the search drop down
  ///The input is restricted to Sweden
  void searchDropDown(){ 
    
    final input = querySelector("weather-data::shadow #searchTextField") as InputElement;

    AutocompleteOptions ao = new AutocompleteOptions();
        
    ao.$unsafe['ComponentRestrictions'] = new js.JsObject.jsify({
      'country': 'se'
    }); 
    
    //TODO: fixa städer
    //försök att begränsa till städerx
    //ao.$unsafe['GeocoderComponentRestrictions'] = new js.JsObject.jsify({
    //  'locality': ['(cities)']
    //}); 
        
    final autocomplete = new Autocomplete(input, ao);
    
    autocomplete.onPlaceChanged.listen((_) {
     
        final place = autocomplete.place;
        input.value = "";
        input.placeholder = place.name;
        
        nameToCoords(place.name);
      });
  }
  
  ///Set header for smhi depending on currentWeatherSet in [LoadSmhi]
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

   ///Set header for yr depending on currentWeatherSet in [LoadYr]
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
  
  ///Function to set the device's geocoordinates with the api [Nominatim](http://wiki.openstreetmap.org/wiki/Nominatim) 
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
        var changePlaceholder = querySelector('weather-data::shadow #searchTextField') as InputElement;
        if(changePlaceholder != null)
        changePlaceholder.placeholder = currentCity;
        
      });
      
      //set currentCity in search field
      var changePlaceholder = querySelector('weather-data::shadow #searchTextField') as InputElement;
      if(changePlaceholder != null)
      changePlaceholder.placeholder = currentCity;

      return coordinates;
      
    }, onError: (error) {
          longitude = 16.14752;
          latitude = 58.58078;
          var coordinates = [latitude, longitude];
          
          return coordinates;
          
          
        });
       

  }
  //TODO: HERE IS WERE OUR GETTEMP PROBLEM COMES IN TO PLAY, SINCE YRDATA TAKES TO LONG
  ///Function that changes the values in the graph depending on chosen paramter, returns the [currentParameter]
 String getCurrentParameter(WeatherSet ws){
   
    /*if(smhiData.currentWeatherSet == null || yrData.currentWeatherSet == null){
      print("Something went wrong @ here..");
      return "Sorry";
    }*/
    bool notTrue = false;
    if(smhiData.currentWeatherSet == null){
      print("smhi is not loaded yet");
      notTrue = true;
    }

    if(yrData.currentWeatherSet == null){
      print("YR is not loaded yet");
      notTrue = true;
    }
    if(notTrue) return "Sorry";
  
    String value = "Not found";
    if(currentParameter == 'rain'){
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.add('active');
      querySelector('#headerTextYr').text = yrData.currentWeatherSet.rain.toString();
      querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.rain.toString();
      ws.currentParameter = ws.rainValue;
      value = ws.rain; 
    }
    else if(currentParameter == 'temp'){
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.add('active');
      querySelector('#headerTextYr').text = yrData.currentWeatherSet.temp.toString() + "°C";
      querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.temp.toString() + "°C";
      ws.currentParameter = ws.temp;
      value = "${ws.temp} °C"; 
    }
    else if(currentParameter == 'wind'){
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.add('active');
      querySelector('#headerTextYr').text = yrData.currentWeatherSet.wind.toString();
      querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.wind.toString();
      ws.currentParameter = ws.windValue;
      value =  ws.wind; 
    }
    else if(currentParameter == 'cloud'){
      (querySelector('weather-data::shadow #windIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #tempIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #rainIcon') as DivElement).classes.remove('active');
      (querySelector('weather-data::shadow #cloudIcon') as DivElement).classes.add('active');
      querySelector('#headerTextYr').text = yrData.currentWeatherSet.cloud.toString();
      querySelector('#headerTextSmhi').text = smhiData.currentWeatherSet.cloud.toString();
      ws.currentParameter = ws.cloudValue;
      value = ws.cloud; 
    }
    //js.context.callMethod("setParameters", [smhiData.weatherSets, yrData.weatherSets, currentParameter]);

    return value;
      
  }
  
  
  void printError(error) {
    print("It doesn't work, too bad! Error code: ${error.code}");
  }  
}

///Used to create the same weather objects for both smhi and yr
class WeatherSet {
  double temp, rainValue, windValue, cloudValue, currentParameter;
  String cloud, rain, wind, time;
  DateTime date; 
  
  WeatherSet(this.temp, this.cloud, this.rain, this.wind, this.time, this.rainValue, this.windValue, this.cloudValue, this.date, this.currentParameter);
  
}

