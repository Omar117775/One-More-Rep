@extends('layouts.dashboard')

@section('title', 'Coach Suite Overview')

@section('content')
    <!-- KPI Metrics -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-label">Assigned Trainees</div>
            <div class="kpi-value">{{ $traineeCount }}</div>
            <div class="kpi-sub">Direct coaching roster</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Workout Programs</div>
            <div class="kpi-value">{{ $programCount }}</div>
            <div class="kpi-sub">Designed protocols</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Active Assignments</div>
            <div class="kpi-value">{{ $activeAssignmentsCount }}</div>
            <div class="kpi-sub">In-progress trainee programs</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Exercise Library</div>
            <div class="kpi-value">{{ $exerciseCount }}</div>
            <div class="kpi-sub">Public & custom movements</div>
        </div>
    </div>

    <!-- Trainees Section -->
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Assigned Trainees Roster</div>
            <a href="{{ route('coach.trainees') }}" class="btn-outline">View All Trainees</a>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Trainee Name</th>
                    <th>Email</th>
                    <th>Height / Weight</th>
                    <th>Relationship</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                @forelse($trainees as $rel)
                    <tr>
                        <td><strong>{{ $rel->trainee->name }}</strong></td>
                        <td>{{ $rel->trainee->email }}</td>
                        <td>
                            @if($rel->trainee->traineeProfile)
                                {{ $rel->trainee->traineeProfile->height_cm }} cm / {{ $rel->trainee->traineeProfile->initial_weight_kg }} kg
                            @else
                                <span style="color: var(--neutral-gray)">Not specified</span>
                            @endif
                        </td>
                        <td><span class="badge badge-gold">{{ $rel->relationship_type }}</span></td>
                        <td><span class="badge badge-active">{{ $rel->status }}</span></td>
                        <td>
                            <a href="{{ route('coach.trainees.show', $rel->trainee->id) }}" class="btn-outline" style="padding: 4px 10px; font-size: 12px;">Review Profile</a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" style="text-align: center; color: var(--neutral-gray); padding: 30px;">
                            No trainees currently assigned.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Active Programs Section -->
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Your Workout Programs</div>
            <a href="{{ route('coach.programs') }}" class="btn-outline">Manage Programs</a>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Program Name</th>
                    <th>Description</th>
                    <th>Days</th>
                    <th>Total Exercises</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @forelse($programs as $prog)
                    <tr>
                        <td><strong>{{ $prog->name }}</strong></td>
                        <td style="max-width: 320px; font-size: 12.5px; color: var(--neutral-gray)">{{ $prog->description }}</td>
                        <td><span class="badge badge-gold">{{ $prog->days->count() }} Days</span></td>
                        <td>{{ $prog->days->sum(fn($d) => $d->exercises->count()) }} Movements</td>
                        <td>
                            <span class="badge {{ $prog->is_active ? 'badge-active' : 'badge-inactive' }}">
                                {{ $prog->is_active ? 'Active' : 'Archived' }}
                            </span>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" style="text-align: center; color: var(--neutral-gray); padding: 30px;">
                            No programs created yet.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
