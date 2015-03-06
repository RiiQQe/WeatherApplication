import 'package:angular/application_factory.dart';
import 'package:di/annotations.dart';
import 'dart:html';


//Coordinates
var long, lat;

@Injectable()
class Greeter {
  String name;
}

void main() {
 
  findCoords();
  
  applicationFactory()
      .rootContextType(Greeter)
      .run();
}

void alertError(PositionError error) {
  window.alert("Error occurred. Error code: ${error.code}");
}

//Function to set coordinates
void findCoords(){
  window.navigator.geolocation.getCurrentPosition().then((Geoposition pos){

    lat = pos.coords.latitude;                    //Here the variables are set
    long = pos.coords.longitude;
    
    querySelector("#start-lat").text = "${pos.coords.latitude}";
    querySelector("#start-long").text = "${pos.coords.longitude}";
  }, onError: (error) => alertError(error));
 
}
