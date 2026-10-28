<?php

namespace App\Http\Controllers\Api\V1\Coach;

use App\Http\Controllers\Controller;
use App\Http\Resources\CardioSessionResource;
use App\Models\CardioSession;
use App\Models\User;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class TraineeCardioController extends Controller
{
    public function index(Request $request, User $trainee): JsonResponse
    {
        Gate::authorize('access-trainee', $trainee);

        $filters = $request->validate([
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $sessions = CardioSession::query()
            ->where('trainee_id', $trainee->id)
            ->orderByDesc('performed_at')
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return CardioSessionResource::collection($sessions)->response();
    }

    public function show(User $trainee, CardioSession $cardio): JsonResponse
    {
        Gate::authorize('access-trainee', $trainee);
        abort_unless($cardio->trainee_id === $trainee->id, 404);

        return (new CardioSessionResource($cardio))->response();
    }
}
