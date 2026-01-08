class ProductOfInterest {
  final String ean;
  final String name;
  final String image;
  final String type;
  final int categoryId;
  final int brandId;
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String categoryName;
  final String brandName;

  ProductOfInterest({
    required this.ean,
    required this.name,
    required this.image,
    required this.type,
    required this.categoryId,
    required this.brandId,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryName,
    required this.brandName,
  });

  factory ProductOfInterest.fromJson(Map<String, dynamic> json) {
    return ProductOfInterest(
      ean: json['ean'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? '',
      categoryId: json['category_id'] ?? 0,
      brandId: json['brand_id'] ?? 0,
      id: json['id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      categoryName: json['category_name'] ?? '',
      brandName: json['brand_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ean': ean,
      'name': name,
      'image': image,
      'type': type,
      'category_id': categoryId,
      'brand_id': brandId,
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category_name': categoryName,
      'brand_name': brandName,
    };
  }
}
