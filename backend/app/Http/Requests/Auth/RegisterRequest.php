<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'min:2', 'max:120'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'confirmed', Password::defaults()],
            'password_confirmation' => ['required'],
            'device_name' => ['sometimes', 'string', 'max:100'],
            'locale' => ['sometimes', 'in:en,ar'],
            'timezone' => ['sometimes', 'timezone'],
            'role' => ['prohibited'],
            'roles' => ['prohibited'],
            'is_active' => ['prohibited'],
            'is_super_admin' => ['prohibited'],
            'email_verified_at' => ['prohibited'],
            'user_id' => ['prohibited'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('email')) {
            $this->merge(['email' => strtolower(trim((string) $this->input('email')))]);
        }
    }
}
