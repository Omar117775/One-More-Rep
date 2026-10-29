import 'package:flutter/material.dart';

import '../../components/common.dart';
import '../../core/app_scope.dart';
import '../../core/formatters.dart';
import '../../core/parsing.dart';
import '../../design/tokens.dart';
import '../../data/models/cardio_entry.dart';
import '../../localization/app_strings.dart';
import 'cardio_activities.dart';
import 'cardio_view_model.dart';

class CardioFormScreen extends StatefulWidget {
  const CardioFormScreen({required this.viewModel, this.entry, super.key});

  final CardioViewModel viewModel;
  final CardioEntry? entry;

  static Future<void> push(BuildContext context, {CardioEntry? entry}) async {
    final viewModel = CardioViewModel(repo: AppScope.of(context).cardio);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CardioFormScreen(viewModel: viewModel, entry: entry),
      ),
    );
  }

  @override
  State<CardioFormScreen> createState() => _CardioFormScreenState();
}

class _CardioFormScreenState extends State<CardioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late CardioActivityOption _activity;
  late final TextEditingController _duration;
  final _distanceController = TextEditingController();
  final _heartRateController = TextEditingController();
  DateTime _performedAt = DateTime.now();
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _activity = entry == null
        ? CardioActivityOption.options[0]
        : CardioActivityOption.resolve(entry.activityType);
    _duration = TextEditingController(
      text: entry != null ? '${(entry.durationSeconds / 60).round()}' : '',
    );
    if (entry?.distanceKm != null) {
      _distanceController.text = _trimNumber(entry!.distanceKm!);
    }
    if (entry?.averageHeartRate != null) {
      _heartRateController.text = '${entry!.averageHeartRate}';
    }
    if (entry?.performedAt != null) {
      _performedAt = entry!.performedAt!.toLocal();
    }
  }

  String _trimNumber(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();

  @override
  void dispose() {
    _duration.dispose();
    _distanceController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  String? _validateRequiredNumber(String? value) {
    final strings = AppStrings.of(context);
    if ((value ?? '').trim().isEmpty) return strings.requiredField;
    final parsed = parseDecimal(value);
    if (parsed == null || parsed <= 0) return strings.invalidNumber;
    return null;
  }

  String? _validateOptionalNumber(String? value) {
    final strings = AppStrings.of(context);
    if ((value ?? '').trim().isEmpty) return null;
    final parsed = parseDecimal(value);
    if (parsed == null || parsed <= 0) return strings.invalidNumber;
    return null;
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      return;
    }
    final strings = AppStrings.of(context);
    final minutes = parseDecimal(_duration.text) ?? 0;
    final seconds = (minutes * 60).round();
    final distance = parseDecimal(_distanceController.text);
    final heartRate = parseInt(_heartRateController.text);
    final isUpdate = widget.entry != null;

    setState(() {
      _saving = true;
      _errorText = null;
    });
    final ok = await widget.viewModel.save(
      isUpdate: isUpdate,
      id: widget.entry?.id,
      activityType: _activity.value,
      durationSeconds: seconds,
      distanceKm: distance,
      averageHeartRate: heartRate,
      performedAt: _performedAt,
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.entry == null ? strings.addCardio : strings.editCardio,
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(strings.activityType, style: AppText.caption),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              initialValue: _activity.value,
              decoration: InputDecoration(
                prefixIcon: Icon(_activity.icon, color: AppColors.blueLight),
              ),
              items: [
                for (final option in CardioActivityOption.options)
                  DropdownMenuItem(
                    value: option.value,
                    child: Row(
                      children: [
                        Icon(option.icon, size: 20, color: AppColors.blueLight),
                        const SizedBox(width: AppSpacing.sm),
                        Text(option.label(strings)),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _activity = CardioActivityOption(value));
              },
            ),
            const SizedBox(height: AppSpacing.md),
            OmrTextField(
              label: strings.durationMinutes,
              controller: _duration,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateRequiredNumber,
            ),
            const SizedBox(height: AppSpacing.md),
            OmrTextField(
              label: strings.distanceKm,
              controller: _distanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: _validateOptionalNumber,
            ),
            const SizedBox(height: AppSpacing.md),
            OmrTextField(
              label: strings.avgHeartRate,
              controller: _heartRateController,
              keyboardType: TextInputType.number,
              validator: _validateOptionalNumber,
            ),
            const SizedBox(height: AppSpacing.md),
            _DateRow(
              label: strings.performedAt,
              value: _performedAt,
              locale: AppScope.of(context).strings.localeName,
              onChanged: (dt) {
                if (dt != null) setState(() => _performedAt = dt);
              },
            ),
            if (_errorText != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorText!,
                style: AppText.secondary.copyWith(color: AppColors.danger),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: widget.entry == null
                  ? strings.addCardio
                  : strings.editCardio,
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

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.value,
    required this.locale,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final String locale;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.caption),
        const SizedBox(height: AppSpacing.xs),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.white,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          onPressed: () async {
            final now = DateTime.now();
            final today = DateUtils.dateOnly(now);
            final date = await showDatePicker(
              context: context,
              initialDate: value.isAfter(today) ? today : value,
              firstDate: DateTime(2000),
              lastDate: today,
            );
            if (date == null || !context.mounted) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(value),
            );
            if (time == null) return;
            var picked = date.add(
              Duration(hours: time.hour, minutes: time.minute),
            );
            // The backend rejects performed_at values in the future.
            if (picked.isAfter(now)) picked = now;
            onChanged(picked);
          },
          icon: const Icon(Icons.event_outlined, size: 20),
          label: Text(
            formatDateTime(value, locale: locale),
            style: AppText.body,
          ),
        ),
      ],
    );
  }
}
