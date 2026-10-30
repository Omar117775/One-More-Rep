/// Subscription / payment / voucher domain (Phase 4: local mock data — see
/// [MockSubscriptionRepository]). NO purchasing, pricing enforcement or
/// voucher validation happens in the app: those decisions are owned by the
/// backend. Everything here is display-only and marked MOCK PREVIEW in the
/// UI.
library;

/// Catalog plan shown in the mock preview. Prices are intentionally NOT part
/// of the model — pricing belongs to the backend, and the client never
/// presents it as authoritative.
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.durationLabel,
    required this.features,
    required this.recommended,
  });

  final String id;

  /// Mock catalog copy (English-only content).
  final String name;
  final String durationLabel;
  final List<String> features;

  /// Visual emphasis for the mock catalog's highlighted tier.
  final bool recommended;
}

class SubscriptionStatus {
  const SubscriptionStatus({
    required this.planName,
    required this.planDurationLabel,
    required this.cycleDays,
    required this.daysRemaining,
    required this.active,
  });

  final String planName;
  final String planDurationLabel;

  /// Cycle progress for the ring (days remaining / cycle length).
  final int cycleDays;
  final int daysRemaining;
  final bool active;
}

enum PaymentStatus { pending, approved }

class PaymentRecord {
  const PaymentRecord({
    required this.id,
    required this.reference,
    required this.submittedOn,
    required this.status,
  });

  final String id;

  /// Manual Vodafone Cash reference text.
  final String reference;
  final DateTime submittedOn;
  final PaymentStatus status;
}

enum VoucherStatus { valid, redeemed }

class VoucherRecord {
  const VoucherRecord({
    required this.code,
    required this.redeemedOn,
    required this.status,
  });

  final String code;
  final DateTime redeemedOn;
  final VoucherStatus status;
}
