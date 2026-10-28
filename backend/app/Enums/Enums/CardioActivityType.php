<?php

namespace App\Enums\Enums;

enum CardioActivityType: string
{
    case RUNNING = 'running';
    case WALKING = 'walking';
    case CYCLING = 'cycling';
    case SWIMMING = 'swimming';
    case ROWING = 'rowing';
    case JUMP_ROPE = 'jump_rope';
    case ELLIPTICAL = 'elliptical';
    case HIIT = 'hiit';
    case OTHER = 'other';

    /** @return list<string> */
    public static function values(): array
    {
        return array_map(fn (self $case) => $case->value, self::cases());
    }
}
