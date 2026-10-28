<?php

namespace App\Enums\Enums;

enum ExerciseMuscleGroup: string
{
    case CHEST = 'chest';
    case BACK = 'back';
    case SHOULDERS = 'shoulders';
    case BICEPS = 'biceps';
    case TRICEPS = 'triceps';
    case LEGS = 'legs';
    case GLUTES = 'glutes';
    case CORE = 'core';
    case FULL_BODY = 'full_body';
    case CARDIO = 'cardio';

    /** @return list<string> */
    public static function values(): array
    {
        return array_map(fn (self $case) => $case->value, self::cases());
    }
}
