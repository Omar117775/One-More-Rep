<?php

namespace App\Http\Controllers\Api\V1\Trainee;

use App\Http\Controllers\Controller;
use App\Http\Requests\AnalyticsOverviewRequest;
use App\Http\Resources\AnalyticsOverviewResource;
use App\Services\Training\AnalyticsService;
use Illuminate\Http\JsonResponse;

class AnalyticsController extends Controller
{
    public function __construct(private readonly AnalyticsService $analytics) {}

    public function show(AnalyticsOverviewRequest $request): JsonResponse
    {
        $data = $this->analytics->forTrainee(
            $request->user(),
            $request->fromDate(),
            $request->toDate(),
        );

        return (new AnalyticsOverviewResource($data))->response();
    }
}
