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
 

  //dropdown
   Dropdown.use();
  
}


