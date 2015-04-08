//The WeatherAppModule called from the main function binds 
//all components and makes the code run in the right order

library main;

import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';
import 'dart:html';
import 'package:bootjack/bootjack.dart';

import 'package:weatherapplication/component/weather_data_component.dart';
import 'package:weatherapplication/formatter/time_category_filter.dart';

///Binds all components of the app right now it consists of
///[WeatherDataComponent] and [CategoryFilter]
class WeatherAppModule extends Module {
  WeatherAppModule() {
    bind(WeatherDataComponent);
    bind(CategoryFilter);
  }
}

main() {

  applicationFactory().addModule(new WeatherAppModule()).run();

  //dropdown
  Dropdown.use();

}

