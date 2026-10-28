<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Dated trainee progress records using the documented ERD body-measurement
     * fields. Records are historical and are never overwritten by later entries.
     */
    public function up(): void
    {
        Schema::create('body_measurements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('trainee_id')->constrained('users')->cascadeOnDelete();
            $table->decimal('weight_kg', 6, 2)->nullable();
            $table->decimal('body_fat_percentage', 5, 2)->nullable();
            $table->decimal('waist_cm', 6, 2)->nullable();
            $table->decimal('chest_cm', 6, 2)->nullable();
            $table->decimal('arm_cm', 6, 2)->nullable();
            $table->date('measured_on');
            $table->timestamps();

            $table->index(['trainee_id', 'measured_on']);
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('ALTER TABLE body_measurements ADD CONSTRAINT body_measurements_weight_check CHECK (weight_kg IS NULL OR (weight_kg >= 20 AND weight_kg <= 500))');
            DB::statement('ALTER TABLE body_measurements ADD CONSTRAINT body_measurements_body_fat_check CHECK (body_fat_percentage IS NULL OR (body_fat_percentage >= 0 AND body_fat_percentage <= 100))');
            DB::statement('ALTER TABLE body_measurements ADD CONSTRAINT body_measurements_waist_check CHECK (waist_cm IS NULL OR (waist_cm >= 20 AND waist_cm <= 300))');
            DB::statement('ALTER TABLE body_measurements ADD CONSTRAINT body_measurements_chest_check CHECK (chest_cm IS NULL OR (chest_cm >= 20 AND chest_cm <= 300))');
            DB::statement('ALTER TABLE body_measurements ADD CONSTRAINT body_measurements_arm_check CHECK (arm_cm IS NULL OR (arm_cm >= 5 AND arm_cm <= 150))');
            DB::statement('ALTER TABLE body_measurements ADD CONSTRAINT body_measurements_has_value_check CHECK (weight_kg IS NOT NULL OR body_fat_percentage IS NOT NULL OR waist_cm IS NOT NULL OR chest_cm IS NOT NULL OR arm_cm IS NOT NULL)');
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('body_measurements');
    }
};
