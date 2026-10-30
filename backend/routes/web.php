<?php

use App\Http\Controllers\Web\Admin\AdminDashboardController;
use App\Http\Controllers\Web\AuthController;
use App\Http\Controllers\Web\Coach\CoachDashboardController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes — One More Rep Portal
|--------------------------------------------------------------------------
*/

Route::get('/', function () {
    return view('welcome');
});

// Authentication
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
});

Route::post('/logout', [AuthController::class, 'logout'])->name('logout')->middleware('auth');

// Coach Web Dashboard
Route::middleware(['auth', 'active', 'role:coach'])->prefix('coach')->name('coach.')->group(function () {
    Route::get('/dashboard', [CoachDashboardController::class, 'index'])->name('dashboard');
    Route::get('/trainees', [CoachDashboardController::class, 'trainees'])->name('trainees');
    Route::get('/trainees/{id}', [CoachDashboardController::class, 'showTrainee'])->name('trainees.show');
    Route::get('/programs', [CoachDashboardController::class, 'programs'])->name('programs');
    Route::get('/exercises', [CoachDashboardController::class, 'exercises'])->name('exercises');
});

// Super Admin Web Dashboard
Route::middleware(['auth', 'active', 'role:super_admin'])->prefix('admin')->name('admin.')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('dashboard');
    Route::get('/users', [AdminDashboardController::class, 'users'])->name('users');
    Route::post('/users/{id}/toggle-status', [AdminDashboardController::class, 'toggleUserStatus'])->name('users.toggle');
    Route::get('/subscriptions', [AdminDashboardController::class, 'subscriptions'])->name('subscriptions');
    Route::get('/vouchers', [AdminDashboardController::class, 'vouchers'])->name('vouchers');
    Route::get('/payments', [AdminDashboardController::class, 'payments'])->name('payments');
});
