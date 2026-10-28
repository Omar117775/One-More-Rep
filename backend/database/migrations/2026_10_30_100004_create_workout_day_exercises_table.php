<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_day_exercises', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workout_program_day_id')->constrained('workout_program_days')->cascadeOnDelete();
            $table->foreignId('exercise_id')->constrained('exercises')->restrictOnDelete();
            $table->unsignedSmallInteger('sort_order');
            $table->unsignedSmallInteger('target_sets')->default(3);
            $table->unsignedSmallInteger('target_reps_min');
            $table->unsignedSmallInteger('target_reps_max');
            $table->decimal('target_weight_kg', 6, 2)->nullable();
            $table->unsignedSmallInteger('rest_seconds')->nullable();
            $table->timestamps();

            $table->unique(['workout_program_day_id', 'sort_order']);
            $table->index('exercise_id');
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('ALTER TABLE workout_day_exercises ADD CONSTRAINT workout_day_exercises_sort_check CHECK (sort_order BETWEEN 0 AND 50)');
            DB::statement('ALTER TABLE workout_day_exercises ADD CONSTRAINT workout_day_exercises_sets_check CHECK (target_sets BETWEEN 1 AND 20)');
            DB::statement('ALTER TABLE workout_day_exercises ADD CONSTRAINT workout_day_exercises_reps_check CHECK (target_reps_min BETWEEN 1 AND 100 AND target_reps_max BETWEEN 1 AND 100 AND target_reps_min <= target_reps_max)');
            DB::statement('ALTER TABLE workout_day_exercises ADD CONSTRAINT workout_day_exercises_weight_check CHECK (target_weight_kg IS NULL OR (target_weight_kg >= 0 AND target_weight_kg <= 1000))');
            DB::statement('ALTER TABLE workout_day_exercises ADD CONSTRAINT workout_day_exercises_rest_check CHECK (rest_seconds IS NULL OR (rest_seconds >= 0 AND rest_seconds <= 3600))');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_day_exercises');
    }
};
