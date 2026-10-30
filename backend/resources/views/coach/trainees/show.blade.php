@extends('layouts.dashboard')

@section('title', 'Trainee Profile: ' . $trainee->name)

@section('content')
    <div style="margin-bottom: 20px;">
        <a href="{{ route('coach.trainees') }}" class="btn-outline" style="font-size: 12px; padding: 6px 12px;">← Back to Trainees</a>
    </div>

    <!-- Trainee Summary Cards -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-label">Physical Stats</div>
            <div class="kpi-value" style="font-size: 22px;">
                @if($trainee->traineeProfile)
                    {{ $trainee->traineeProfile->height_cm }} cm / {{ $trainee->traineeProfile->initial_weight_kg }} kg
                @else
                    N/A
                @endif
            </div>
            <div class="kpi-sub">Gender: {{ ucfirst($trainee->traineeProfile->sex ?? 'Unknown') }}</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Total Workouts</div>
            <div class="kpi-value">{{ $trainee->workoutSessions->count() }}</div>
            <div class="kpi-sub">Logged strength sessions</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Cardio Sessions</div>
            <div class="kpi-value">{{ $trainee->cardioSessions->count() }}</div>
            <div class="kpi-sub">Logged endurance sessions</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Measurements</div>
            <div class="kpi-value">{{ $trainee->bodyMeasurements->count() }}</div>
            <div class="kpi-sub">Logged body weight/fat records</div>
        </div>
    </div>

    <!-- Program Assignments -->
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Assigned Workout Programs</div>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Program</th>
                    <th>Starts On</th>
                    <th>Ends On</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @forelse($trainee->workoutAssignments as $assignment)
                    <tr>
                        <td><strong>{{ $assignment->program->name ?? 'Custom Program' }}</strong></td>
                        <td>{{ $assignment->starts_on ? $assignment->starts_on->toFormattedDateString() : 'N/A' }}</td>
                        <td>{{ $assignment->ends_on ? $assignment->ends_on->toFormattedDateString() : 'N/A' }}</td>
                        <td>
                            <span class="badge {{ $assignment->status->value === 'active' ? 'badge-active' : 'badge-inactive' }}">
                                {{ ucfirst($assignment->status->value) }}
                            </span>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" style="text-align: center; color: var(--neutral-gray); padding: 20px;">
                            No programs assigned yet.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Recent Body Measurements -->
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Recent Body Measurements</div>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Weight (kg)</th>
                    <th>Body Fat %</th>
                    <th>Chest (cm)</th>
                    <th>Waist (cm)</th>
                    <th>Arms (cm)</th>
                </tr>
            </thead>
            <tbody>
                @forelse($trainee->bodyMeasurements as $measurement)
                    <tr>
                        <td>{{ $measurement->recorded_at ? $measurement->recorded_at->toFormattedDateString() : 'N/A' }}</td>
                        <td><strong>{{ $measurement->weight_kg }}</strong></td>
                        <td>{{ $measurement->body_fat_percentage ? $measurement->body_fat_percentage . '%' : '—' }}</td>
                        <td>{{ $measurement->chest_cm ?? '—' }}</td>
                        <td>{{ $measurement->waist_cm ?? '—' }}</td>
                        <td>{{ $measurement->biceps_cm ?? '—' }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" style="text-align: center; color: var(--neutral-gray); padding: 20px;">
                            No measurements recorded yet.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
