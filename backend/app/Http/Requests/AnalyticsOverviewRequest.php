<?php

namespace App\Http\Requests;

use Carbon\CarbonImmutable;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class AnalyticsOverviewRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) ($this->user()?->isTrainee() || $this->user()?->isCoach());
    }

    public function rules(): array
    {
        return [
            'from' => ['sometimes', 'date_format:Y-m-d'],
            'to' => ['sometimes', 'date_format:Y-m-d', 'before_or_equal:today'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            if ($validator->errors()->isNotEmpty()) {
                return;
            }

            $to = $this->toDate();

            if ($this->filled('from') && CarbonImmutable::parse($this->input('from'))->gt($to)) {
                $validator->errors()->add('from', 'The start date must be before or equal to the end date.');
            }

            if ($this->fromDate()->diffInDays($to) + 1 > 366) {
                $validator->errors()->add('from', 'The analytics range cannot exceed 366 days.');
            }
        });
    }

    public function fromDate(): CarbonImmutable
    {
        if ($this->filled('from')) {
            return CarbonImmutable::parse($this->input('from'))->startOfDay();
        }

        return $this->toDate()->subDays(29)->startOfDay();
    }

    public function toDate(): CarbonImmutable
    {
        if ($this->filled('to')) {
            return CarbonImmutable::parse($this->input('to'))->startOfDay();
        }

        return CarbonImmutable::today()->startOfDay();
    }
}
