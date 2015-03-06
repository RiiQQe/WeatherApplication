import 'package:angular/application_factory.dart';
import 'package:di/annotations.dart';
import 'dart:html';
import 'dart:convert';
import 'dart:async';

import 'WeatherData.dart';

@Injectable()
class Greeter {
  String name;
}

main() {
 
  applicationFactory()
      .rootContextType(Greeter)
      .run();
  
  var coordinates = [58.34, 16.00];
  //Uncomment when compilated to JavaScript
  //coordinates  = findCoords();
  
  WeatherData currentWeather = new WeatherData(coordinates[0], coordinates[1]);
  currentWeather.loadData();
  
}

void printError(error){
  print("It doesn't work, too bad! Error code: ${error.code}");
}

//Function to set the device's geocoordinates
findCoords(){
  window.navigator.geolocation.getCurrentPosition().then((Geoposition pos){

  double lat = pos.coords.latitude;                    //Here the variables are set
  double long = pos.coords.longitude;
   
  var coordinates = [lat, long];
  return coordinates;
    
  }, onError: (error) => printError(error));
 
}


