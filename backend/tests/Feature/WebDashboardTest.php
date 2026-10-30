<?php

namespace Tests\Feature;

use App\Models\Role;
use App\Models\User;

class WebDashboardTest extends FeatureTestCase
{
    public function test_login_page_renders_successfully(): void
    {
        $response = $this->get('/login');
        $response->assertStatus(200);
        $response->assertSee('ONE MORE REP');
        $response->assertSee('Sign In to Console');
    }

    public function test_unauthenticated_user_redirected_to_login(): void
    {
        $response = $this->get('/coach/dashboard');
        $response->assertRedirect('/login');

        $response = $this->get('/admin/dashboard');
        $response->assertRedirect('/login');
    }

    public function test_trainee_cannot_access_coach_or_admin_dashboard(): void
    {
        $traineeRole = Role::firstOrCreate(['name' => 'trainee']);
        $trainee = User::factory()->create(['is_active' => true]);
        $trainee->roles()->attach($traineeRole->id);

        $response = $this->actingAs($trainee)->get('/coach/dashboard');
        $response->assertStatus(403);

        $response = $this->actingAs($trainee)->get('/admin/dashboard');
        $response->assertStatus(403);
    }

    public function test_coach_can_access_coach_dashboard_but_not_admin(): void
    {
        $coachRole = Role::firstOrCreate(['name' => 'coach']);
        $coach = User::factory()->create(['is_active' => true]);
        $coach->roles()->attach($coachRole->id);

        $response = $this->actingAs($coach)->get('/coach/dashboard');
        $response->assertStatus(200);
        $response->assertSee('Coach Suite');

        $response = $this->actingAs($coach)->get('/admin/dashboard');
        $response->assertStatus(403);
    }

    public function test_super_admin_can_access_admin_dashboard(): void
    {
        $adminRole = Role::firstOrCreate(['name' => 'super_admin']);
        $admin = User::factory()->create(['is_active' => true]);
        $admin->roles()->attach($adminRole->id);

        $response = $this->actingAs($admin)->get('/admin/dashboard');
        $response->assertStatus(200);
        $response->assertSee('Global System Analytics');

        $response = $this->actingAs($admin)->get('/admin/users');
        $response->assertStatus(200);
        $response->assertSee('All System Accounts');
    }

    public function test_coach_web_login_flow(): void
    {
        $coachRole = Role::firstOrCreate(['name' => 'coach']);
        $coach = User::factory()->create([
            'email' => 'webcoach@test.fit',
            'password' => bcrypt('password123'),
            'is_active' => true,
        ]);
        $coach->roles()->attach($coachRole->id);

        $response = $this->post('/login', [
            'email' => 'webcoach@test.fit',
            'password' => 'password123',
        ]);

        $response->assertRedirect('/coach/dashboard');
        $this->assertAuthenticatedAs($coach);
    }

    public function test_admin_web_login_flow(): void
    {
        $adminRole = Role::firstOrCreate(['name' => 'super_admin']);
        $admin = User::factory()->create([
            'email' => 'webadmin@test.fit',
            'password' => bcrypt('password123'),
            'is_active' => true,
        ]);
        $admin->roles()->attach($adminRole->id);

        $response = $this->post('/login', [
            'email' => 'webadmin@test.fit',
            'password' => 'password123',
        ]);

        $response->assertRedirect('/admin/dashboard');
        $this->assertAuthenticatedAs($admin);
    }

    public function test_web_logout(): void
    {
        $adminRole = Role::firstOrCreate(['name' => 'super_admin']);
        $admin = User::factory()->create(['is_active' => true]);
        $admin->roles()->attach($adminRole->id);

        $response = $this->actingAs($admin)->post('/logout');
        $response->assertRedirect('/login');
        $this->assertGuest();
    }
}
