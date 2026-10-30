<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View;

class AuthController extends Controller
{
    public function showLoginForm(): View|RedirectResponse
    {
        if (Auth::check()) {
            $user = Auth::user();
            if ($user->isSuperAdmin()) {
                return redirect()->intended('/admin/dashboard');
            }
            if ($user->isCoach()) {
                return redirect()->intended('/coach/dashboard');
            }
        }

        return view('auth.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $remember = $request->boolean('remember');

        if (Auth::attempt($credentials, $remember)) {
            $request->session()->regenerate();
            $user = Auth::user();

            if (! $user->is_active) {
                Auth::logout();
                return back()->withErrors(['email' => 'This account has been disabled.']);
            }

            if ($user->isSuperAdmin()) {
                return redirect()->intended('/admin/dashboard');
            }

            if ($user->isCoach()) {
                return redirect()->intended('/coach/dashboard');
            }

            // Trainees use the Flutter mobile application
            Auth::logout();
            return back()->withErrors([
                'email' => 'Trainee accounts access One More Rep via the mobile app.',
            ]);
        }

        return back()->withErrors([
            'email' => 'The provided credentials do not match our records.',
        ])->onlyInput('email');
    }

    public function logout(Request $request): RedirectResponse
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return redirect('/login');
    }
}
