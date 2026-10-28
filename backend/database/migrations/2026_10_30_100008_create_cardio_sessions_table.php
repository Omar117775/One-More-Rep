<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cardio_sessions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trainee_id')->constrained('users')->cascadeOnDelete();
            $table->string('activity_type', 24);
            $table->unsignedInteger('duration_seconds');
            $table->decimal('distance_km', 7, 2)->nullable();
            $table->unsignedSmallInteger('average_heart_rate')->nullable();
            $table->timestamp('performed_at');
            $table->timestamps();

            $table->index(['trainee_id', 'performed_at']);
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement("ALTER TABLE cardio_sessions ADD CONSTRAINT cardio_sessions_activity_check CHECK (activity_type IN ('running', 'walking', 'cycling', 'swimming', 'rowing', 'jump_rope', 'elliptical', 'hiit', 'other'))");
            DB::statement('ALTER TABLE cardio_sessions ADD CONSTRAINT cardio_sessions_duration_check CHECK (duration_seconds BETWEEN 1 AND 86400)');
            DB::statement('ALTER TABLE cardio_sessions ADD CONSTRAINT cardio_sessions_distance_check CHECK (distance_km IS NULL OR (distance_km >= 0 AND distance_km <= 1000))');
            DB::statement('ALTER TABLE cardio_sessions ADD CONSTRAINT cardio_sessions_heart_rate_check CHECK (average_heart_rate IS NULL OR (average_heart_rate >= 30 AND average_heart_rate <= 250))');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('cardio_sessions');
    }
};
