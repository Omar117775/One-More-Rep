@extends('layouts.dashboard')

@section('title', 'Trainees Roster')

@section('content')
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">All Assigned Trainees</div>
            <form action="{{ route('coach.trainees') }}" method="GET" style="display: flex; gap: 10px;">
                <input type="text" name="search" value="{{ $search }}" placeholder="Search by name or email..." style="padding: 8px 14px; background: #0d0d0d; border: 1px solid rgba(255, 255, 255, 0.15); border-radius: 6px; color: var(--warm-white); font-size: 13px;">
                <button type="submit" class="btn-gold" style="padding: 8px 14px;">Filter</button>
            </form>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Trainee</th>
                    <th>Email</th>
                    <th>Current Active Program</th>
                    <th>Assigned Since</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                @forelse($relationships as $rel)
                    <tr>
                        <td><strong>{{ $rel->trainee->name }}</strong></td>
                        <td>{{ $rel->trainee->email }}</td>
                        <td>
                            @php
                                $activeAssignment = $rel->trainee->workoutAssignments->firstWhere('status.value', 'active');
                            @endphp
                            @if($activeAssignment && $activeAssignment->program)
                                <span class="badge badge-gold">{{ $activeAssignment->program->name }}</span>
                            @else
                                <span style="color: var(--neutral-gray)">None Assigned</span>
                            @endif
                        </td>
                        <td>{{ $rel->started_at ? \Illuminate\Support\Carbon::parse($rel->started_at)->toFormattedDateString() : 'N/A' }}</td>
                        <td><span class="badge badge-active">{{ $rel->status }}</span></td>
                        <td>
                            <a href="{{ route('coach.trainees.show', $rel->trainee->id) }}" class="btn-outline" style="padding: 4px 10px; font-size: 12px;">Review Profile</a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" style="text-align: center; color: var(--neutral-gray); padding: 30px;">
                            No trainees matched your filter.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
