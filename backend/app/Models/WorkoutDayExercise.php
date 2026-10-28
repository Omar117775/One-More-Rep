<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WorkoutDayExercise extends Model
{
    use HasFactory;

    protected $fillable = [
        'workout_program_day_id',
        'exercise_id',
        'sort_order',
        'target_sets',
        'target_reps_min',
        'target_reps_max',
        'target_weight_kg',
        'rest_seconds',
    ];

    protected function casts(): array
    {
        return [
            'sort_order' => 'integer',
            'target_sets' => 'integer',
            'target_reps_min' => 'integer',
            'target_reps_max' => 'integer',
            'target_weight_kg' => 'decimal:2',
            'rest_seconds' => 'integer',
        ];
    }

    public function day(): BelongsTo
    {
        return $this->belongsTo(WorkoutProgramDay::class, 'workout_program_day_id');
    }

    public function exercise(): BelongsTo
    {
        return $this->belongsTo(Exercise::class);
    }
}
