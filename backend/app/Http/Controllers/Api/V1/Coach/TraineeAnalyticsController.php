<?php

namespace App\Http\Controllers\Api\V1\Coach;

use App\Http\Controllers\Controller;
use App\Http\Requests\AnalyticsOverviewRequest;
use App\Http\Resources\AnalyticsOverviewResource;
use App\Models\User;
use App\Services\Training\AnalyticsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Gate;

class TraineeAnalyticsController extends Controller
{
    public function __construct(private readonly AnalyticsService $analytics) {}

    public function show(AnalyticsOverviewRequest $request, User $trainee): JsonResponse
    {
        Gate::authorize('access-trainee', $trainee);

        $data = $this->analytics->forTrainee(
            $trainee,
            $request->fromDate(),
            $request->toDate(),
        );

        return (new AnalyticsOverviewResource($data))->response();
    }
}
