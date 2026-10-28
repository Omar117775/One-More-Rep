<?php

namespace App\Http\Requests\Coach;

use App\Enums\Enums\ExerciseEquipment;
use App\Enums\Enums\ExerciseMuscleGroup;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreExerciseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user()?->isCoach();
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:120'],
            'muscle_group' => ['required', Rule::enum(ExerciseMuscleGroup::class)],
            'equipment' => ['nullable', Rule::enum(ExerciseEquipment::class)],
            'instructions' => ['nullable', 'string', 'max:5000'],
            'is_public' => ['sometimes', 'boolean'],

            'created_by' => ['prohibited'],
            'user_id' => ['prohibited'],
            'id' => ['prohibited'],
        ];
    }
}
