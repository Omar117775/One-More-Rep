<?php

namespace App\Models;

use App\Enums\Enums\RelationshipStatus;
use App\Enums\Enums\RelationshipType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CoachTraineeRelationship extends Model
{
    use HasFactory;

    protected $fillable = ['coach_id', 'trainee_id', 'relationship_type', 'status', 'started_at', 'ended_at'];

    protected function casts(): array
    {
        return [
            'relationship_type' => RelationshipType::class,
            'status' => RelationshipStatus::class,
            'started_at' => 'datetime',
            'ended_at' => 'datetime',
        ];
    }

    public function coach(): BelongsTo
    {
        return $this->belongsTo(User::class, 'coach_id');
    }

    public function trainee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'trainee_id');
    }

    public function scopeActive($query)
    {
        return $query->where('status', RelationshipStatus::ACTIVE)->whereNull('ended_at');
    }

    public function scopePrimary($query)
    {
        return $query->where('relationship_type', RelationshipType::PRIMARY);
    }

    public function scopeForCoach($query, User $coach)
    {
        return $query->where('coach_id', $coach->id);
    }

    public function scopeForTrainee($query, User $trainee)
    {
        return $query->where('trainee_id', $trainee->id);
    }
}
