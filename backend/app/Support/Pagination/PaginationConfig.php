<?php

namespace App\Support\Pagination;

class PaginationConfig
{
    public const DEFAULT_PER_PAGE = 15;

    public const MAX_PER_PAGE = 100;

    public static function perPage(?int $perPage = null): int
    {
        if ($perPage === null) {
            return self::DEFAULT_PER_PAGE;
        }

        if ($perPage < 1) {
            return self::DEFAULT_PER_PAGE;
        }

        if ($perPage > self::MAX_PER_PAGE) {
            return self::MAX_PER_PAGE;
        }

        return $perPage;
    }
}
