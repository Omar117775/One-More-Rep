@extends('layouts.dashboard')

@section('title', 'Global System Analytics')

@section('content')
    <!-- Global Analytics KPIs -->
    <div class="kpi-grid">
        <div class="kpi-card">
            <div class="kpi-label">Total Registered Users</div>
            <div class="kpi-value">{{ $totalUsers }}</div>
            <div class="kpi-sub">{{ $traineeCount }} Trainees / {{ $coachCount }} Coaches</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Active Coaching Links</div>
            <div class="kpi-value">{{ $activeRelationships }}</div>
            <div class="kpi-sub">Verified coach-trainee pairs</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">System Protocols</div>
            <div class="kpi-value">{{ $totalPrograms }}</div>
            <div class="kpi-sub">{{ $totalExercises }} Catalog exercises</div>
        </div>
        <div class="kpi-card">
            <div class="kpi-label">Logged Workouts</div>
            <div class="kpi-value">{{ $totalSessionsLogged }}</div>
            <div class="kpi-sub">Total database session rows</div>
        </div>
    </div>

    <!-- Recent Users Table -->
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Recent User Registrations</div>
            <a href="{{ route('admin.users') }}" class="btn-outline">Open Directory</a>
        </div>
        <table>
            <thead>
                <tr>
                    <th>User</th>
                    <th>Email</th>
                    <th>Role(s)</th>
                    <th>Status</th>
                    <th>Joined</th>
                </tr>
            </thead>
            <tbody>
                @forelse($recentUsers as $user)
                    <tr>
                        <td><strong>{{ $user->name }}</strong></td>
                        <td>{{ $user->email }}</td>
                        <td>
                            @foreach($user->roles as $role)
                                <span class="badge badge-gold">{{ $role->name }}</span>
                            @endforeach
                        </td>
                        <td>
                            <span class="badge {{ $user->is_active ? 'badge-active' : 'badge-danger' }}">
                                {{ $user->is_active ? 'Active' : 'Disabled' }}
                            </span>
                        </td>
                        <td>{{ $user->created_at ? $user->created_at->diffForHumans() : 'N/A' }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" style="text-align: center; color: var(--neutral-gray); padding: 20px;">
                            No users registered yet.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Recent Audit Logs Table -->
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Security & System Audit Log</div>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Timestamp</th>
                    <th>Actor</th>
                    <th>Action</th>
                    <th>Target Entity</th>
                    <th>IP Address</th>
                </tr>
            </thead>
            <tbody>
                @forelse($recentAuditLogs as $log)
                    <tr>
                        <td>{{ $log->created_at ? $log->created_at->format('M d, H:i:s') : 'N/A' }}</td>
                        <td>{{ $log->user->name ?? 'System' }}</td>
                        <td><span class="badge badge-gold">{{ $log->action }}</span></td>
                        <td>{{ class_basename($log->auditable_type ?? 'Entity') }} #{{ $log->auditable_id ?? '—' }}</td>
                        <td style="color: var(--neutral-gray)">{{ $log->ip_address ?? '127.0.0.1' }}</td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" style="text-align: center; color: var(--neutral-gray); padding: 20px;">
                            Audit log is clean.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>
@endsection
