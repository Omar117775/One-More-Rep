<?php

namespace App\Enums\Enums;

enum RelationshipStatus: string
{
    case PENDING = 'pending';
    case ACTIVE = 'active';
    case REJECTED = 'rejected';
    case CANCELLED = 'cancelled';
    case ENDED = 'ended';

    /**
     * @return list<string>
     */
    public static function values(): array
    {
        return array_map(fn (self $case) => $case->value, self::cases());
    }
}
