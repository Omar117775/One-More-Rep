<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_sets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workout_session_id')->constrained('workout_sessions')->cascadeOnDelete();
            $table->foreignId('exercise_id')->constrained('exercises')->restrictOnDelete();
            $table->unsignedSmallInteger('set_number');
            $table->decimal('weight_kg', 6, 2)->nullable();
            $table->unsignedSmallInteger('reps');
            $table->boolean('is_completed')->default(true);
            $table->timestamps();

            $table->unique(['workout_session_id', 'exercise_id', 'set_number']);
            $table->index('exercise_id');
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('ALTER TABLE workout_sets ADD CONSTRAINT workout_sets_number_check CHECK (set_number BETWEEN 1 AND 100)');
            DB::statement('ALTER TABLE workout_sets ADD CONSTRAINT workout_sets_reps_check CHECK (reps BETWEEN 1 AND 1000)');
            DB::statement('ALTER TABLE workout_sets ADD CONSTRAINT workout_sets_weight_check CHECK (weight_kg IS NULL OR (weight_kg >= 0 AND weight_kg <= 1000))');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_sets');
    }
};
