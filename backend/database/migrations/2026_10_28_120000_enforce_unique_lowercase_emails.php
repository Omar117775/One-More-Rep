<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Note: CREATE UNIQUE INDEX CONCURRENTLY cannot run inside a transaction in PostgreSQL.
     * Laravel wraps migrations in transactions by default for some drivers; we disable it for pgsql.
     */
    public $withinTransaction = false;

    public function up(): void
    {
        $driver = DB::connection()->getDriverName();

        if ($driver === 'pgsql') {
            // Create a unique functional index on lower(email). CONCURRENTLY avoids locking writes.
            // If the index already exists, this will error - in that case, skip or use IF NOT EXISTS pattern carefully.
            DB::statement('CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS users_email_lower_unique ON users (LOWER(email))');
        } elseif ($driver === 'sqlite') {
            // SQLite has limited support for functional indexes; application enforces case-insensitive uniqueness.
            // No-op or add trigger if needed - not critical for dev.
        }
        // Other drivers: rely on application-level enforcement.
    }

    public function down(): void
    {
        $driver = DB::connection()->getDriverName();

        if ($driver === 'pgsql') {
            DB::statement('DROP INDEX CONCURRENTLY IF EXISTS users_email_lower_unique');
        }
    }
};
