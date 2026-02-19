class PartnersCategory {
  final int id;
  final String name;

  PartnersCategory({
    required this.id,
    required this.name,
  });

  factory PartnersCategory.fromJson(Map<String, dynamic> json) {
    return PartnersCategory(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
