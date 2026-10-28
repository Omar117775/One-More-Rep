import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/parsing.dart';
import '../../design/tokens.dart';
import '../../data/models/progress_entry.dart';
import '../../localization/app_strings.dart';
import 'progress_view_model.dart';

/// Create/edit body measurement. Backend requires measured_on + at least one
/// measurement; the form enforces the same contract client-side.
class ProgressFormScreen extends StatefulWidget {
  const ProgressFormScreen({required this.viewModel, this.entry, super.key});

  final ProgressViewModel viewModel;
  final ProgressEntry? entry;

  static Future<void> push(
    BuildContext context, {
    required ProgressViewModel viewModel,
    ProgressEntry? entry,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgressFormScreen(viewModel: viewModel, entry: entry),
      ),
    );
  }

  @override
  State<ProgressFormScreen> createState() => _ProgressFormScreenState();
}

class _ProgressFormScreenState extends State<ProgressFormScreen> {
  static const _measurementFields = [
    _FieldSpec(_Field.weight),
    _FieldSpec(_Field.bodyFat),
    _FieldSpec(_Field.waist),
    _FieldSpec(_Field.chest),
    _FieldSpec(_Field.arm),
  ];

  final _formKey = GlobalKey<FormState>();
  final Map<_Field, TextEditingController> _controllers = {
    for (final spec in _measurementFields)
      spec.field: TextEditingController(),
  };
  DateTime _measuredOn = DateTime.now();
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry == null) return;
    void fill(_Field field, double? value) {
      if (value == null) return;
      final text = value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toString();
      _controllers[field]!.text = text;
    }

    fill(_Field.weight, entry.weightKg);
    fill(_Field.bodyFat, entry.bodyFatPercentage);
    fill(_Field.waist, entry.waistCm);
    fill(_Field.chest, entry.chestCm);
    fill(_Field.arm, entry.armCm);
    _measuredOn = entry.measuredOn.toLocal();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _validateOptional(String? value) {
    final strings = AppStrings.of(context);
    if ((value ?? '').trim().isEmpty) return null;
    final parsed = parseDecimal(value);
    if (parsed == null || parsed <= 0) return strings.invalidNumber;
    return null;
  }

  Future<void> _submit() async {
    final strings = AppStrings.of(context);
    if (_formKey.currentState?.validate() != true) return;

    double? valueFor(_Field field) => parseDecimal(_controllers[field]!.text);

    final weight = valueFor(_Field.weight);
    final bodyFat = valueFor(_Field.bodyFat);
    final waist = valueFor(_Field.waist);
    final chest = valueFor(_Field.chest);
    final arm = valueFor(_Field.arm);
    if (weight == null && bodyFat == null && waist == null && chest == null && arm == null) {
      setState(() => _errorText = strings.requiredField);
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });
    final ok = await widget.viewModel.save(
      isUpdate: widget.entry != null,
      id: widget.entry?.id,
      measuredOn: _measuredOn,
      weightKg: weight,
      bodyFatPercentage: bodyFat,
      waistCm: waist,
      chestCm: chest,
      armCm: arm,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _errorText = widget.viewModel.errorMessage ?? strings.errorGeneric;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final controller = AppScope.of(context);
    final locale = controller.strings.localeName;

    final labels = {
      _Field.weight: strings.weightKg,
      _Field.bodyFat: strings.bodyFatPercentage,
      _Field.waist: strings.waistCm,
      _Field.chest: strings.chestCm,
      _Field.arm: strings.armCm,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry == null ? strings.addMeasurement : strings.editMeasurement),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(strings.measuredOn, style: AppText.caption),
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.white,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _measuredOn,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) setState(() => _measuredOn = picked);
              },
              icon: const Icon(Icons.event_outlined, size: 20),
              label: Text(formatDate(_measuredOn, locale: locale), style: AppText.body),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final spec in _measurementFields)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: OmrTextField(
                  label: labels[spec.field]!,
                  controller: _controllers[spec.field],
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: _validateOptional,
                ),
              ),
            if (_errorText != null)
              Text(_errorText!, style: AppText.secondary.copyWith(color: AppColors.danger)),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: widget.entry == null ? strings.addMeasurement : strings.editMeasurement,
              loading: _saving,
              onPressed: _saving ? null : _submit,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

enum _Field { weight, bodyFat, waist, chest, arm }

class _FieldSpec {
  const _FieldSpec(this.field);

  final _Field field;
}
