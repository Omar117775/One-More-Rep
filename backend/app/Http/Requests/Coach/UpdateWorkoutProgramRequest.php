<?php

namespace App\Http\Requests\Coach;

use Illuminate\Validation\Validator;

class UpdateWorkoutProgramRequest extends StoreWorkoutProgramRequest
{
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'min:2', 'max:120'],
            'description' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'is_active' => ['sometimes', 'boolean'],

            'days' => ['sometimes', 'array', 'min:1', 'max:7'],
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

        $validator->after(function (Validator $validator) {
            $editable = ['name', 'description', 'is_active', 'days'];

            if (array_intersect($editable, array_keys($this->all())) === []) {
                $validator->errors()->add('program', 'At least one editable field is required.');
            }
        });
    }
}
