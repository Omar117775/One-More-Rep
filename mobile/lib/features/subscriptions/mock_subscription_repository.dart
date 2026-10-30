import 'subscription.dart';
import 'subscription_repository.dart';

/// MOCK DATA — Phase 4 stop-gap until subscriptions/payments/vouchers exist
/// on the backend. Static, English-only catalog content; deterministic
/// records; nothing is persisted or charged. Swap for a `lib/data/`
/// repository later.
class MockSubscriptionRepository implements SubscriptionRepository {
  const MockSubscriptionRepository();

  static const List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: 'starter-monthly',
      name: 'Starter',
      durationLabel: '1 month',
      features: [
        'Full exercise library',
        'Session tracking & history',
        'Weekly progress snapshots',
      ],
      recommended: false,
    ),
    SubscriptionPlan(
      id: 'warrior-quarterly',
      name: 'Warrior',
      durationLabel: '3 months',
      features: [
        'Everything in Starter',
        'Coach-assigned programs',
        'Nutrition targets',
      ],
      recommended: true,
    ),
    SubscriptionPlan(
      id: 'legend-yearly',
      name: 'Legend',
      durationLabel: '12 months',
      features: [
        'Everything in Warrior',
        'Best-value guarantee',
        'Early feature previews',
      ],
      recommended: false,
    ),
  ];

  static final SubscriptionStatus _current = SubscriptionStatus(
    planName: 'Warrior',
    planDurationLabel: '3 months',
    cycleDays: 30,
    daysRemaining: 21,
    active: true,
  );

  static final List<PaymentRecord> _payments = [
    PaymentRecord(
      id: 'p1',
      reference: 'VC-841022',
      submittedOn: DateTime(2026, 10, 12),
      status: PaymentStatus.approved,
    ),
    PaymentRecord(
      id: 'p2',
      reference: 'VC-917754',
      submittedOn: DateTime(2026, 9, 28),
      status: PaymentStatus.approved,
    ),
    PaymentRecord(
      id: 'p3',
      reference: 'VC-334219',
      submittedOn: DateTime(2026, 9, 10),
      status: PaymentStatus.pending,
    ),
  ];

  static final List<VoucherRecord> _vouchers = [
    VoucherRecord(
      code: 'WAR10',
      redeemedOn: DateTime(2026, 10, 12),
      status: VoucherStatus.redeemed,
    ),
    VoucherRecord(
      code: 'LAUNCH50',
      redeemedOn: DateTime(2026, 8, 2),
      status: VoucherStatus.redeemed,
    ),
    VoucherRecord(
      code: 'WELCOME15',
      redeemedOn: DateTime(2026, 1, 12),
      status: VoucherStatus.valid,
    ),
  ];

  @override
  Future<List<SubscriptionPlan>> plans() async => _plans;

  @override
  Future<SubscriptionStatus?> currentStatus() async => _current;

  @override
  Future<List<PaymentRecord>> paymentHistory() async => _payments;

  @override
  Future<List<VoucherRecord>> voucherHistory() async => _vouchers;
}
