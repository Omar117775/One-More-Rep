<?php

namespace App\Http\Controllers\Api\V1\Coach;

use App\Enums\Enums\RelationshipStatus;
use App\Http\Controllers\Controller;
use App\Http\Resources\CoachTraineeRelationshipResource;
use App\Models\CoachTraineeRelationship;
use App\Services\Relationships\RelationshipService;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class RelationshipController extends Controller
{
    public function __construct(private readonly RelationshipService $relationships) {}

    public function indexRequests(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'status' => ['sometimes', Rule::enum(RelationshipStatus::class)],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $status = $filters['status'] ?? RelationshipStatus::PENDING->value;

        $requests = CoachTraineeRelationship::query()
            ->where('coach_id', $request->user()->id)
            ->where('status', $status)
            ->with(['trainee'])
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return CoachTraineeRelationshipResource::collection($requests)->response();
    }

    public function showRequest(Request $request, int $relationship): JsonResponse
    {
        $model = $this->findAddressedToCoach($request, $relationship, ['trainee']);

        return (new CoachTraineeRelationshipResource($model))->response();
    }

    public function approve(Request $request, int $relationship): JsonResponse
    {
        $model = $this->relationships->approve($request->user(), $this->findAddressedToCoach($request, $relationship));

        return (new CoachTraineeRelationshipResource($model->load(['trainee'])))->response();
    }

    public function reject(Request $request, int $relationship): JsonResponse
    {
        $model = $this->relationships->reject($request->user(), $this->findAddressedToCoach($request, $relationship));

        return (new CoachTraineeRelationshipResource($model->load(['trainee'])))->response();
    }

    public function indexRelationships(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'status' => ['sometimes', Rule::enum(RelationshipStatus::class)],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $relationships = CoachTraineeRelationship::query()
            ->where('coach_id', $request->user()->id)
            ->when(isset($filters['status']), fn ($query) => $query->where('status', $filters['status']))
            ->with(['trainee'])
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return CoachTraineeRelationshipResource::collection($relationships)->response();
    }

    public function end(Request $request, int $relationship): JsonResponse
    {
        $model = $this->findAddressedToCoach($request, $relationship);

        $model = $this->relationships->end($request->user(), $model);

        return (new CoachTraineeRelationshipResource($model->load(['trainee'])))->response();
    }

    /**
     * @param  list<string>  $with
     */
    private function findAddressedToCoach(Request $request, int $relationshipId, array $with = []): CoachTraineeRelationship
    {
        return CoachTraineeRelationship::query()
            ->where('coach_id', $request->user()->id)
            ->with($with)
            ->findOrFail($relationshipId);
    }
}
