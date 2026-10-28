<?php

namespace App\Enums\Enums;

enum ExerciseEquipment: string
{
    case BARBELL = 'barbell';
    case DUMBBELL = 'dumbbell';
    case MACHINE = 'machine';
    case CABLE = 'cable';
    case BODYWEIGHT = 'bodyweight';
    case KETTLEBELL = 'kettlebell';
    case RESISTANCE_BAND = 'resistance_band';
    case OTHER = 'other';

    /** @return list<string> */
    public static function values(): array
    {
        return array_map(fn (self $case) => $case->value, self::cases());
    }
}
