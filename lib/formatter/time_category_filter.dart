//Filter used when printing the weather data
//depending on time.

library time_category_filter;

import 'package:angular/angular.dart';


@Formatter(name: 'cityfilter')

///Filter [WeatherSet]s depending on categories checked in the checkboxes.
class CityFilter {
  
  List call(weatherSets, cityFilterMap) {
    if (weatherSets is Iterable && cityFilterMap is Map) {
      //If there is nothing checked, treat it as "everything is checked".
      bool nothingChecked = cityFilterMap.values.every((isChecked) => !isChecked);
      return nothingChecked
          ? weatherSets.toList()
          : weatherSets.where((i) => cityFilterMap[i.city] == true).toList();
    }
    return const [];
  }

}