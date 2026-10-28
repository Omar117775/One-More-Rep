<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workout_program_id')->constrained('workout_programs')->restrictOnDelete();
            $table->foreignId('trainee_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('assigned_by')->nullable()->constrained('users')->nullOnDelete();
            $table->date('starts_on');
            $table->date('ends_on')->nullable();
            $table->string('status', 16)->default('active');
            $table->timestamps();

            $table->index(['trainee_id', 'status']);
            $table->index(['workout_program_id', 'status']);
        });

        DB::statement("CREATE UNIQUE INDEX workout_assignments_active_unique ON workout_assignments (workout_program_id, trainee_id) WHERE status = 'active'");

        if (DB::getDriverName() === 'pgsql') {
            DB::statement("ALTER TABLE workout_assignments ADD CONSTRAINT workout_assignments_status_check CHECK (status IN ('active', 'ended'))");
            DB::statement('ALTER TABLE workout_assignments ADD CONSTRAINT workout_assignments_dates_check CHECK (ends_on IS NULL OR ends_on >= starts_on)');
            DB::statement("ALTER TABLE workout_assignments ADD CONSTRAINT workout_assignments_ended_check CHECK (status <> 'ended' OR ends_on IS NOT NULL)");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_assignments');
    }
};
