<?php

namespace App\Http\Controllers\Api\V1\Trainee;

use App\Enums\Enums\RelationshipStatus;
use App\Enums\Enums\RelationshipType;
use App\Http\Controllers\Controller;
use App\Http\Requests\Trainee\StoreRelationshipRequest;
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

    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'status' => ['sometimes', Rule::enum(RelationshipStatus::class)],
            'relationship_type' => ['sometimes', Rule::enum(RelationshipType::class)],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        $relationships = CoachTraineeRelationship::query()
            ->where('trainee_id', $request->user()->id)
            ->when(isset($filters['status']), fn ($query) => $query->where('status', $filters['status']))
            ->when(isset($filters['relationship_type']), fn ($query) => $query->where('relationship_type', $filters['relationship_type']))
            ->with(['coach.coachProfile'])
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return CoachTraineeRelationshipResource::collection($relationships)->response();
    }

    public function store(StoreRelationshipRequest $request): JsonResponse
    {
        $data = $request->validated();
        $type = RelationshipType::from($data['relationship_type'] ?? RelationshipType::PRIMARY->value);

        $relationship = $this->relationships->request($request->user(), (int) $data['coach_id'], $type);

        return (new CoachTraineeRelationshipResource($relationship->load(['coach.coachProfile'])))
            ->response()
            ->setStatusCode(201);
    }

    public function show(Request $request, int $relationship): JsonResponse
    {
        $model = $this->findOwned($request, $relationship, ['coach.coachProfile']);

        return (new CoachTraineeRelationshipResource($model))->response();
    }

    public function cancel(Request $request, int $relationship): JsonResponse
    {
        $model = $this->findOwned($request, $relationship);

        $model = $this->relationships->cancel($request->user(), $model);

        return (new CoachTraineeRelationshipResource($model->load(['coach.coachProfile'])))->response();
    }

    public function end(Request $request, int $relationship): JsonResponse
    {
        $model = $this->findOwned($request, $relationship);

        $model = $this->relationships->end($request->user(), $model);

        return (new CoachTraineeRelationshipResource($model->load(['coach.coachProfile'])))->response();
    }

    /**
     * @param  list<string>  $with
     */
    private function findOwned(Request $request, int $relationshipId, array $with = []): CoachTraineeRelationship
    {
        return CoachTraineeRelationship::query()
            ->where('trainee_id', $request->user()->id)
            ->with($with)
            ->findOrFail($relationshipId);
    }
}
