//The WeatherAppModule called from the main function binds 
//all components and makes the code run in the right order

library main;

import 'package:angular/application_factory.dart';
import 'package:angular/angular.dart';

import 'package:bootjack/bootjack.dart';

import 'dart:html';

import 'package:weatherapplication/component/weather_data.dart';

import 'package:weatherapplication/formatter/time_category_filter.dart';
import 'package:weatherapplication/decorators/image_decorator.dart';


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


    //final input = querySelector('#searchTextField') as InputElement;
    
    //final autocomplete = new Autocomplete(input);
    
    //autocomplete.bindTo('bounds', map);

    //final infowindow = new InfoWindow();
    /*final marker = new Marker(new MarkerOptions()
      ..map = map
    );
   */ 
   /*
   autocomplete.onPlaceChanged.listen((_) {
      infowindow.close();
      final place = autocomplete.place;

      if (place.geometry.viewport != null) {
        map.fitBounds(place.geometry.viewport);
      } else {
        map.center = place.geometry.location;
        map.zoom = 17;  // Why 17? Because it looks good.
      }

      // TODO issue for MarkerImage deprecated
      final icon = new Icon()
        ..url = place.icon
        ..size = new Size(71, 71)
        ..origin = new Point(0, 0)
        ..anchor = new Point(17, 34)
        ..scaledSize = new Size(35, 35);
      marker.icon = icon;
      marker.position = place.geometry.location;

      String address = '';
      if (place.addressComponents != null) {
        address = [
          (place.addressComponents[0] != null && place.addressComponents[0].shortName != null ? place.addressComponents[0].shortName : ''),
          (place.addressComponents[1] != null && place.addressComponents[1].shortName != null ? place.addressComponents[1].shortName : ''),
          (place.addressComponents[2] != null && place.addressComponents[2].shortName != null ? place.addressComponents[2].shortName : '')
        ].join(' ');
      }

      infowindow.content = '<div><strong>${place.name}</strong><br>${address}';
      infowindow.open(map, marker);
    });
    */
    // Sets a listener on a radio button to change the filter type on Places
    // Autocomplete.
    /*
    void setupClickListener(id, types) {
      final radioButton = querySelector('#${id}');
      event.addDomListener(radioButton, 'click', (_) {
        autocomplete.types = types;
      });
    }
    
    setupClickListener('changetype-all', []);
    setupClickListener('changetype-establishment', ['establishment']);
    setupClickListener('changetype-geocode', ['geocode']);
    */

}
sfunction(){
  print("here i am");
}

