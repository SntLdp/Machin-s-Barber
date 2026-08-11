<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthenticatedSessionController extends Controller
{
    /**
     * Handle an incoming authentication request.
     */

   public function store(LoginRequest $request)
{
    $request->validate([
        'email' => 'email|required|exists:users,email',
        'password' => 'required',
    ]);

    $user = User::where('email', $request->email)->first();

    if (!$user || !Hash::check($request->password, $user->password)) {

        if ($request->wantsJson()) {
            return response()->json([
                'message' => 'Las credenciales proporcionadas no son correctas.'
            ], 422);
        }

        return back()->withErrors([
            'email' => 'Las credenciales proporcionadas no son correctas.',
        ])->onlyInput('email');
    }

    // ==========================================
    // LOGIN DE LA APP MÓVIL / API
    // ==========================================

    if ($request->is('api/*') || $request->wantsJson()) {

        $token = $user->createToken('barberia-api-token')->plainTextToken;

        return response()->json([
            'message' => 'Inicio de sesión exitoso.',
            'user' => $user,
            'token' => $token,
        ]);
    }

    // ==========================================
    // LOGIN WEB
    // ==========================================

    Auth::guard('web')->login(
        $user,
        $request->boolean('remember')
    );

    $request->session()->regenerate();

    $user->loadMissing('employee');

    if (
        $user->employee &&
        $user->employee->admin_type === 'admin'
    ) {
        return redirect()->route('admin.dashboard');
    }

    return redirect()->intended(route('home'));
}

    /**
     * Destroy an authenticated session.
     */
    public function destroy(Request $request): Response
    {
        Auth::guard('web')->logout();

        $request->session()->invalidate();

        $request->session()->regenerateToken();

        return response()->noContent();
    }
}
