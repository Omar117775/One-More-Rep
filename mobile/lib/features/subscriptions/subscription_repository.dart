import 'subscription.dart';

/// Source of truth for subscription/payment/voucher data. Backed by
/// [MockSubscriptionRepository] for now; a backend-backed implementation can
/// be dropped in WITHOUT any UI change. Real redemption/checkout logic stays
/// server-side.
abstract class SubscriptionRepository {
  Future<List<SubscriptionPlan>> plans();

  Future<SubscriptionStatus?> currentStatus();

  Future<List<PaymentRecord>> paymentHistory();

  Future<List<VoucherRecord>> voucherHistory();
}
