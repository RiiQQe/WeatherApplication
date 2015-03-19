library main;

import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';
import 'dart:html';
import 'package:bootjack/bootjack.dart';

import 'package:weatherapplication/component/WeatherData.dart';

class WeatherAppModule extends Module {
  WeatherAppModule() {
    bind(WeatherDataComponent);
  }
}

main() {
 
  applicationFactory()
    .addModule(new WeatherAppModule())
      .run();
 
  //Default coordinates values
  var coordinates = [58.00, 16.00];
  //Uncomment when compilated to JavaScript to get the right coordinates
  //coordinates  = findCoords();
  
 
  WeatherDataComponent currentWeather = new WeatherDataComponent(coordinates[0], coordinates[1]);
  currentWeather.loadData();

  //dropdown
   Dropdown.use();
  
}

void printError(error){
  print("It doesn't work, too bad! Error code: ${error.code}");
}

//Function to set the device's geocoordinates
findCoords(){
  
  //Get the location of the device
  window.navigator.geolocation.getCurrentPosition().then((Geoposition pos){

  double lat = pos.coords.latitude;                    
  double long = pos.coords.longitude;
   
  var coordinates = [lat, long];
  return coordinates;
    
  }, onError: (error) => printError(error));
 
}


