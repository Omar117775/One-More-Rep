<?php

namespace App\Http\Controllers\Api\V1\Trainee;

use App\Enums\Enums\AuditAction;
use App\Http\Controllers\Controller;
use App\Http\Requests\Trainee\StoreBodyMeasurementRequest;
use App\Http\Requests\Trainee\UpdateBodyMeasurementRequest;
use App\Http\Resources\BodyMeasurementResource;
use App\Models\BodyMeasurement;
use App\Services\Audit\AuditLogger;
use App\Support\Pagination\PaginationConfig;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class ProgressController extends Controller
{
    public function __construct(private readonly AuditLogger $auditLogger) {}

    public function index(Request $request): JsonResponse
    {
        $perPage = PaginationConfig::perPage($request->integer('per_page') ?: null);

        $measurements = BodyMeasurement::query()
            ->where('trainee_id', $request->user()->id)
            ->orderByDesc('measured_on')
            ->orderByDesc('id')
            ->paginate($perPage);

        return BodyMeasurementResource::collection($measurements)->response();
    }

    public function store(StoreBodyMeasurementRequest $request): JsonResponse
    {
        $measurement = DB::transaction(function () use ($request) {
            $measurement = BodyMeasurement::create([
                ...$request->validated(),
                'trainee_id' => $request->user()->id,
            ]);

            $this->auditLogger->log($request->user(), AuditAction::BODY_MEASUREMENT_CREATED->value, $measurement, [
                'trainee_id' => $request->user()->id,
                'fields' => array_keys($request->validated()),
            ]);

            return $measurement;
        });

        return (new BodyMeasurementResource($measurement))->response()->setStatusCode(201);
    }

    public function show(Request $request, BodyMeasurement $measurement): JsonResponse
    {
        $this->assertOwned($request, $measurement);

        return (new BodyMeasurementResource($measurement))->response();
    }

    public function update(UpdateBodyMeasurementRequest $request, BodyMeasurement $measurement): JsonResponse
    {
        $this->assertOwned($request, $measurement);

        $data = $request->validated();
        $measurementFields = ['weight_kg', 'body_fat_percentage', 'waist_cm', 'chest_cm', 'arm_cm'];

        $merged = array_merge(
            $measurement->only($measurementFields),
            array_intersect_key($data, array_flip($measurementFields)),
        );

        if (count(array_filter($merged, fn ($value) => $value !== null)) === 0) {
            throw ValidationException::withMessages([
                'measurements' => 'At least one measurement value is required.',
            ]);
        }

        DB::transaction(function () use ($request, $measurement, $data, $measurementFields) {
            $measurement->update($data);

            $this->auditLogger->log($request->user(), AuditAction::BODY_MEASUREMENT_UPDATED->value, $measurement, [
                'trainee_id' => $measurement->trainee_id,
                'fields' => array_values(array_intersect(array_keys($data), $measurementFields)),
            ]);
        });

        return (new BodyMeasurementResource($measurement->fresh()))->response();
    }

    public function destroy(Request $request, BodyMeasurement $measurement): JsonResponse
    {
        $this->assertOwned($request, $measurement);

        DB::transaction(function () use ($request, $measurement) {
            $this->auditLogger->log($request->user(), AuditAction::BODY_MEASUREMENT_DELETED->value, $measurement, [
                'trainee_id' => $measurement->trainee_id,
            ]);

            $measurement->delete();
        });

        return response()->json(null, 204);
    }

    private function assertOwned(Request $request, BodyMeasurement $measurement): void
    {
        abort_unless($measurement->trainee_id === $request->user()->id, 404);
    }
}
