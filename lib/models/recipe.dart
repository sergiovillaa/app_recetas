class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.type,
    required this.isVegan,
    required this.isVegetarian,
    required this.author,
    this.likes = 0,
  });

  final String id;
  final String title;
  final String type;
  final bool isVegan;
  final bool isVegetarian;
  final String author;
  final int likes;

  Recipe copyWith({
    String? id,
    String? title,
    String? type,
    bool? isVegan,
    bool? isVegetarian,
    String? author,
    int? likes,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      author: author ?? this.author,
      likes: likes ?? this.likes,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json, String id) {
    return Recipe(
      id: id,
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isVegan: json['isVegan'] as bool? ?? false,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      author: json['author'] as String? ?? 'Desconocido',
      likes: json['likes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'isVegan': isVegan,
      'isVegetarian': isVegetarian,
      'author': author,
      'likes': likes,
    };
  }
}
