import 'package:angular/application_factory.dart';
import 'package:di/annotations.dart';

import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'package:bootjack/bootjack.dart';
import 'WeatherData.dart';



@Injectable()
class Greeter {
  String name;
}

main() {
  
  applicationFactory()
      .rootContextType(Greeter)
      .run();
 
  //Default coordinates values
  var coordinates = [58.00, 16.00];
  //Uncomment when compilated to JavaScript to get the right coordinates
  //coordinates  = findCoords();
  
  drawCanvas();
  
  WeatherData currentWeather = new WeatherData(coordinates[0], coordinates[1]);
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

drawCanvas(){
  
  DateTime now = new DateTime.now();
    
  int hour = now.hour;
  int minute = now.minute;
  
  String min;
  
  //Just so 17:9 -> 17:09 
  min = (minute < 10 ? "0"+minute.toString() : minute.toString());
  
  var canvas = querySelector("#myCanvas");
  var ctx = canvas.getContext("2d");
  
  var img = new ImageElement(src : "/pic/sunncloud.png");
  ctx.drawImage(img, 100,100);
  
  ctx.beginPath();
    ctx.moveTo(100,0);
    ctx.lineTo(100, 1000);
    ctx.lineWidth = 10;
    ctx.stroke();
    
  ctx.fillText("$hour:$min", 10,0);
   
    
    for(int i=1; i < 10; i++){
          ctx.font = "15px serif";
          
          if(hour > 24) hour = 0;
      
          ctx.fillText("$hour:$min", 10,i * 100);
      //    ctx.drawImage(img, 0,i * 50);
          
          hour++;;
    }
    
    
     //img.src = "/pic/sunncloud.png";
}


