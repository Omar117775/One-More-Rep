<?php

namespace Tests\Integration;

use Illuminate\Support\Facades\DB;

class ExampleTest extends IntegrationTestCase
{
    public function test_can_connect_to_postgres_test_database(): void
    {
        $this->assertEquals('pgsql', DB::connection()->getDriverName());
        $database = DB::connection()->getDatabaseName();
        $this->assertStringEndsWith('_test', $database);
    }
}
