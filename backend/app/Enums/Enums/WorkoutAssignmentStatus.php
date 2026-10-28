<?php

namespace App\Enums\Enums;

enum WorkoutAssignmentStatus: string
{
    case ACTIVE = 'active';
    case ENDED = 'ended';

    /** @return list<string> */
    public static function values(): array
    {
        return array_map(fn (self $case) => $case->value, self::cases());
    }
}
