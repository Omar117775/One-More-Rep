@extends('layouts.dashboard')

@section('title', 'Workout Programs')

@section('content')
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Authored Workout Programs</div>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Program Title</th>
                    <th>Description</th>
                    <th>Days</th>
                    <th>Exercises Breakdown</th>
                    <th>Active Trainees</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @forelse($programs as $prog)
                    <tr>
                        <td><strong>{{ $prog->name }}</strong></td>
                        <td style="max-width: 300px; color: var(--neutral-gray); font-size: 13px;">{{ $prog->description }}</td>
                        <td><span class="badge badge-gold">{{ $prog->days->count() }} Training Days</span></td>
                        <td>
                            @foreach($prog->days as $day)
                                <div style="font-size: 12px; margin-bottom: 2px;">
                                    <strong>Day {{ $day->day_number }}:</strong> {{ $day->name }} ({{ $day->exercises->count() }} exercises)
                                </div>
                            @endforeach
                        </td>
                        <td>{{ $prog->assignments->where('status.value', 'active')->count() }} Active</td>
                        <td>
                            <span class="badge {{ $prog->is_active ? 'badge-active' : 'badge-inactive' }}">
                                {{ $prog->is_active ? 'Active' : 'Archived' }}
                            </span>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" style="text-align: center; color: var(--neutral-gray); padding: 30px;">
                            No programs found.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
