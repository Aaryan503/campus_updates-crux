import 'package:flutter_riverpod/flutter_riverpod.dart';

enum Filter {
  technical, cultural, sports
}

class FiltersNotifier extends StateNotifier<Map<Filter, bool>> {
  FiltersNotifier()
      : super({
          Filter.technical: true,
          Filter.cultural: true,
          Filter.sports: true,
        });

  void setFilter(Filter filter, bool isSet) {
    state = {
      ...state,
      filter: isSet,
    };
  }

  void resetFilters() {
    state = {
      Filter.technical: true,
      Filter.cultural: true,
      Filter.sports: true,
    };
  }
}

final filtersProvider =
    StateNotifierProvider<FiltersNotifier, Map<Filter, bool>>(
  (ref) => FiltersNotifier(),
);
