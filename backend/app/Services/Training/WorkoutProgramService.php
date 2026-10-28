<?php

namespace App\Services\Training;

use App\Enums\Enums\AuditAction;
use App\Enums\Enums\WorkoutAssignmentStatus;
use App\Models\User;
use App\Models\WorkoutAssignment;
use App\Models\WorkoutProgram;
use App\Models\WorkoutProgramDay;
use App\Services\Audit\AuditLogger;
use Carbon\CarbonImmutable;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class WorkoutProgramService
{
    public function __construct(
        private readonly AuditLogger $auditLogger,
        private readonly ExerciseService $exercises,
    ) {}

    public function create(User $coach, array $data): WorkoutProgram
    {
        return DB::transaction(function () use ($coach, $data) {
            $this->assertExerciseAvailability($coach, $data['days']);

            $program = WorkoutProgram::create([
                'coach_id' => $coach->id,
                'name' => $data['name'],
                'description' => $data['description'] ?? null,
                'is_active' => $data['is_active'] ?? true,
            ]);

            $this->createDays($program, $data['days']);

            $this->auditLogger->log($coach, AuditAction::WORKOUT_PROGRAM_CREATED->value, $program, [
                'coach_id' => $coach->id,
                'days' => count($data['days']),
                'exercise_count' => $this->exerciseCount($data['days']),
            ]);

            return $this->loadProgram($program);
        }, 3);
    }

    public function update(User $coach, WorkoutProgram $program, array $data): WorkoutProgram
    {
        return DB::transaction(function () use ($coach, $program, $data) {
            $locked = WorkoutProgram::query()->lockForUpdate()->findOrFail($program->id);
            $this->assertOwned($coach, $locked);

            if (array_key_exists('days', $data) && $locked->assignments()->exists()) {
                throw ValidationException::withMessages([
                    'days' => 'A program with assignment history cannot have its schedule replaced. Create a new program version instead.',
                ]);
            }

            if (array_key_exists('days', $data)) {
                $this->assertExerciseAvailability($coach, $data['days']);
            }

            $locked->fill(array_intersect_key($data, array_flip(['name', 'description', 'is_active'])))->save();

            if (array_key_exists('days', $data)) {
                $locked->days()->delete();
                $this->createDays($locked, $data['days']);
            }

            $this->auditLogger->log($coach, AuditAction::WORKOUT_PROGRAM_UPDATED->value, $locked, [
                'coach_id' => $locked->coach_id,
                'fields' => array_keys($data),
                'days' => $locked->days()->count(),
            ]);

            return $this->loadProgram($locked);
        }, 3);
    }

    public function delete(User $coach, WorkoutProgram $program): void
    {
        DB::transaction(function () use ($coach, $program) {
            $locked = WorkoutProgram::query()->lockForUpdate()->findOrFail($program->id);
            $this->assertOwned($coach, $locked);

            if ($locked->assignments()->exists()) {
                throw ValidationException::withMessages([
                    'program' => 'A program with assignment history cannot be deleted. Mark it inactive instead.',
                ]);
            }

            $this->auditLogger->log($coach, AuditAction::WORKOUT_PROGRAM_DELETED->value, $locked, [
                'coach_id' => $locked->coach_id,
            ]);

            $locked->delete();
        }, 3);
    }

    public function assign(User $coach, WorkoutProgram $program, array $data): WorkoutAssignment
    {
        try {
            return DB::transaction(function () use ($coach, $program, $data) {
                $lockedProgram = WorkoutProgram::query()->lockForUpdate()->findOrFail($program->id);
                $this->assertOwned($coach, $lockedProgram);

                if (! $lockedProgram->is_active) {
                    throw ValidationException::withMessages([
                        'program' => 'Inactive programs cannot be assigned.',
                    ]);
                }

                $trainee = User::query()->lockForUpdate()->find($data['trainee_id']);

                if (! $trainee || ! $trainee->isTrainee() || ! $trainee->is_active || $trainee->email_verified_at === null) {
                    throw ValidationException::withMessages([
                        'trainee_id' => 'The selected trainee is not available for assignment.',
                    ]);
                }

                $hasActiveRelationship = $coach->activeCoachingRelationships()
                    ->where('trainee_id', $trainee->id)
                    ->exists();

                if (! $hasActiveRelationship) {
                    throw ValidationException::withMessages([
                        'trainee_id' => 'The trainee must have an active coach relationship before assignment.',
                    ]);
                }

                $duplicate = WorkoutAssignment::query()
                    ->where('workout_program_id', $lockedProgram->id)
                    ->where('trainee_id', $trainee->id)
                    ->where('status', WorkoutAssignmentStatus::ACTIVE)
                    ->lockForUpdate()
                    ->exists();

                if ($duplicate) {
                    throw ValidationException::withMessages([
                        'trainee_id' => 'This trainee already has an active assignment for this program.',
                    ]);
                }

                $assignment = WorkoutAssignment::create([
                    'workout_program_id' => $lockedProgram->id,
                    'trainee_id' => $trainee->id,
                    'assigned_by' => $coach->id,
                    'starts_on' => CarbonImmutable::parse($data['starts_on'])->toDateString(),
                    'ends_on' => isset($data['ends_on']) ? CarbonImmutable::parse($data['ends_on'])->toDateString() : null,
                    'status' => WorkoutAssignmentStatus::ACTIVE,
                ]);

                $this->auditLogger->log($coach, AuditAction::WORKOUT_ASSIGNMENT_CREATED->value, $assignment, [
                    'workout_program_id' => $lockedProgram->id,
                    'trainee_id' => $trainee->id,
                    'starts_on' => $assignment->starts_on->toDateString(),
                    'ends_on' => $assignment->ends_on?->toDateString(),
                ]);

                return $assignment->fresh()->load('program.days.exercises.exercise');
            }, 3);
        } catch (QueryException) {
            throw ValidationException::withMessages([
                'trainee_id' => 'This trainee already has an active assignment for this program.',
            ]);
        }
    }

    public function end(User $coach, WorkoutAssignment $assignment): WorkoutAssignment
    {
        return DB::transaction(function () use ($coach, $assignment) {
            $locked = WorkoutAssignment::query()->lockForUpdate()->findOrFail($assignment->id);
            $locked->loadMissing('program');
            $this->assertOwned($coach, $locked->program);

            if ($locked->status === WorkoutAssignmentStatus::ENDED) {
                throw ValidationException::withMessages([
                    'assignment' => 'This assignment has already ended.',
                ]);
            }

            $this->endAssignment($coach, $locked);

            return $locked->fresh()->load('program.days.exercises.exercise');
        }, 3);
    }

    /**
     * End every active assignment owned by the given coach for a trainee.
     *
     * Called inside the relationship-ending transaction so a former coach's
     * training program cannot remain usable after access is revoked.
     */
    public function endActiveForRelationship(User $actor, int $coachId, int $traineeId): int
    {
        $assignments = WorkoutAssignment::query()
            ->where('trainee_id', $traineeId)
            ->where('status', WorkoutAssignmentStatus::ACTIVE)
            ->whereHas('program', fn ($query) => $query->where('coach_id', $coachId))
            ->lockForUpdate()
            ->get();

        foreach ($assignments as $assignment) {
            $this->endAssignment($actor, $assignment);
        }

        return $assignments->count();
    }

    private function endAssignment(User $actor, WorkoutAssignment $assignment): void
    {
        $today = CarbonImmutable::today();
        $endsOn = $today->lt($assignment->starts_on) ? $assignment->starts_on : $today;

        $assignment->update([
            'status' => WorkoutAssignmentStatus::ENDED,
            'ends_on' => $endsOn->toDateString(),
        ]);

        $this->auditLogger->log($actor, AuditAction::WORKOUT_ASSIGNMENT_ENDED->value, $assignment, [
            'workout_program_id' => $assignment->workout_program_id,
            'trainee_id' => $assignment->trainee_id,
            'ends_on' => $assignment->ends_on?->toDateString(),
        ]);
    }

    private function createDays(WorkoutProgram $program, array $days): void
    {
        foreach ($days as $dayData) {
            $day = WorkoutProgramDay::create([
                'workout_program_id' => $program->id,
                'day_number' => $dayData['day_number'],
                'name' => $dayData['name'],
            ]);

            foreach ($dayData['exercises'] as $exerciseData) {
                $day->exercises()->create([
                    'exercise_id' => $exerciseData['exercise_id'],
                    'sort_order' => $exerciseData['sort_order'],
                    'target_sets' => $exerciseData['target_sets'],
                    'target_reps_min' => $exerciseData['target_reps_min'],
                    'target_reps_max' => $exerciseData['target_reps_max'],
                    'target_weight_kg' => $exerciseData['target_weight_kg'] ?? null,
                    'rest_seconds' => $exerciseData['rest_seconds'] ?? null,
                ]);
            }
        }
    }

    private function assertExerciseAvailability(User $coach, array $days): void
    {
        $exerciseIds = [];

        foreach ($days as $day) {
            foreach ($day['exercises'] as $exercise) {
                $exerciseIds[] = $exercise['exercise_id'];
            }
        }

        $this->exercises->assertExercisesAvailable($coach, $exerciseIds);
    }

    private function exerciseCount(array $days): int
    {
        return array_sum(array_map(fn (array $day) => count($day['exercises']), $days));
    }

    private function assertOwned(User $coach, WorkoutProgram $program): void
    {
        if ($program->coach_id !== $coach->id) {
            throw ValidationException::withMessages([
                'program' => 'Only the coach who owns this program can change it.',
            ]);
        }
    }

    private function loadProgram(WorkoutProgram $program): WorkoutProgram
    {
        return $program->fresh()->load('days.exercises.exercise');
    }
}
