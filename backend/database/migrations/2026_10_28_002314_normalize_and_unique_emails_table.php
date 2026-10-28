<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (DB::getDriverName() === 'pgsql') {
            // Pre-check for case-insensitive duplicates
            $duplicates = DB::select('SELECT LOWER(email) as email_lower, COUNT(*) as cnt FROM users GROUP BY LOWER(email) HAVING COUNT(*) > 1');
            if (! empty($duplicates)) {
                $details = [];
                foreach ($duplicates as $dup) {
                    $details[] = $dup->email_lower.' ('.$dup->cnt.' records)';
                }
                throw new RuntimeException('Case-insensitive email duplicates detected. Resolve before migration: '.implode(', ', $details));
            }

            // Normalize emails to lowercase
            DB::statement('UPDATE users SET email = LOWER(TRIM(email))');

            // Add functional unique index
            DB::statement('CREATE UNIQUE INDEX users_email_lower_unique ON users (LOWER(email))');
        } else {
            // SQLite: normalize emails
            $users = DB::table('users')->get();
            foreach ($users as $user) {
                $normalized = strtolower(trim($user->email));
                if ($normalized !== $user->email) {
                    DB::table('users')->where('id', $user->id)->update(['email' => $normalized]);
                }
            }
            // Application enforces case-insensitive uniqueness
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (DB::getDriverName() === 'pgsql') {
            DB::statement('DROP INDEX IF EXISTS users_email_lower_unique');
        }
        // Email normalization not reverted
    }
};
