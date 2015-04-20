/*
 * Handles printing of weather data from SMHI and YR (comming soon)
 */



library weatherdata_component;

import 'package:angular/angular.dart';
import 'dart:convert';

import 'dart:html' as dom hide Point, Events;
import 'dart:html';

import 'package:polymer/polymer.dart';

import 'package:google_maps/google_maps.dart';
import 'package:google_maps/google_maps_places.dart';

import 'package:weatherapplication/component/load_smhi.dart';

@Component(
    selector: 'weather-data', 
    templateUrl: 'packages/weatherapplication/component/weather_data.html',
    cssUrl: 'packages/weatherapplication/component/weather_data.css'    
)
  
    
class WeatherDataComponent {
  
  double latitude, longitude;
  List<WeatherSet> smhiWeatherSets = [];
  LoadSmhi smhiData;
  
  City currentCity;
  List<City> allCities = [];
  List<String> cities = ["Norrköping", "Norge", "Rimforsa"];
  Map<String, bool> cityFilterMap;
  String cityName = "";
  
  
  //Constructor saves coorinates to member variables
  WeatherDataComponent() {
    //var coord = findCoords();
    List<double> coord = [58.1378296, 15.6762024];
    latitude = coord[0];
    longitude = coord[1];
    
    smhiData = new LoadSmhi(latitude, longitude);
    
    _loadData(true);

  }
  
  void nameToCoords(String cityName){
  
    currentCity.name = cityName;
  
    cityName = cityName.toLowerCase();
    
    var url = 'http://nominatim.openstreetmap.org/search?q=$cityName&format=json';
    
    HttpRequest.getString(url).then((String responseText){
      Map citySearch = JSON.decode(responseText);
      
      latitude = double.parse(citySearch[1]["lat"]);
      longitude = double.parse(citySearch[1]["lon"]);

      _loadData(false);
    });    
  
  }
  
  void searchDropDown(){ 
    
    final input = querySelector("weather-data::shadow #searchTextField") as InputElement;
    
    final autocomplete = new Autocomplete(input);
    
    final infowindow = new InfoWindow();

    autocomplete.onPlaceChanged.listen((_) {
         infowindow.close();
         final place = autocomplete.place.formattedAddress[0];
         var kalle = autocomplete.place.addressComponents;
         
          
         nameToCoords(place);
         
         print("place " + place.toString());
         
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
        
        currentCity = new City(currentData["address"]["village"]); 
      });
    }
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




