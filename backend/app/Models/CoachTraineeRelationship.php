<?php

namespace App\Models;

use App\Enums\Enums\RelationshipStatus;
use App\Enums\Enums\RelationshipType;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CoachTraineeRelationship extends Model
{
    use HasFactory;

    protected $fillable = ['coach_id', 'trainee_id', 'relationship_type', 'status', 'started_at', 'responded_at', 'ended_at'];

    protected function casts(): array
    {
        return [
            'relationship_type' => RelationshipType::class,
            'status' => RelationshipStatus::class,
            'started_at' => 'datetime',
            'responded_at' => 'datetime',
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

    public function scopeActive(Builder $query): Builder
    {
        return $query->where('status', RelationshipStatus::ACTIVE)->whereNull('ended_at');
    }

    public function scopePending(Builder $query): Builder
    {
        return $query->where('status', RelationshipStatus::PENDING);
    }

    public function scopePrimary(Builder $query): Builder
    {
        return $query->where('relationship_type', RelationshipType::PRIMARY);
    }

    public function scopeForCoach(Builder $query, User $coach): Builder
    {
        return $query->where('coach_id', $coach->id);
    }

    public function scopeForTrainee(Builder $query, User $trainee): Builder
    {
        return $query->where('trainee_id', $trainee->id);
    }

    public function isPending(): bool
    {
        return $this->status === RelationshipStatus::PENDING;
    }

    public function isActive(): bool
    {
        return $this->status === RelationshipStatus::ACTIVE;
    }

    public function isPrimary(): bool
    {
        return $this->relationship_type === RelationshipType::PRIMARY;
    }
}
