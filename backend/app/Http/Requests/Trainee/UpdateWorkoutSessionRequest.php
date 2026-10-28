<?php

namespace App\Http\Requests\Trainee;

use App\Models\WorkoutSession;
use Carbon\CarbonImmutable;
use Illuminate\Validation\Validator;

class UpdateWorkoutSessionRequest extends StoreWorkoutSessionRequest
{
    public function rules(): array
    {
        return [
            'started_at' => ['sometimes', 'date', 'before_or_equal:now'],
            'completed_at' => ['sometimes', 'nullable', 'date', 'before_or_equal:now'],
            'notes' => ['sometimes', 'nullable', 'string', 'max:2000'],

            'sets' => ['sometimes', 'array', 'min:1', 'max:200'],
            'sets.*.exercise_id' => ['required', 'integer', 'exists:exercises,id'],
            'sets.*.set_number' => ['required', 'integer', 'between:1,100'],
            'sets.*.weight_kg' => ['nullable', 'numeric', 'between:0,1000'],
            'sets.*.reps' => ['required', 'integer', 'between:1,1000'],
            'sets.*.is_completed' => ['sometimes', 'boolean'],

            'assignment_id' => ['prohibited'],
            'trainee_id' => ['prohibited'],
            'workout_assignment_id' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $this->validateUniqueSetNumbers($validator);

        $validator->after(function (Validator $validator) {
            $startedAt = $this->input('started_at');
            $completedAt = $this->input('completed_at');
            $session = $this->route('session');

            if (! $startedAt && $session instanceof WorkoutSession) {
                $startedAt = $session->started_at?->toIso8601String();
            }

            if ($startedAt && $completedAt) {
                try {
                    if (CarbonImmutable::parse($completedAt)->lt(CarbonImmutable::parse($startedAt))) {
                        $validator->errors()->add('completed_at', 'The completion time must be after the start time.');
                    }
                } catch (\Throwable) {
                    // Date validation reports malformed values.
                }
            }

            $editable = ['started_at', 'completed_at', 'notes', 'sets'];

            if (array_intersect($editable, array_keys($this->all())) === []) {
                $validator->errors()->add('session', 'At least one editable field is required.');
            }
        });
    }
}
