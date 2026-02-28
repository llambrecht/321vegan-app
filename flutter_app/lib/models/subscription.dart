enum SubscriptionStatus {
  active,
  expired,
  cancelled,
  graceperiod;

  static SubscriptionStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      case 'grace_period':
        return SubscriptionStatus.graceperiod;
      default:
        return SubscriptionStatus.expired;
    }
  }
}

class Subscription {
  final int id;
  final int userId;
  final String platform;
  final String originalTransactionId;
  final String productId;
  final SubscriptionStatus status;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.platform,
    required this.originalTransactionId,
    required this.productId,
    required this.status,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      userId: json['user_id'],
      platform: json['platform'],
      originalTransactionId: json['original_transaction_id'],
      productId: json['product_id'],
      status: SubscriptionStatus.fromString(json['status'] ?? 'expired'),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.graceperiod;
}
