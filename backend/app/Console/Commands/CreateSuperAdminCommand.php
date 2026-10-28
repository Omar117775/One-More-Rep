<?php

namespace App\Console\Commands;

use App\Models\AuditLog;
use App\Models\Role;
use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class CreateSuperAdminCommand extends Command
{
    protected $signature = 'user:create-super-admin {--name=} {--email=}';

    protected $description = 'Create a super admin account (CLI only, no password passed as argument)';

    public function handle(): int
    {
        $name = $this->option('name') ?: $this->ask('Full name');
        $email = $this->option('email') ?: $this->ask('Email address');
        $email = strtolower(trim($email));

        $password = $this->secret('Password (min 10 chars, letters and numbers)');
        $confirm = $this->secret('Confirm password');

        if ($password !== $confirm) {
            $this->error('Passwords do not match.');

            return self::FAILURE;
        }

        $validator = Validator::make([
            'name' => $name,
            'email' => $email,
            'password' => $password,
        ], [
            'name' => ['required', 'string', 'min:2', 'max:120'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:10', 'regex:/[A-Za-z]/', 'regex:/[0-9]/'],
        ]);

        if ($validator->fails()) {
            foreach ($validator->errors()->all() as $error) {
                $this->error($error);
            }

            return self::FAILURE;
        }

        DB::transaction(function () use ($name, $email, $password) {
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'password' => Hash::make($password),
                'email_verified_at' => now(),
                'is_active' => true,
            ]);

            $role = Role::firstOrCreate(['name' => 'super_admin']);
            $user->roles()->syncWithoutDetaching([$role->id]);

            AuditLog::create([
                'actor_user_id' => null,
                'action' => 'user.super_admin_created',
                'entity_type' => $user->getMorphClass(),
                'entity_id' => $user->id,
                'metadata' => ['email' => $email, 'source' => 'console'],
                'created_at' => now(),
            ]);
        });

        $this->info('Super admin created successfully.');

        return self::SUCCESS;
    }
}
