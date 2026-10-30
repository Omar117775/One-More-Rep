import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../components/states.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../design/motion/progress_ring_bar.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'payments_screen.dart';
import 'subscription.dart';
import 'subscription_repository.dart';
import 'subscriptions_view_model.dart';

/// Subscription preview (P4 mock). Every card carries the localized MOCK
/// PREVIEW badge; plan selection is a mock toast. Prices/vouchers are
/// backend-owned — nothing is enforced or charged from the client. Payments
/// (manual Vodafone Cash) and vouchers live on/in this screen.
class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({this.repository, super.key});

  /// Optional injection point for tests; defaults to the mock container.
  final SubscriptionRepository? repository;

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  SubscriptionsViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel ??= SubscriptionsViewModel(repository: widget.repository)
      ..load();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final viewModel = _viewModel!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(child: Text(strings.subscriptionsTitle)),
            _MockBadge(),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          switch (viewModel.status) {
            case SubscriptionsStatus.loading:
              return const OmrLoading();
            case SubscriptionsStatus.error:
              return OmrErrorPanel(
                message: viewModel.errorMessage ?? strings.errorGeneric,
                onRetry: viewModel.load,
              );
            case SubscriptionsStatus.ready:
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppBreakpoints.contentMax,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      if (viewModel.current != null) ...[
                        SectionHeader(
                          title: strings.subscriptionsCurrentHeader,
                        ),
                        _CurrentPlanCard(status: viewModel.current!),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: SectionHeader(
                              title: strings.subscriptionsPlansHeader,
                            ),
                          ),
                        ],
                      ),
                      ...[
                        for (final plan in viewModel.plans)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: _PlanCard(
                              plan: plan,
                              strings: strings,
                            ),
                          ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      _PaymentsEntryRow(onOpenPayments: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => PaymentsScreen(
                              viewModel: viewModel,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.lg),
                      _VoucherSection(viewModel: viewModel),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}

class _MockBadge extends StatelessWidget {
  const _MockBadge();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
      ),
      child: Text(
        strings.mockPreview,
        style: AppText.microLabel.copyWith(color: AppColors.goldLight),
      ),
    );
  }
}

/// Current plan with the second [ProgressRingBar] consumer: cycle progress.
class _CurrentPlanCard extends StatelessWidget {
  const _CurrentPlanCard({required this.status});

  final SubscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;
    final progress = status.cycleDays > 0
        ? status.daysRemaining / status.cycleDays
        : 0.0;

    return OmrCard(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ProgressRingBar(value: progress, size: 84, strokeWidth: 9),
              Text(
                '${formatInteger(status.daysRemaining, locale: locale)}\n'
                '${strings.subscriptionsDaysRemaining}',
                textAlign: TextAlign.center,
                style: AppText.microLabel.copyWith(fontSize: 9, height: 1.2),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.planName,
                  style: AppText.headline.copyWith(fontSize: 20),
                ),
                Text(status.planDurationLabel, style: AppText.secondary),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    strings.trainActive,
                    style: AppText.microLabel.copyWith(
                      color: AppColors.goldLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.strings});

  final SubscriptionPlan plan;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return OmrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: AppText.title.copyWith(fontSize: 17),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bronze.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  border: Border.all(
                    color: AppColors.bronze.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  plan.durationLabel,
                  style: AppText.microLabel.copyWith(color: AppColors.bronze),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final feature in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppColors.goldLight,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(feature, style: AppText.body)),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (plan.recommended) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Text(
                    strings.trainUpcoming,
                    style: AppText.microLabel.copyWith(
                      color: AppColors.goldLight,
                    ),
                  ),
                  // The mock catalog tags a recommended tier visually via
                  // the gold border below.
                ),
                const SizedBox(width: AppSpacing.sm),
                const Spacer(),
              ] else
                const Spacer(),
              SizedBox(
                height: AppSpacing.touchTarget - 8,
                child: FilledButton.tonal(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(strings.planSelectToast)),
                    );
                  },
                  child: Text(strings.planSelectCta),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single entry row to payments: localized form-field alike.
class _PaymentsEntryRow extends StatelessWidget {
  const _PaymentsEntryRow({required this.onOpenPayments});

  final VoidCallback onOpenPayments;

  @override
  Widget build(BuildContext context) {
    final ctrl = AppScope.of(context);
    final strings = ctrl.strings;
    final locale = strings.localeName;
    final title = strings.paymentsTitle;

    return OmrCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onOpenPayments,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child: Icon(
              Icons.payments_outlined,
              color: AppColors.goldLight,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  // Mock honesty: what the sub-page does.
                  '${strings.paymentsReferenceLabel} • '
                  '${formatInteger(0, locale: locale)}',
                  style: AppText.secondary.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.goldLight,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}

class _VoucherSection extends StatefulWidget {
  const _VoucherSection({required this.viewModel});

  final SubscriptionsViewModel viewModel;

  @override
  State<_VoucherSection> createState() => _VoucherSectionState();
}

class _VoucherSectionState extends State<_VoucherSection> {
  final _voucherController = TextEditingController();

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final ctrl = AppScope.of(context);
    final locale = ctrl.strings.localeName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: strings.voucherSectionHeader),
        OmrCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.voucherCodeLabel, style: AppText.caption),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _voucherController,
                      decoration: InputDecoration(
                        hintText: strings.paymentsReferenceHint,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SizedBox(
                    height: AppSpacing.touchTarget - 8,
                    child: FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.voucherInfoNote)),
                        );
                      },
                      child: Text(strings.voucherRedeemCta),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                strings.voucherInfoNote,
                style: AppText.secondary.copyWith(
                  fontSize: 11,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: strings.voucherHistoryHeader),
        for (final record in widget.viewModel.vouchers)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: OmrCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.code, style: AppText.title),
                        const SizedBox(height: 2),
                        Text(
                          formatDate(record.redeemedOn, locale: locale),
                          style: AppText.secondary.copyWith(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                  _StatusChip(
                    label: record.status == VoucherStatus.redeemed
                        ? strings.voucherStatusRedeemed
                        : strings.voucherStatusValid,
                    color: record.status == VoucherStatus.redeemed
                        ? AppColors.muted
                        : AppColors.goldLight,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(color: color, fontSize: 10.5),
      ),
    );
  }
}
