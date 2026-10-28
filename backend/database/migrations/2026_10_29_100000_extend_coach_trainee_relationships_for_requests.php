<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('coach_trainee_relationships', function (Blueprint $table) {
            $table->timestamp('responded_at')->nullable();
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('ALTER TABLE coach_trainee_relationships DROP CONSTRAINT IF EXISTS coach_trainee_relationships_status_check');
            DB::statement('ALTER TABLE coach_trainee_relationships DROP CONSTRAINT IF EXISTS coach_trainee_relationships_state_check');

            DB::statement("ALTER TABLE coach_trainee_relationships ADD CONSTRAINT coach_trainee_relationships_status_check CHECK (status IN ('pending', 'active', 'rejected', 'cancelled', 'ended'))");
            DB::statement(
                "ALTER TABLE coach_trainee_relationships ADD CONSTRAINT coach_trainee_relationships_state_check CHECK (
                    (status = 'pending' AND started_at IS NULL AND ended_at IS NULL AND responded_at IS NULL)
                    OR (status = 'active' AND started_at IS NOT NULL AND ended_at IS NULL)
                    OR (status = 'rejected' AND started_at IS NULL AND ended_at IS NOT NULL AND responded_at IS NOT NULL)
                    OR (status = 'cancelled' AND started_at IS NULL AND ended_at IS NOT NULL AND responded_at IS NULL)
                    OR (status = 'ended' AND started_at IS NOT NULL AND ended_at IS NOT NULL)
                )"
            );

            DB::statement('CREATE UNIQUE INDEX coach_trainee_relationships_pending_pair_unique ON coach_trainee_relationships (coach_id, trainee_id) WHERE status = \'pending\'');
            DB::statement('CREATE UNIQUE INDEX coach_trainee_relationships_pending_primary_unique ON coach_trainee_relationships (trainee_id) WHERE relationship_type = \'primary\' AND status = \'pending\'');
        } else {
            // SQLite supports partial indexes; service validation remains the primary guard.
            try {
                DB::statement('CREATE UNIQUE INDEX IF NOT EXISTS coach_trainee_relationships_pending_pair_unique ON coach_trainee_relationships (coach_id, trainee_id) WHERE status = \'pending\'');
            } catch (Throwable $e) {
                // ignore if not supported
            }

            try {
                DB::statement('CREATE UNIQUE INDEX IF NOT EXISTS coach_trainee_relationships_pending_primary_unique ON coach_trainee_relationships (trainee_id) WHERE relationship_type = \'primary\' AND status = \'pending\'');
            } catch (Throwable $e) {
                // ignore if not supported
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement('DROP INDEX IF EXISTS coach_trainee_relationships_pending_pair_unique');
        DB::statement('DROP INDEX IF EXISTS coach_trainee_relationships_pending_primary_unique');

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('ALTER TABLE coach_trainee_relationships DROP CONSTRAINT IF EXISTS coach_trainee_relationships_status_check');
            DB::statement('ALTER TABLE coach_trainee_relationships DROP CONSTRAINT IF EXISTS coach_trainee_relationships_state_check');

            // Existing request rows cannot satisfy the legacy status check; close them.
            DB::statement(
                "UPDATE coach_trainee_relationships
                 SET status = 'ended',
                     started_at = COALESCE(started_at, created_at),
                     ended_at = COALESCE(ended_at, NOW()),
                     responded_at = NULL
                 WHERE status IN ('pending', 'rejected', 'cancelled')"
            );

            DB::statement("ALTER TABLE coach_trainee_relationships ADD CONSTRAINT coach_trainee_relationships_status_check CHECK (status IN ('active', 'ended'))");
            DB::statement("ALTER TABLE coach_trainee_relationships ADD CONSTRAINT coach_trainee_relationships_state_check CHECK ((status = 'active' AND ended_at IS NULL AND started_at IS NOT NULL) OR (status = 'ended' AND ended_at IS NOT NULL))");
        }

        Schema::table('coach_trainee_relationships', function (Blueprint $table) {
            $table->dropColumn('responded_at');
        });
    }
};
