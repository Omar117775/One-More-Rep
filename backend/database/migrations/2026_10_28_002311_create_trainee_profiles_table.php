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
        Schema::create('trainee_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->date('date_of_birth')->nullable();
            $table->string('sex', 20)->nullable();
            $table->decimal('height_cm', 5, 2)->nullable();
            $table->decimal('initial_weight_kg', 6, 2)->nullable();
            $table->timestamps();
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement("ALTER TABLE trainee_profiles ADD CONSTRAINT trainee_profiles_sex_check CHECK (sex IS NULL OR sex IN ('male', 'female', 'other', 'prefer_not_to_say'))");
            DB::statement('ALTER TABLE trainee_profiles ADD CONSTRAINT trainee_profiles_height_check CHECK (height_cm IS NULL OR (height_cm >= 50 AND height_cm <= 300))');
            DB::statement('ALTER TABLE trainee_profiles ADD CONSTRAINT trainee_profiles_weight_check CHECK (initial_weight_kg IS NULL OR (initial_weight_kg >= 20 AND initial_weight_kg <= 500))');
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('trainee_profiles');
    }
};
