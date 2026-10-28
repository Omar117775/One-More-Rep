<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workout_program_days', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workout_program_id')->constrained('workout_programs')->cascadeOnDelete();
            $table->unsignedTinyInteger('day_number');
            $table->string('name', 100);
            $table->timestamps();

            $table->unique(['workout_program_id', 'day_number']);
        });

        if (DB::getDriverName() === 'pgsql') {
            DB::statement('ALTER TABLE workout_program_days ADD CONSTRAINT workout_program_days_number_check CHECK (day_number BETWEEN 1 AND 7)');
            DB::statement('ALTER TABLE workout_program_days ADD CONSTRAINT workout_program_days_name_check CHECK (char_length(trim(name)) >= 2)');
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('workout_program_days');
    }
};
