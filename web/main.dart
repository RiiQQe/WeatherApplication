//The WeatherAppModule called from the main function binds 
//all components and makes the code run in the right order

library main;

import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';
import 'dart:html';
import 'package:bootjack/bootjack.dart';

import 'package:weatherapplication/component/weather_data.dart';

import 'package:weatherapplication/formatter/time_category_filter.dart';
import 'package:weatherapplication/decorators/image_decorator.dart';

import 'dart:convert';

///Binds all components of the app right now it consists of
///[WeatherDataComponent] and [CityFilter]
class WeatherAppModule extends Module {
  WeatherAppModule() {
    
    bind(WeatherDataComponent);
    bind(CityFilter);
    bind(ImageDecorator);
  
  }
}

main() {

    applicationFactory().addModule(new WeatherAppModule()).run();

  //dropdown
  Dropdown.use();

}

