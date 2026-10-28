<?php

namespace App\Http\Requests\Coach;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class StoreWorkoutProgramRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isCoach();
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:120'],
            'description' => ['nullable', 'string', 'max:5000'],
            'is_active' => ['sometimes', 'boolean'],

            'days' => ['required', 'array', 'min:1', 'max:7'],
            'days.*.day_number' => ['required', 'integer', 'between:1,7', 'distinct'],
            'days.*.name' => ['required', 'string', 'min:2', 'max:100'],
            'days.*.exercises' => ['required', 'array', 'min:1', 'max:30'],
            'days.*.exercises.*.exercise_id' => ['required', 'integer', 'exists:exercises,id'],
            'days.*.exercises.*.sort_order' => ['required', 'integer', 'between:0,50'],
            'days.*.exercises.*.target_sets' => ['required', 'integer', 'between:1,20'],
            'days.*.exercises.*.target_reps_min' => ['required', 'integer', 'between:1,100'],
            'days.*.exercises.*.target_reps_max' => ['required', 'integer', 'between:1,100'],
            'days.*.exercises.*.target_weight_kg' => ['nullable', 'numeric', 'between:0,1000'],
            'days.*.exercises.*.rest_seconds' => ['nullable', 'integer', 'between:0,3600'],

            'coach_id' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $this->validateRepRanges($validator);
        $this->validateUniqueSortOrders($validator);
    }

    protected function validateRepRanges(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            foreach ((array) $this->input('days', []) as $dayIndex => $day) {
                foreach ((array) ($day['exercises'] ?? []) as $exerciseIndex => $exercise) {
                    if (! is_array($exercise)) {
                        continue;
                    }

                    $min = $exercise['target_reps_min'] ?? null;
                    $max = $exercise['target_reps_max'] ?? null;

                    if (is_numeric($min) && is_numeric($max) && (int) $min > (int) $max) {
                        $validator->errors()->add(
                            "days.{$dayIndex}.exercises.{$exerciseIndex}.target_reps_max",
                            'The maximum repetitions must be greater than or equal to the minimum repetitions.',
                        );
                    }
                }
            }
        });
    }

    protected function validateUniqueSortOrders(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            foreach ((array) $this->input('days', []) as $dayIndex => $day) {
                $seen = [];

                foreach ((array) ($day['exercises'] ?? []) as $exerciseIndex => $exercise) {
                    if (! is_array($exercise) || ! isset($exercise['sort_order'])) {
                        continue;
                    }

                    $sortOrder = (int) $exercise['sort_order'];

                    if (isset($seen[$sortOrder])) {
                        $validator->errors()->add(
                            "days.{$dayIndex}.exercises.{$exerciseIndex}.sort_order",
                            'The sort order must be unique within a program day.',
                        );
                    }

                    $seen[$sortOrder] = true;
                }
            }
        });
    }
}
