import 'vegan_status.dart';

class ProductDocument {
  final String code;
  final DateTime createdAt;
  final VeganStatus isVegan;

  ProductDocument({
    required this.code,
    required this.createdAt,
    required this.isVegan,
  });

  Map<String, dynamic> toJson() => {
        'createdAt': createdAt.toIso8601String(),
        'isVegan': isVegan.toShortString(),
      };

  factory ProductDocument.fromJson(Map<String, dynamic> json) => ProductDocument(
        code: json['code'],
        createdAt: DateTime.parse(json['createdAt']),
        isVegan: VeganStatusExtension.fromString(json['isVegan']),
      );
}
