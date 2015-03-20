library time_category_filter;

import 'package:angular/angular.dart';


@Formatter(name: 'categoryfilter')
//Filter WeatherSets depending on categories checked in the checkboxes
class CategoryFilter {
  List call(weatherSets, categoryFilterMap) {
    if (weatherSets is Iterable && categoryFilterMap is Map) {
      // If there is nothing checked, treat it as "everything is checked"
      bool nothingChecked = categoryFilterMap.values.every((isChecked) => !isChecked);
      return nothingChecked
          ? weatherSets.toList()
          : weatherSets.where((i) => categoryFilterMap[i.category] == true).toList();
    }
    return const [];
  }
}