<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Public and coach-owned exercises. A coach-created exercise is private by
     * default and can be shared publicly by its owner.
     */
    public function up(): void
    {
        Schema::create('exercises', function (Blueprint $table) {
            $table->id();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->string('name', 120);
            $table->string('muscle_group', 32);
            $table->string('equipment', 32)->nullable();
            $table->text('instructions')->nullable();
            $table->boolean('is_public')->default(false);
            $table->timestamps();

            $table->index(['is_public', 'muscle_group']);
            $table->index('created_by');
            $table->index('name');
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('ALTER TABLE exercises ADD CONSTRAINT exercises_name_check CHECK (char_length(trim(name)) >= 2)');
            DB::statement("ALTER TABLE exercises ADD CONSTRAINT exercises_muscle_group_check CHECK (muscle_group IN ('chest', 'back', 'shoulders', 'biceps', 'triceps', 'legs', 'glutes', 'core', 'full_body', 'cardio'))");
            DB::statement("ALTER TABLE exercises ADD CONSTRAINT exercises_equipment_check CHECK (equipment IS NULL OR equipment IN ('barbell', 'dumbbell', 'machine', 'cable', 'bodyweight', 'kettlebell', 'resistance_band', 'other'))");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('exercises');
    }
};
