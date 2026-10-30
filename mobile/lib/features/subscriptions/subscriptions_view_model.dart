import 'package:flutter/foundation.dart';

import 'mock_subscription_repository.dart';
import 'subscription.dart';
import 'subscription_repository.dart';

/// Load status — mirrors repo-backed view models so a real repository can
/// replace the mock without changing the UI shell.
enum SubscriptionsStatus { loading, error, ready }

/// Read-only subscription state with a MOCK payment-reference flow. Nothing
/// here implies charging, entitlement or voucher validity: in the real
/// system the backend owns plans, prices, discounts, voucher codes and
/// payment approval (explicit admin approval for manual Vodafone Cash).
class SubscriptionsViewModel extends ChangeNotifier {
  SubscriptionsViewModel({SubscriptionRepository? repository})
    : _repository = repository ?? const MockSubscriptionRepository();

  final SubscriptionRepository _repository;

  SubscriptionsStatus status = SubscriptionsStatus.loading;
  String? errorMessage;

  List<SubscriptionPlan> plans = const [];
  SubscriptionStatus? current;
  List<PaymentRecord> payments = const [];
  List<VoucherRecord> vouchers = const [];

  bool _busy = false;
  bool get busy => _busy;

  Future<void> load() async {
    status = SubscriptionsStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.plans(),
        _repository.currentStatus(),
        _repository.paymentHistory(),
        _repository.voucherHistory(),
      ]);
      plans = results[0] as List<SubscriptionPlan>;
      current = results[1] as SubscriptionStatus?;
      payments = results[2] as List<PaymentRecord>;
      vouchers = results[3] as List<VoucherRecord>;
      status = SubscriptionsStatus.ready;
    } catch (error) {
      errorMessage = error.toString();
      status = SubscriptionsStatus.error;
    }
    notifyListeners();
  }

  /// MOCK: records a submitted Vodafone Cash reference into the local list as
  /// PENDING. It explicitly never confirms payment — real approval is an
  /// admin action on the server. [reference] must be pre-validated by the
  /// caller's form.
  void submitPaymentReference(String reference) {
    if (_busy) return;
    _busy = true;
    payments = [
      PaymentRecord(
        id: 'mock-${payments.length + 1}',
        reference: reference,
        submittedOn: DateTime.now(),
        status: PaymentStatus.pending,
      ),
      ...payments,
    ];
    _busy = false;
    notifyListeners();
  }
}
