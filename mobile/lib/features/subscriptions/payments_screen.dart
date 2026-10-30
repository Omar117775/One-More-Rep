import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../design/tokens.dart';
import '../../localization/app_strings.dart';
import 'subscription.dart';
import 'subscriptions_view_model.dart';

/// Payments screen (UI only / Mock verification).
/// Provides manual Vodafone Cash reference submission, payment methods overview,
/// transaction history, and mock invoice details.
///
/// NOTE: Financial charges and payment approvals are strictly owned by backend
/// and administrative review.
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({required this.viewModel, super.key});

  final SubscriptionsViewModel viewModel;

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _referenceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedMethodIndex = 0;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  void _submitReference(AppStrings strings) {
    if (!_formKey.currentState!.validate()) return;
    final reference = _referenceController.text.trim();
    widget.viewModel.submitPaymentReference(reference);
    _referenceController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.paymentsSubmittedToast),
        backgroundColor: AppColors.surfaceLight,
      ),
    );
  }

  void _showInvoiceDialog(PaymentRecord record, AppStrings strings, String locale) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              const Icon(Icons.receipt_long, color: AppColors.gold),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  strings.paymentsHistoryHeader,
                  style: AppText.title,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InvoiceRow(
                label: 'ID',
                value: record.id,
              ),
              const SizedBox(height: AppSpacing.xs),
              _InvoiceRow(
                label: strings.paymentsReferenceLabel,
                value: record.reference,
              ),
              const SizedBox(height: AppSpacing.xs),
              _InvoiceRow(
                label: 'Date',
                value: formatDate(record.submittedOn, locale: locale),
              ),
              const SizedBox(height: AppSpacing.xs),
              _InvoiceRow(
                label: 'Status',
                value: record.status == PaymentStatus.approved
                    ? strings.paymentStatusApproved
                    : strings.paymentStatusPending,
                valueColor: record.status == PaymentStatus.approved
                    ? AppColors.success
                    : AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                strings.paymentsInfoNote,
                style: AppText.secondary.copyWith(fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final ctrl = AppScope.of(context);
    final locale = ctrl.strings.localeName;

    final methods = [
      {'name': 'Vodafone Cash', 'desc': 'Manual transfer to wallet (010-XXXX-XXXX)'},
      {'name': 'Credit / Debit Card', 'desc': 'Visa & Mastercard (Mock UI)'},
      {'name': 'InstaPay', 'desc': 'Instant Egyptian Bank Transfer (Mock UI)'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.paymentsTitle),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppBreakpoints.contentMax,
              ),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Payment Methods Selection
                  SectionHeader(title: 'Payment Methods'),
                  for (var i = 0; i < methods.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: OmrCard(
                        onTap: () => setState(() => _selectedMethodIndex = i),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _selectedMethodIndex == i
                                      ? AppColors.gold
                                      : AppColors.muted,
                                  width: 2,
                                ),
                              ),
                              child: _selectedMethodIndex == i
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    methods[i]['name']!,
                                    style: AppText.title.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    methods[i]['desc']!,
                                    style: AppText.secondary.copyWith(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),

                  // Submission Form
                  SectionHeader(title: strings.paymentsReferenceLabel),
                  OmrCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.paymentsReferenceHint,
                            style: AppText.caption,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          TextFormField(
                            controller: _referenceController,
                            decoration: InputDecoration(
                              hintText: 'e.g. 98234710',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadii.sm),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return strings.paymentsReferenceHint;
                              }
                              if (value.trim().length < 4) {
                                return 'Reference must be at least 4 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => _submitReference(strings),
                              child: Text(strings.paymentsSubmitCta),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            strings.paymentsInfoNote,
                            style: AppText.secondary.copyWith(fontSize: 11, height: 1.3),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            strings.paymentsPrivacyNote,
                            style: AppText.secondary.copyWith(
                              fontSize: 11,
                              color: AppColors.goldDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Payment History
                  SectionHeader(title: strings.paymentsHistoryHeader),
                  if (widget.viewModel.payments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      child: Text(
                        'No payment records found',
                        style: AppText.secondary,
                      ),
                    )
                  else
                    for (final record in widget.viewModel.payments)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: OmrCard(
                          onTap: () => _showInvoiceDialog(record, strings, locale),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  record.status == PaymentStatus.approved
                                      ? Icons.check_circle_outline
                                      : Icons.hourglass_top,
                                  color: record.status == PaymentStatus.approved
                                      ? AppColors.success
                                      : AppColors.warning,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${strings.paymentsReferenceLabel}: ${record.reference}',
                                      style: AppText.title.copyWith(fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formatDate(record.submittedOn, locale: locale),
                                      style: AppText.secondary.copyWith(fontSize: 11.5),
                                    ),
                                  ],
                                ),
                              ),
                              _PaymentBadge(
                                status: record.status,
                                strings: strings,
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.secondary.copyWith(fontSize: 12)),
        Text(
          value,
          style: AppText.body.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: valueColor ?? AppColors.white,
          ),
        ),
      ],
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.status, required this.strings});

  final PaymentStatus status;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final isApproved = status == PaymentStatus.approved;
    final color = isApproved ? AppColors.success : AppColors.warning;
    final text = isApproved
        ? strings.paymentStatusApproved
        : strings.paymentStatusPending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: AppText.caption.copyWith(color: color, fontSize: 10.5),
      ),
    );
  }
}
