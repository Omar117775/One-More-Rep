<?php

namespace Tests\Integration;

use Database\Seeders\RoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Tests\TestCase;

abstract class IntegrationTestCase extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $default = Config::get('database.default');
        $connection = Config::get("database.connections.{$default}");
        $driver = $connection['driver'] ?? null;
        $database = $connection['database'] ?? null;

        if ($driver !== 'pgsql') {
            throw new \RuntimeException('PostgreSQL integration tests must use the pgsql driver only.');
        }

        if (! is_string($database) || ! str_ends_with($database, '_test')) {
            throw new \RuntimeException("PostgreSQL integration tests must use a dedicated *_test database. Got [{$database}]. Refusing to run against development database.");
        }

        $this->seed(RoleSeeder::class);
    }
}
