<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workout_assignment_id')->constrained('workout_assignments')->restrictOnDelete();
            $table->foreignId('trainee_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('started_at');
            $table->timestamp('completed_at')->nullable();
            $table->text('notes')->nullable();
            $table->timestamps();

            $table->index(['trainee_id', 'started_at']);
            $table->index('workout_assignment_id');
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('ALTER TABLE workout_sessions ADD CONSTRAINT workout_sessions_completed_check CHECK (completed_at IS NULL OR completed_at >= started_at)');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_sessions');
    }
};
