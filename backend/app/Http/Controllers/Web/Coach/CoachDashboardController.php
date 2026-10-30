<?php

namespace App\Http\Controllers\Web\Coach;

use App\Http\Controllers\Controller;
use App\Models\CoachTraineeRelationship;
use App\Models\Exercise;
use App\Models\User;
use App\Models\WorkoutAssignment;
use App\Models\WorkoutProgram;
use App\Models\WorkoutSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class CoachDashboardController extends Controller
{
    public function index(): View
    {
        $coach = Auth::user();

        // 1. Assigned trainees (isolated to this coach)
        $traineeRelationships = CoachTraineeRelationship::with(['trainee.traineeProfile'])
            ->where('coach_id', $coach->id)
            ->where('status', 'active')
            ->whereNull('ended_at')
            ->get();

        $traineeCount = $traineeRelationships->count();

        // 2. Active Programs created by this coach
        $programs = WorkoutProgram::with(['days.exercises'])
            ->where('coach_id', $coach->id)
            ->get();

        $programCount = $programs->count();

        // 3. Active Assignments
        $activeAssignmentsCount = WorkoutAssignment::where('assigned_by', $coach->id)
            ->where('status', 'active')
            ->count();

        // 4. Exercises accessible to coach
        $exerciseCount = Exercise::where('is_public', true)
            ->orWhere('created_by', $coach->id)
            ->count();

        // 5. Recent Workout Sessions logged by coach's trainees
        $traineeIds = $traineeRelationships->pluck('trainee_id');
        $recentSessions = WorkoutSession::with(['trainee', 'workoutDay'])
            ->whereIn('trainee_id', $traineeIds)
            ->latest('started_at')
            ->take(5)
            ->get();

        return view('coach.dashboard', [
            'coach' => $coach,
            'traineeCount' => $traineeCount,
            'programCount' => $programCount,
            'activeAssignmentsCount' => $activeAssignmentsCount,
            'exerciseCount' => $exerciseCount,
            'trainees' => $traineeRelationships,
            'programs' => $programs,
            'recentSessions' => $recentSessions,
        ]);
    }

    public function trainees(Request $request): View
    {
        $coach = Auth::user();

        $query = CoachTraineeRelationship::with(['trainee.traineeProfile', 'trainee.workoutAssignments.program'])
            ->where('coach_id', $coach->id);

        if ($search = $request->input('search')) {
            $query->whereHas('trainee', function ($q) use ($search) {
                $q->where('name', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        $relationships = $query->paginate(15)->withQueryString();

        return view('coach.trainees.index', [
            'coach' => $coach,
            'relationships' => $relationships,
            'search' => $search,
            'status' => $status,
        ]);
    }

    public function showTrainee(int $id): View
    {
        $coach = Auth::user();

        // Security / Tenant Isolation: Verify this trainee is explicitly assigned to this coach
        $relationship = CoachTraineeRelationship::where('coach_id', $coach->id)
            ->where('trainee_id', $id)
            ->firstOrFail();

        $trainee = User::with([
            'traineeProfile',
            'bodyMeasurements' => fn ($q) => $q->latest('recorded_at')->take(10),
            'workoutSessions' => fn ($q) => $q->latest('started_at')->take(10),
            'workoutAssignments.program',
            'cardioSessions' => fn ($q) => $q->latest('started_at')->take(10),
        ])->findOrFail($id);

        $availablePrograms = WorkoutProgram::where('coach_id', $coach->id)
            ->where('is_active', true)
            ->get();

        return view('coach.trainees.show', [
            'coach' => $coach,
            'relationship' => $relationship,
            'trainee' => $trainee,
            'availablePrograms' => $availablePrograms,
        ]);
    }

    public function programs(): View
    {
        $coach = Auth::user();

        $programs = WorkoutProgram::with(['days.exercises.exercise', 'assignments'])
            ->where('coach_id', $coach->id)
            ->latest()
            ->paginate(10);

        return view('coach.programs.index', [
            'coach' => $coach,
            'programs' => $programs,
        ]);
    }

    public function exercises(): View
    {
        $coach = Auth::user();

        $exercises = Exercise::where('is_public', true)
            ->orWhere('created_by', $coach->id)
            ->orderBy('name')
            ->paginate(20);

        return view('coach.exercises.index', [
            'coach' => $coach,
            'exercises' => $exercises,
        ]);
    }
}
