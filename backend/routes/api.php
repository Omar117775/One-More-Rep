<?php

use App\Http\Controllers\Api\V1\Admin\AuditLogController;
use App\Http\Controllers\Api\V1\Admin\UserController;
use App\Http\Controllers\Api\V1\Auth\EmailVerificationController;
use App\Http\Controllers\Api\V1\Auth\ForgotPasswordController;
use App\Http\Controllers\Api\V1\Auth\LoginController;
use App\Http\Controllers\Api\V1\Auth\LogoutAllController;
use App\Http\Controllers\Api\V1\Auth\LogoutController;
use App\Http\Controllers\Api\V1\Auth\MeController;
use App\Http\Controllers\Api\V1\Auth\RegisterController;
use App\Http\Controllers\Api\V1\Auth\ResetPasswordController;
use App\Http\Controllers\Api\V1\Coach\ExerciseController as CoachExerciseController;
use App\Http\Controllers\Api\V1\Coach\RelationshipController as CoachRelationshipController;
use App\Http\Controllers\Api\V1\Coach\TraineeAnalyticsController as CoachTraineeAnalyticsController;
use App\Http\Controllers\Api\V1\Coach\TraineeCardioController as CoachTraineeCardioController;
use App\Http\Controllers\Api\V1\Coach\TraineeController as CoachTraineeController;
use App\Http\Controllers\Api\V1\Coach\TraineeProgressController as CoachTraineeProgressController;
use App\Http\Controllers\Api\V1\Coach\TraineeWorkoutController as CoachTraineeWorkoutController;
use App\Http\Controllers\Api\V1\Coach\WorkoutAssignmentController as CoachWorkoutAssignmentController;
use App\Http\Controllers\Api\V1\Coach\WorkoutProgramController as CoachWorkoutProgramController;
use App\Http\Controllers\Api\V1\Directory\CoachController as CoachDirectoryController;
use App\Http\Controllers\Api\V1\Directory\ExerciseController as ExerciseDirectoryController;
use App\Http\Controllers\Api\V1\Profile\ProfileController;
use App\Http\Controllers\Api\V1\Trainee\AnalyticsController as TraineeAnalyticsController;
use App\Http\Controllers\Api\V1\Trainee\CardioSessionController as TraineeCardioSessionController;
use App\Http\Controllers\Api\V1\Trainee\ProgressController as TraineeProgressController;
use App\Http\Controllers\Api\V1\Trainee\RelationshipController as TraineeRelationshipController;
use App\Http\Controllers\Api\V1\Trainee\WorkoutAssignmentController as TraineeWorkoutAssignmentController;
use App\Http\Controllers\Api\V1\Trainee\WorkoutSessionController as TraineeWorkoutSessionController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function () {
    Route::middleware(['throttle:api'])->get('/health', function () {
        return response()->json(['status' => 'ok']);
    });

    // Public auth
    Route::middleware(['throttle:api', 'throttle:register'])->post('/auth/register', [RegisterController::class, 'store']);
    Route::middleware(['throttle:api', 'throttle:auth'])->post('/auth/login', [LoginController::class, 'store']);
    Route::middleware(['throttle:api', 'throttle:password'])->post('/auth/forgot-password', [ForgotPasswordController::class, 'store']);
    Route::middleware(['throttle:api', 'throttle:password'])->post('/auth/reset-password', [ResetPasswordController::class, 'store']);
    Route::middleware(['auth:sanctum', 'signed', 'throttle:api'])->get('/auth/email/verify/{id}/{hash}', [EmailVerificationController::class, 'verify'])->name('verification.verify');

    // Authenticated
    Route::middleware(['auth:sanctum', 'active', 'throttle:api'])->group(function () {
        Route::get('/auth/me', [MeController::class, 'show']);
        Route::post('/auth/logout', [LogoutController::class, 'store']);
        Route::post('/auth/logout-all', [LogoutAllController::class, 'store']);
        Route::middleware(['throttle:verification'])->post('/auth/email/verification-notification', [EmailVerificationController::class, 'send']);
        Route::get('/profile', [ProfileController::class, 'show']);
        Route::patch('/profile', [ProfileController::class, 'update']);

        // Non-sensitive coach directory (name, display name, bio only; no email).
        Route::get('/coaches', [CoachDirectoryController::class, 'index']);
        Route::get('/coaches/{coach}', [CoachDirectoryController::class, 'show']);

        // Shared, authorization-scoped exercise library.
        Route::middleware(['role:coach,trainee'])->group(function () {
            Route::get('/exercises', [ExerciseDirectoryController::class, 'index']);
            Route::get('/exercises/{exercise}', [ExerciseDirectoryController::class, 'show']);
        });
    });

    // Trainee
    Route::middleware(['auth:sanctum', 'active', 'verified', 'throttle:api', 'role:trainee'])->prefix('trainee')->group(function () {
        Route::get('/relationships', [TraineeRelationshipController::class, 'index']);
        Route::post('/relationships', [TraineeRelationshipController::class, 'store']);
        Route::get('/relationships/{relationship}', [TraineeRelationshipController::class, 'show']);
        Route::post('/relationships/{relationship}/cancel', [TraineeRelationshipController::class, 'cancel']);
        Route::post('/relationships/{relationship}/end', [TraineeRelationshipController::class, 'end']);

        Route::get('/progress', [TraineeProgressController::class, 'index']);
        Route::post('/progress', [TraineeProgressController::class, 'store']);
        Route::get('/progress/{measurement}', [TraineeProgressController::class, 'show']);
        Route::patch('/progress/{measurement}', [TraineeProgressController::class, 'update']);
        Route::delete('/progress/{measurement}', [TraineeProgressController::class, 'destroy']);

        Route::get('/assignments', [TraineeWorkoutAssignmentController::class, 'index']);
        Route::get('/assignments/{assignment}', [TraineeWorkoutAssignmentController::class, 'show']);

        Route::get('/sessions', [TraineeWorkoutSessionController::class, 'index']);
        Route::post('/sessions', [TraineeWorkoutSessionController::class, 'store']);
        Route::get('/sessions/{session}', [TraineeWorkoutSessionController::class, 'show']);
        Route::patch('/sessions/{session}', [TraineeWorkoutSessionController::class, 'update']);
        Route::delete('/sessions/{session}', [TraineeWorkoutSessionController::class, 'destroy']);

        Route::get('/cardio', [TraineeCardioSessionController::class, 'index']);
        Route::post('/cardio', [TraineeCardioSessionController::class, 'store']);
        Route::get('/cardio/{cardio}', [TraineeCardioSessionController::class, 'show']);
        Route::patch('/cardio/{cardio}', [TraineeCardioSessionController::class, 'update']);
        Route::delete('/cardio/{cardio}', [TraineeCardioSessionController::class, 'destroy']);

        Route::get('/analytics', [TraineeAnalyticsController::class, 'show']);
    });

    // Coach
    Route::middleware(['auth:sanctum', 'active', 'verified', 'throttle:api', 'role:coach'])->prefix('coach')->group(function () {
        Route::get('/trainees', [CoachTraineeController::class, 'index']);
        Route::get('/trainees/{trainee}', [CoachTraineeController::class, 'show']);
        Route::get('/trainees/{trainee}/progress', [CoachTraineeProgressController::class, 'index']);
        Route::get('/trainees/{trainee}/progress/{measurement}', [CoachTraineeProgressController::class, 'show']);
        Route::get('/trainees/{trainee}/workouts', [CoachTraineeWorkoutController::class, 'index']);
        Route::get('/trainees/{trainee}/workouts/{session}', [CoachTraineeWorkoutController::class, 'show']);
        Route::get('/trainees/{trainee}/cardio', [CoachTraineeCardioController::class, 'index']);
        Route::get('/trainees/{trainee}/cardio/{cardio}', [CoachTraineeCardioController::class, 'show']);
        Route::get('/trainees/{trainee}/analytics', [CoachTraineeAnalyticsController::class, 'show']);

        Route::post('/exercises', [CoachExerciseController::class, 'store']);
        Route::patch('/exercises/{exercise}', [CoachExerciseController::class, 'update']);
        Route::delete('/exercises/{exercise}', [CoachExerciseController::class, 'destroy']);

        Route::get('/programs', [CoachWorkoutProgramController::class, 'index']);
        Route::post('/programs', [CoachWorkoutProgramController::class, 'store']);
        Route::get('/programs/{program}', [CoachWorkoutProgramController::class, 'show']);
        Route::patch('/programs/{program}', [CoachWorkoutProgramController::class, 'update']);
        Route::delete('/programs/{program}', [CoachWorkoutProgramController::class, 'destroy']);
        Route::post('/programs/{program}/assignments', [CoachWorkoutProgramController::class, 'assign']);

        Route::get('/assignments', [CoachWorkoutAssignmentController::class, 'index']);
        Route::post('/assignments/{assignment}/end', [CoachWorkoutAssignmentController::class, 'end']);

        Route::get('/requests', [CoachRelationshipController::class, 'indexRequests']);
        Route::get('/requests/{relationship}', [CoachRelationshipController::class, 'showRequest']);
        Route::post('/requests/{relationship}/approve', [CoachRelationshipController::class, 'approve']);
        Route::post('/requests/{relationship}/reject', [CoachRelationshipController::class, 'reject']);

        Route::get('/relationships', [CoachRelationshipController::class, 'indexRelationships']);
        Route::post('/relationships/{relationship}/end', [CoachRelationshipController::class, 'end']);
    });

    // Admin
    Route::middleware(['auth:sanctum', 'active', 'verified', 'throttle:api', 'role:super_admin'])->prefix('admin')->group(function () {
        Route::get('/users', [UserController::class, 'index']);
        Route::get('/audit-logs', [AuditLogController::class, 'index']);
    });
});
