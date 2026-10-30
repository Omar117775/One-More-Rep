<?php

namespace App\Http\Controllers\Web\Admin;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\CoachTraineeRelationship;
use App\Models\Exercise;
use App\Models\Role;
use App\Models\User;
use App\Models\WorkoutProgram;
use App\Models\WorkoutSession;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;

class AdminDashboardController extends Controller
{
    public function index(): View
    {
        $admin = Auth::user();

        // Global User Counts
        $totalUsers = User::count();
        $traineeCount = User::whereHas('roles', fn ($q) => $q->where('name', 'trainee'))->count();
        $coachCount = User::whereHas('roles', fn ($q) => $q->where('name', 'coach'))->count();
        $adminCount = User::whereHas('roles', fn ($q) => $q->where('name', 'super_admin'))->count();

        // System Activity Counts
        $activeRelationships = CoachTraineeRelationship::where('status', 'active')->count();
        $totalPrograms = WorkoutProgram::count();
        $totalExercises = Exercise::count();
        $totalSessionsLogged = WorkoutSession::count();

        // Recent Audit Logs
        $recentAuditLogs = AuditLog::with('user')->latest()->take(8)->get();

        // Recent User Registrations
        $recentUsers = User::with('roles')->latest()->take(6)->get();

        return view('admin.dashboard', [
            'admin' => $admin,
            'totalUsers' => $totalUsers,
            'traineeCount' => $traineeCount,
            'coachCount' => $coachCount,
            'adminCount' => $adminCount,
            'activeRelationships' => $activeRelationships,
            'totalPrograms' => $totalPrograms,
            'totalExercises' => $totalExercises,
            'totalSessionsLogged' => $totalSessionsLogged,
            'recentAuditLogs' => $recentAuditLogs,
            'recentUsers' => $recentUsers,
        ]);
    }

    public function users(Request $request): View
    {
        $query = User::with(['roles', 'traineeProfile', 'coachProfile']);

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        if ($role = $request->input('role')) {
            $query->whereHas('roles', fn ($q) => $q->where('name', $role));
        }

        if ($request->has('active') && $request->input('active') !== '') {
            $query->where('is_active', $request->boolean('active'));
        }

        $users = $query->latest()->paginate(20)->withQueryString();
        $roles = Role::all();

        return view('admin.users.index', [
            'users' => $users,
            'roles' => $roles,
            'search' => $search,
            'currentRole' => $role,
        ]);
    }

    public function toggleUserStatus(int $id): RedirectResponse
    {
        $user = User::findOrFail($id);

        // Prevent admin from disabling their own account
        if ($user->id === Auth::id()) {
            return back()->with('error', 'You cannot disable your own administrator account.');
        }

        $user->is_active = ! $user->is_active;
        $user->save();

        $action = $user->is_active ? 'enabled' : 'disabled';

        // Log audit event
        AuditLog::create([
            'user_id' => Auth::id(),
            'action' => "user.{$action}",
            'auditable_type' => User::class,
            'auditable_id' => $user->id,
            'ip_address' => request()->ip(),
            'payload' => ['target_user_email' => $user->email],
        ]);

        return back()->with('success', "User account {$user->email} has been {$action}.");
    }

    public function subscriptions(): View
    {
        $plans = [
            [
                'name' => 'Monthly Spartan',
                'duration' => '30 Days',
                'price_egp' => 650,
                'price_usd' => 19.99,
                'features' => ['Unlimited workouts', 'Full exercise library', 'Standard analytics', 'Rest timer'],
                'active_members' => 42,
            ],
            [
                'name' => 'Yearly Titan',
                'duration' => '365 Days',
                'price_egp' => 5400,
                'price_usd' => 149.99,
                'features' => ['All Monthly features', 'Priority AI Coach access', 'Advanced biometric charts', '30% savings'],
                'active_members' => 128,
            ],
            [
                'name' => 'Spartan Elite (Coached)',
                'duration' => 'Monthly Dedicated',
                'price_egp' => 1800,
                'price_usd' => 49.99,
                'features' => ['Dedicated Certified Coach', 'Custom tailored programs', 'Weekly form reviews', 'Direct coach messaging'],
                'active_members' => 24,
            ],
        ];

        return view('admin.subscriptions.index', [
            'plans' => $plans,
        ]);
    }

    public function vouchers(): View
    {
        $sampleVouchers = [
            [
                'code' => 'SPARTAN50',
                'discount' => '50% OFF',
                'type' => 'percentage',
                'expires_at' => now()->addMonths(2)->format('Y-m-d'),
                'max_uses' => 100,
                'used_count' => 34,
                'is_active' => true,
            ],
            [
                'code' => 'ONEMOREREP2026',
                'discount' => 'FREE 1 MONTH',
                'type' => 'full_trial',
                'expires_at' => now()->addMonths(6)->format('Y-m-d'),
                'max_uses' => 500,
                'used_count' => 189,
                'is_active' => true,
            ],
            [
                'code' => 'SUMMERFIT',
                'discount' => '25% OFF',
                'type' => 'percentage',
                'expires_at' => now()->subDays(10)->format('Y-m-d'),
                'max_uses' => 50,
                'used_count' => 50,
                'is_active' => false,
            ],
        ];

        return view('admin.vouchers.index', [
            'vouchers' => $sampleVouchers,
        ]);
    }

    public function payments(): View
    {
        $pendingPayments = [
            [
                'id' => 'VOD-8921',
                'trainee_name' => 'Omar Farouk',
                'trainee_email' => 'omar.f@gmail.com',
                'method' => 'Vodafone Cash',
                'reference' => '01012345678-TX992',
                'amount' => '650 EGP',
                'submitted_at' => now()->subHours(2)->diffForHumans(),
                'status' => 'pending',
            ],
            [
                'id' => 'INSTA-4412',
                'trainee_name' => 'Kareem Tarek',
                'trainee_email' => 'kareem@gmail.com',
                'method' => 'InstaPay',
                'reference' => 'IPA-2026-90812',
                'amount' => '1,800 EGP',
                'submitted_at' => now()->subHours(5)->diffForHumans(),
                'status' => 'pending',
            ],
        ];

        return view('admin.payments.index', [
            'pendingPayments' => $pendingPayments,
        ]);
    }
}
