<?php

namespace App\Services\Training;

use App\Models\BodyMeasurement;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Support\Facades\DB;

class AnalyticsService
{
    /**
     * Build a range-limited overview from aggregate queries. Only daily rows in
     * the requested window are loaded; weekly buckets are derived in PHP so the
     * response stays consistent across PostgreSQL and SQLite.
     */
    public function forTrainee(User $trainee, CarbonImmutable $from, CarbonImmutable $to): array
    {
        $start = $from->startOfDay();
        $end = $to->endOfDay();

        $workoutDays = DB::table('workout_sessions')
            ->leftJoin('workout_sets', 'workout_sets.workout_session_id', '=', 'workout_sessions.id')
            ->where('workout_sessions.trainee_id', $trainee->id)
            ->whereBetween('workout_sessions.started_at', [$start, $end])
            ->groupByRaw('DATE(workout_sessions.started_at)')
            ->orderByRaw('DATE(workout_sessions.started_at)')
            ->selectRaw('DATE(workout_sessions.started_at) as activity_day')
            ->selectRaw('COUNT(DISTINCT workout_sessions.id) as sessions')
            ->selectRaw('COUNT(DISTINCT CASE WHEN workout_sessions.completed_at IS NOT NULL THEN workout_sessions.id END) as completed_sessions')
            ->selectRaw('COUNT(workout_sets.id) as sets')
            ->selectRaw('COALESCE(SUM(CASE WHEN workout_sets.is_completed THEN 1 ELSE 0 END), 0) as completed_sets')
            ->selectRaw('COALESCE(SUM(CASE WHEN workout_sets.is_completed THEN workout_sets.reps ELSE 0 END), 0) as reps')
            ->selectRaw('COALESCE(SUM(CASE WHEN workout_sets.is_completed THEN workout_sets.weight_kg * workout_sets.reps ELSE 0 END), 0) as volume_kg')
            ->get();

        $cardioDays = DB::table('cardio_sessions')
            ->where('trainee_id', $trainee->id)
            ->whereBetween('performed_at', [$start, $end])
            ->groupByRaw('DATE(performed_at)')
            ->orderByRaw('DATE(performed_at)')
            ->selectRaw('DATE(performed_at) as activity_day')
            ->selectRaw('COUNT(*) as sessions')
            ->selectRaw('COALESCE(SUM(duration_seconds), 0) as duration_seconds')
            ->selectRaw('COALESCE(SUM(distance_km), 0) as distance_km')
            ->get();

        $workouts = $this->workoutSummary($workoutDays);
        $cardio = $this->cardioSummary($cardioDays);

        $measurements = BodyMeasurement::query()
            ->where('trainee_id', $trainee->id)
            ->whereBetween('measured_on', [$from->toDateString(), $to->toDateString()])
            ->orderBy('measured_on')
            ->orderBy('id')
            ->get();

        $bodySeries = $measurements->map(fn (BodyMeasurement $measurement) => [
            'id' => $measurement->id,
            'measured_on' => $measurement->measured_on?->toDateString(),
            'weight_kg' => $measurement->weight_kg,
            'body_fat_percentage' => $measurement->body_fat_percentage,
            'waist_cm' => $measurement->waist_cm,
            'chest_cm' => $measurement->chest_cm,
            'arm_cm' => $measurement->arm_cm,
        ])->values()->all();

        return [
            'from' => $from->toDateString(),
            'to' => $to->toDateString(),
            'workouts' => $workouts,
            'cardio' => $cardio,
            'body' => [
                'has_data' => count($bodySeries) > 0,
                'series' => $bodySeries,
            ],
        ];
    }

    private function workoutSummary($rows): array
    {
        $weekly = [];

        foreach ($rows as $row) {
            $week = CarbonImmutable::parse((string) $row->activity_day)->startOfWeek(CarbonImmutable::MONDAY)->toDateString();

            if (! isset($weekly[$week])) {
                $weekly[$week] = [
                    'week_start' => $week,
                    'sessions' => 0,
                    'completed_sessions' => 0,
                    'sets' => 0,
                    'completed_sets' => 0,
                    'reps' => 0,
                    'volume_kg' => 0.0,
                ];
            }

            $weekly[$week]['sessions'] += (int) $row->sessions;
            $weekly[$week]['completed_sessions'] += (int) $row->completed_sessions;
            $weekly[$week]['sets'] += (int) $row->sets;
            $weekly[$week]['completed_sets'] += (int) $row->completed_sets;
            $weekly[$week]['reps'] += (int) $row->reps;
            $weekly[$week]['volume_kg'] += (float) $row->volume_kg;
        }

        $totals = [
            'sessions' => 0,
            'completed_sessions' => 0,
            'sets' => 0,
            'completed_sets' => 0,
            'reps' => 0,
            'volume_kg' => 0.0,
        ];

        foreach ($weekly as &$bucket) {
            $bucket['volume_kg'] = round($bucket['volume_kg'], 2);

            foreach ($totals as $key => $value) {
                $totals[$key] += $bucket[$key];
            }
        }
        unset($bucket);

        $totals['volume_kg'] = round($totals['volume_kg'], 2);

        return [
            'has_data' => $totals['sessions'] > 0,
            ...$totals,
            'weekly' => array_values($weekly),
        ];
    }

    private function cardioSummary($rows): array
    {
        $weekly = [];

        foreach ($rows as $row) {
            $week = CarbonImmutable::parse((string) $row->activity_day)->startOfWeek(CarbonImmutable::MONDAY)->toDateString();

            if (! isset($weekly[$week])) {
                $weekly[$week] = [
                    'week_start' => $week,
                    'sessions' => 0,
                    'duration_seconds' => 0,
                    'distance_km' => 0.0,
                ];
            }

            $weekly[$week]['sessions'] += (int) $row->sessions;
            $weekly[$week]['duration_seconds'] += (int) $row->duration_seconds;
            $weekly[$week]['distance_km'] += (float) $row->distance_km;
        }

        $totals = [
            'sessions' => 0,
            'duration_seconds' => 0,
            'distance_km' => 0.0,
        ];

        foreach ($weekly as &$bucket) {
            $bucket['distance_km'] = round($bucket['distance_km'], 2);

            foreach ($totals as $key => $value) {
                $totals[$key] += $bucket[$key];
            }
        }
        unset($bucket);

        $totals['distance_km'] = round($totals['distance_km'], 2);

        return [
            'has_data' => $totals['sessions'] > 0,
            ...$totals,
            'weekly' => array_values($weekly),
        ];
    }
}
