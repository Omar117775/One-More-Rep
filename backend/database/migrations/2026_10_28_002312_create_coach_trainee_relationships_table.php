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
        Schema::create('coach_trainee_relationships', function (Blueprint $table) {
            $table->id();
            $table->foreignId('coach_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('trainee_id')->constrained('users')->cascadeOnDelete();
            $table->string('relationship_type', 20)->default('primary');
            $table->string('status', 20)->default('active');
            $table->timestamp('started_at')->nullable();
            $table->timestamp('ended_at')->nullable();
            $table->timestamps();

            $table->index(['coach_id', 'status']);
            $table->index(['trainee_id', 'status']);
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('CREATE UNIQUE INDEX coach_trainee_relationships_active_pair_unique ON coach_trainee_relationships (coach_id, trainee_id) WHERE status = \'active\'');
            DB::statement('CREATE UNIQUE INDEX coach_trainee_relationships_active_primary_unique ON coach_trainee_relationships (trainee_id) WHERE relationship_type = \'primary\' AND status = \'active\'');
            DB::statement('ALTER TABLE coach_trainee_relationships ADD CONSTRAINT coach_trainee_relationships_not_self CHECK (coach_id <> trainee_id)');
            DB::statement("ALTER TABLE coach_trainee_relationships ADD CONSTRAINT coach_trainee_relationships_type_check CHECK (relationship_type IN ('primary', 'secondary'))");
            DB::statement("ALTER TABLE coach_trainee_relationships ADD CONSTRAINT coach_trainee_relationships_status_check CHECK (status IN ('active', 'ended'))");
            DB::statement('ALTER TABLE coach_trainee_relationships ADD CONSTRAINT coach_trainee_relationships_state_check CHECK ((status = \'active\' AND ended_at IS NULL AND started_at IS NOT NULL) OR (status = \'ended\' AND ended_at IS NOT NULL))');
        } else {
            // SQLite: partial unique indexes limited; service validation enforces rules
            try {
                DB::statement('CREATE UNIQUE INDEX IF NOT EXISTS coach_trainee_relationships_active_pair_unique ON coach_trainee_relationships (coach_id, trainee_id) WHERE status = \'active\'');
            } catch (Throwable $e) {
                // ignore if not supported
            }
            try {
                DB::statement('CREATE UNIQUE INDEX IF NOT EXISTS coach_trainee_relationships_active_primary_unique ON coach_trainee_relationships (trainee_id) WHERE relationship_type = \'primary\' AND status = \'active\'');
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
        Schema::dropIfExists('coach_trainee_relationships');
    }
};
