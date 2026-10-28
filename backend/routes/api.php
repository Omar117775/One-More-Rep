<?php

use App\Http\Controllers\Api\V1\Auth\EmailVerificationController;
use App\Http\Controllers\Api\V1\Auth\ForgotPasswordController;
use App\Http\Controllers\Api\V1\Auth\LoginController;
use App\Http\Controllers\Api\V1\Auth\LogoutAllController;
use App\Http\Controllers\Api\V1\Auth\LogoutController;
use App\Http\Controllers\Api\V1\Auth\MeController;
use App\Http\Controllers\Api\V1\Auth\RegisterController;
use App\Http\Controllers\Api\V1\Auth\ResetPasswordController;
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
    });

    // Coach
    Route::middleware(['auth:sanctum', 'active', 'verified', 'throttle:api', 'role:coach'])->prefix('coach')->group(function () {
        Route::get('/trainees', function () {
            return response()->json(['data' => []]);
        });
        Route::get('/trainees/{trainee}', function () {
            abort(404);
        });
    });

    // Admin
    Route::middleware(['auth:sanctum', 'active', 'verified', 'throttle:api', 'role:super_admin'])->prefix('admin')->group(function () {
        Route::get('/users', function () {
            return response()->json(['data' => []]);
        });
        Route::get('/audit-logs', function () {
            return response()->json(['data' => []]);
        });
    });
});
