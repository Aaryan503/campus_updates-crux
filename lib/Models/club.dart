
enum Filters {technical, sports, cultural}

class Club {
  Club ({
    required this.name,
    required this.type,
  });
  final String name;
  final Filters type;
}