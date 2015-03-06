import 'package:angular/application_factory.dart';
import 'package:di/annotations.dart';
import 'dart:html';
import 'dart:convert';


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
  
  loadData(coordinates[0], coordinates[1]);

}

void printError(error){
  print("It doesn't work, too bad! Error code: ${error.code}");
}

//Function to set the device's geocoordinates
findCoords(){
  window.navigator.geolocation.getCurrentPosition().then((Geoposition pos){

    double lat = pos.coords.latitude;                    //Here the variables are set
    double long = pos.coords.longitude;
    
    querySelector("#start-lat").text = "${pos.coords.latitude}";
    querySelector("#start-long").text = "${pos.coords.longitude}";
    print('hejhej');
    var coordinates = [lat, long];
    return coordinates;
    
  }, onError: (error) => printError(error));
 
}

loadData(double lat, double lon) {
  print("Loading data");
  
  //create URL to SMHI-API with longitude and latitude values
  var url = 'http://opendata-download-metfcst.smhi.se/api/category/pmp1.5g/version/1/geopoint/lat/$lat/lon/$lon/data.json';

  //call SMHI-API and catch error if any
  //pass request content to onDataLoaded
  var request = HttpRequest.getString(url).then(onDataLoaded); //catchError() missing
}

onDataLoaded(String responseText) {
   
   //parse response text
   Map data = JSON.decode(responseText); 
   
   //debug check if the right data is printed
   print(data["timeseries"][0]["pis"]); 
   print(data["timeseries"][0]["ws"]); 
   
}

