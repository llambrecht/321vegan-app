class ShopScanSummary {
  final String ean;
  final int scanCount;
  final DateTime lastScannedAt;
  final int daysSinceLastScan;
  final int notFoundCount;
  final DateTime? lastNotFoundAt;
  final double presenceScore;

  ShopScanSummary({
    required this.ean,
    required this.scanCount,
    required this.lastScannedAt,
    required this.daysSinceLastScan,
    required this.notFoundCount,
    this.lastNotFoundAt,
    required this.presenceScore,
  });

  factory ShopScanSummary.fromJson(Map<String, dynamic> json) {
    final lastScannedAt = json['last_scanned_at'] != null
        ? DateTime.parse(json['last_scanned_at'])
        : DateTime.now();
    final daysSinceLastScan = DateTime.now().difference(lastScannedAt).inDays;
    return ShopScanSummary(
      ean: json['ean'] ?? '',
      scanCount: json['scan_count'] ?? 0,
      lastScannedAt: lastScannedAt,
      daysSinceLastScan: daysSinceLastScan,
      notFoundCount: json['not_found_count'] ?? 0,
      lastNotFoundAt: json['last_not_found_at'] != null
          ? DateTime.parse(json['last_not_found_at'])
          : null,
      presenceScore: (json['presence_score'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
