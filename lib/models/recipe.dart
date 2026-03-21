class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.type,
    required this.isVegan,
    required this.isVegetarian,
    required this.author,
  });

  final String id;
  final String title;
  final String type;
  final bool isVegan;
  final bool isVegetarian;
  final String author;
}
