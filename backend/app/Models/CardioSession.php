<?php

namespace App\Models;

use App\Enums\Enums\CardioActivityType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CardioSession extends Model
{
    use HasFactory;

    protected $fillable = [
        'trainee_id',
        'activity_type',
        'duration_seconds',
        'distance_km',
        'average_heart_rate',
        'performed_at',
    ];

    protected function casts(): array
    {
        return [
            'activity_type' => CardioActivityType::class,
            'duration_seconds' => 'integer',
            'distance_km' => 'decimal:2',
            'average_heart_rate' => 'integer',
            'performed_at' => 'datetime',
        ];
    }

    public function trainee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'trainee_id');
    }
}
