library main;

import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';
import 'dart:html';
import 'package:bootjack/bootjack.dart';

import 'package:weatherapplication/component/weather_data_component.dart';
import 'package:weatherapplication/formatter/time_category_filter.dart';

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

