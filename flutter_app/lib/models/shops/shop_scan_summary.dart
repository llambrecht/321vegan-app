class ShopScanSummary {
  final String ean;
  final int scanCount;
  final DateTime lastScannedAt;
  final int daysSinceLastScan;

  ShopScanSummary(
      {required this.ean,
      required this.scanCount,
      required this.lastScannedAt,
      required this.daysSinceLastScan});

  factory ShopScanSummary.fromJson(Map<String, dynamic> json) {
    final lastScannedAt = json['last_scanned_at'] != null
        ? DateTime.parse(json['last_scanned_at'])
        : DateTime.now();
    final daysSinceLastScan = DateTime.now().difference(lastScannedAt).inDays;
    return ShopScanSummary(
        ean: json['ean'] ?? '',
        scanCount: json['scan_count'] ?? 0,
        lastScannedAt: lastScannedAt,
        daysSinceLastScan: daysSinceLastScan);
  }
}
