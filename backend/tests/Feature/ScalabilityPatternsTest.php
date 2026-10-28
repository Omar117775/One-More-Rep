<?php

namespace Tests\Feature;

use App\Support\Pagination\PaginationConfig;
use Tests\TestCase;

class ScalabilityPatternsTest extends TestCase
{
    public function test_pagination_config_has_safe_defaults_and_max(): void
    {
        $this->assertSame(15, PaginationConfig::DEFAULT_PER_PAGE);
        $this->assertSame(100, PaginationConfig::MAX_PER_PAGE);
        $this->assertSame(15, PaginationConfig::perPage(null));
        $this->assertSame(15, PaginationConfig::perPage(0));
        $this->assertSame(15, PaginationConfig::perPage(-5));
        $this->assertSame(50, PaginationConfig::perPage(50));
        $this->assertSame(100, PaginationConfig::perPage(150));
        $this->assertSame(100, PaginationConfig::perPage(1000));
    }
}
