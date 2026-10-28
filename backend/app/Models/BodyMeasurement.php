<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class BodyMeasurement extends Model
{
    use HasFactory;

    protected $fillable = [
        'trainee_id',
        'weight_kg',
        'body_fat_percentage',
        'waist_cm',
        'chest_cm',
        'arm_cm',
        'measured_on',
    ];

    protected function casts(): array
    {
        return [
            'weight_kg' => 'decimal:2',
            'body_fat_percentage' => 'decimal:2',
            'waist_cm' => 'decimal:2',
            'chest_cm' => 'decimal:2',
            'arm_cm' => 'decimal:2',
            'measured_on' => 'date',
        ];
    }

    public function trainee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'trainee_id');
    }
}
