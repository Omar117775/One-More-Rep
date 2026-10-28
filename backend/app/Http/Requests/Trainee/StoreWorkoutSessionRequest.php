<?php

namespace App\Http\Requests\Trainee;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Validator;

class StoreWorkoutSessionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isTrainee();
    }

    public function rules(): array
    {
        return [
            'assignment_id' => ['required', 'integer', 'exists:workout_assignments,id'],
            'started_at' => ['required', 'date', 'before_or_equal:now'],
            'completed_at' => ['nullable', 'date', 'after_or_equal:started_at', 'before_or_equal:now'],
            'notes' => ['nullable', 'string', 'max:2000'],

            'sets' => ['required', 'array', 'min:1', 'max:200'],
            'sets.*.exercise_id' => ['required', 'integer', 'exists:exercises,id'],
            'sets.*.set_number' => ['required', 'integer', 'between:1,100'],
            'sets.*.weight_kg' => ['nullable', 'numeric', 'between:0,1000'],
            'sets.*.reps' => ['required', 'integer', 'between:1,1000'],
            'sets.*.is_completed' => ['sometimes', 'boolean'],

            'trainee_id' => ['prohibited'],
            'workout_assignment_id' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $this->validateUniqueSetNumbers($validator);
    }

    protected function validateUniqueSetNumbers(Validator $validator): void
    {
        $validator->after(function (Validator $validator) {
            $seen = [];

            foreach ((array) $this->input('sets', []) as $index => $set) {
                if (! is_array($set) || ! isset($set['exercise_id'], $set['set_number'])) {
                    continue;
                }

                $key = (int) $set['exercise_id'].':'.(int) $set['set_number'];

                if (isset($seen[$key])) {
                    $validator->errors()->add(
                        "sets.{$index}.set_number",
                        'The same set number cannot be recorded twice for one exercise.',
                    );
                }

                $seen[$key] = true;
            }
        });
    }
}
