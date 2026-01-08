class ScannedProduct {
  final String ean;
  final int scanCount;

  ScannedProduct({
    required this.ean,
    required this.scanCount,
  });

  factory ScannedProduct.fromJson(Map<String, dynamic> json) {
    return ScannedProduct(
      ean: json['ean'] ?? '',
      scanCount: json['scan_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ean': ean,
      'scan_count': scanCount,
    };
  }
}
