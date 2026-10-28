<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_programs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('coach_id')->constrained('users')->cascadeOnDelete();
            $table->string('name', 120);
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['coach_id', 'is_active']);
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('ALTER TABLE workout_programs ADD CONSTRAINT workout_programs_name_check CHECK (char_length(trim(name)) >= 2)');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_programs');
    }
};
