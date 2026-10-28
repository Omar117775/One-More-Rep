<?php

namespace App\Http\Controllers\Api\V1\Trainee;

use App\Enums\Enums\AuditAction;
use App\Http\Controllers\Controller;
use App\Http\Requests\Trainee\StoreCardioSessionRequest;
use App\Http\Requests\Trainee\UpdateCardioSessionRequest;
use App\Http\Resources\CardioSessionResource;
use App\Models\CardioSession;
use App\Services\Audit\AuditLogger;
use App\Support\Pagination\PaginationConfig;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class CardioSessionController extends Controller
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    public function index(Request $request): JsonResponse
    {
        $filters = $request->validate([
            'from' => ['sometimes', 'date_format:Y-m-d', 'before_or_equal:today'],
            'to' => ['sometimes', 'date_format:Y-m-d', 'before_or_equal:today'],
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ]);

        [$from, $to] = $this->dateRange($filters);

        $sessions = CardioSession::query()
            ->where('trainee_id', $request->user()->id)
            ->when($from !== null, fn ($query) => $query->whereBetween('performed_at', [$from->startOfDay(), $to->endOfDay()]))
            ->orderByDesc('performed_at')
            ->orderByDesc('id')
            ->paginate(PaginationConfig::perPage($filters['per_page'] ?? null));

        return CardioSessionResource::collection($sessions)->response();
    }

    public function store(StoreCardioSessionRequest $request): JsonResponse
    {
        $session = DB::transaction(function () use ($request) {
            $session = CardioSession::create([
                ...$request->validated(),
                'trainee_id' => $request->user()->id,
            ]);

            $this->auditLogger->log($request->user(), AuditAction::CARDIO_SESSION_CREATED->value, $session, [
                'activity_type' => $session->activity_type->value,
                'duration_seconds' => $session->duration_seconds,
            ]);

            return $session;
        });

        return (new CardioSessionResource($session))->response()->setStatusCode(201);
    }

    public function show(Request $request, CardioSession $cardio): JsonResponse
    {
        $owned = $this->findOwned($request, $cardio);

        return (new CardioSessionResource($owned))->response();
    }

    public function update(UpdateCardioSessionRequest $request, CardioSession $cardio): JsonResponse
    {
        $owned = $this->findOwned($request, $cardio);
        $data = $request->validated();

        DB::transaction(function () use ($request, $owned, $data) {
            $owned->update($data);

            $this->auditLogger->log($request->user(), AuditAction::CARDIO_SESSION_UPDATED->value, $owned, [
                'activity_type' => $owned->activity_type->value,
                'fields' => array_keys($data),
            ]);
        });

        return (new CardioSessionResource($owned->fresh()))->response();
    }

    public function destroy(Request $request, CardioSession $cardio): JsonResponse
    {
        $owned = $this->findOwned($request, $cardio);

        DB::transaction(function () use ($request, $owned) {
            $this->auditLogger->log($request->user(), AuditAction::CARDIO_SESSION_DELETED->value, $owned, [
                'activity_type' => $owned->activity_type->value,
            ]);

            $owned->delete();
        });

        return response()->json(null, 204);
    }

    private function findOwned(Request $request, CardioSession $session): CardioSession
    {
        return CardioSession::query()
            ->where('trainee_id', $request->user()->id)
            ->findOrFail($session->id);
    }

    /**
     * @return array{0: CarbonImmutable|null, 1: CarbonImmutable|null}
     */
    private function dateRange(array $filters): array
    {
        if (! isset($filters['from']) && ! isset($filters['to'])) {
            return [null, null];
        }

        $to = isset($filters['to'])
            ? CarbonImmutable::parse($filters['to'])->startOfDay()
            : CarbonImmutable::today();
        $from = isset($filters['from'])
            ? CarbonImmutable::parse($filters['from'])->startOfDay()
            : $to->subDays(29);

        if ($from->gt($to)) {
            throw ValidationException::withMessages([
                'from' => 'The start date must be before or equal to the end date.',
            ]);
        }

        if ($from->diffInDays($to) + 1 > 366) {
            throw ValidationException::withMessages([
                'from' => 'The cardio range cannot exceed 366 days.',
            ]);
        }

        return [$from, $to];
    }
}
