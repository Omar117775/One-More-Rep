<?php

namespace App\Http\Controllers\Api\V1\Coach;

use App\Http\Controllers\Controller;
use App\Http\Resources\BodyMeasurementResource;
use App\Models\BodyMeasurement;
use App\Models\User;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class TraineeProgressController extends Controller
{
    public function index(Request $request, User $trainee): JsonResponse
    {
        Gate::authorize('access-trainee', $trainee);

        $perPage = PaginationConfig::perPage($request->integer('per_page') ?: null);

        $measurements = BodyMeasurement::query()
            ->where('trainee_id', $trainee->id)
            ->orderByDesc('measured_on')
            ->orderByDesc('id')
            ->paginate($perPage);

        return BodyMeasurementResource::collection($measurements)->response();
    }

    public function show(User $trainee, BodyMeasurement $measurement): JsonResponse
    {
        Gate::authorize('access-trainee', $trainee);
        abort_unless($measurement->trainee_id === $trainee->id, 404);

        return (new BodyMeasurementResource($measurement))->response();
    }
}
