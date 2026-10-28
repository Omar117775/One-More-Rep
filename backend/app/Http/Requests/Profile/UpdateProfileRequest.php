<?php

namespace App\Http\Requests\Profile;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null;
    }

    public function rules(): array
    {
        return [
            // Base account fields a user may edit on their own profile.
            'name' => ['sometimes', 'string', 'min:2', 'max:120'],
            'locale' => ['sometimes', 'in:en,ar'],
            'timezone' => ['sometimes', 'timezone'],

            // Trainee-only fields.
            'date_of_birth' => ['sometimes', 'nullable', 'date', 'before:today'],
            'sex' => ['sometimes', 'nullable', 'in:male,female,other,prefer_not_to_say'],
            'height_cm' => ['sometimes', 'nullable', 'numeric', 'min:50', 'max:300'],
            'initial_weight_kg' => ['sometimes', 'nullable', 'numeric', 'min:20', 'max:500'],

            // Coach-only fields.
            'display_name' => ['sometimes', 'nullable', 'string', 'max:120'],
            'bio' => ['sometimes', 'nullable', 'string', 'max:2000'],

            // Never allow privilege/ownership escalation through profile updates.
            'email' => ['prohibited'],
            'password' => ['prohibited'],
            'user_id' => ['prohibited'],
            'role' => ['prohibited'],
            'roles' => ['prohibited'],
            'is_active' => ['prohibited'],
            'is_super_admin' => ['prohibited'],
            'email_verified_at' => ['prohibited'],
        ];
    }
}
