//The WeatherAppModule called from the main function binds 
//all components and makes the code run in the right order

library main;

import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';

import 'package:weatherapplication/component/weather_data.dart';

import 'dart:html';


import 'dart:js' as js;

///Binds all components of the app right now it consists of
///[WeatherDataComponent] and [CityFilter]
class WeatherAppModule extends Module {
  WeatherAppModule() {
   
    bind(WeatherDataComponent);
  
  }
}

main() {
  
  applicationFactory().addModule(new WeatherAppModule()).run();
  
  
  removeSplash();
 
  //Dropdown.use();
  
  
}
//TODO: flytta till weatherData
removeSplash(){
  
  var splashscreen = querySelector("#splashscreen");
  splashscreen.style.display = 'none';
  
  var weatherapp = querySelector('#whenloaded');
  weatherapp.style.display = 'block';
  
}

