<?php

namespace Tests\Feature;

use Database\Seeders\RoleSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Tests\TestCase;

abstract class FeatureTestCase extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        $default = Config::get('database.default');
        $connection = Config::get("database.connections.{$default}");
        $driver = $connection['driver'] ?? null;
        $database = $connection['database'] ?? null;

        if ($driver !== 'sqlite' || $database !== ':memory:') {
            throw new \RuntimeException('Feature tests must run on SQLite :memory: only. Refusing to use any other database.');
        }

        $this->seed(RoleSeeder::class);
    }
}
