<?php

namespace App\Models;

use App\Enums\Enums\WorkoutAssignmentStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class WorkoutAssignment extends Model
{
    use HasFactory;

    protected $fillable = [
        'workout_program_id',
        'trainee_id',
        'assigned_by',
        'starts_on',
        'ends_on',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'starts_on' => 'date',
            'ends_on' => 'date',
            'status' => WorkoutAssignmentStatus::class,
        ];
    }

    public function program(): BelongsTo
    {
        return $this->belongsTo(WorkoutProgram::class, 'workout_program_id');
    }

    public function trainee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'trainee_id');
    }

    public function assignedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_by');
    }

    public function sessions(): HasMany
    {
        return $this->hasMany(WorkoutSession::class);
    }
}
