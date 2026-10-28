<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class TraineeProfile extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'date_of_birth', 'sex', 'height_cm', 'initial_weight_kg'];

    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date',
            'height_cm' => 'decimal:2',
            'initial_weight_kg' => 'decimal:2',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
