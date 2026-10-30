@extends('layouts.dashboard')

@section('title', 'User Management & Access Control')

@section('content')
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">All System Accounts</div>
            <form action="{{ route('admin.users') }}" method="GET" style="display: flex; gap: 10px;">
                <input type="text" name="search" value="{{ $search }}" placeholder="Search name or email..." style="padding: 8px 14px; background: #0d0d0d; border: 1px solid rgba(255, 255, 255, 0.15); border-radius: 6px; color: var(--warm-white); font-size: 13px;">
                <select name="role" style="padding: 8px 14px; background: #0d0d0d; border: 1px solid rgba(255, 255, 255, 0.15); border-radius: 6px; color: var(--warm-white); font-size: 13px;">
                    <option value="">All Roles</option>
                    @foreach($roles as $r)
                        <option value="{{ $r->name }}" {{ $currentRole === $r->name ? 'selected' : '' }}>{{ ucfirst($r->name) }}</option>
                    @endforeach
                </select>
                <button type="submit" class="btn-gold" style="padding: 8px 14px;">Filter</button>
            </form>
        </div>
        <table>
            <thead>
                <tr>
                    <th>User ID</th>
                    <th>Name</th>
                    <th>Email Address</th>
                    <th>Assigned Roles</th>
                    <th>Status</th>
                    <th>Joined</th>
                    <th>Access Control</th>
                </tr>
            </thead>
            <tbody>
                @forelse($users as $user)
                    <tr>
                        <td>#{{ $user->id }}</td>
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
                        <td>{{ $user->created_at ? $user->created_at->format('Y-m-d') : 'N/A' }}</td>
                        <td>
                            @if($user->id !== Auth::id())
                                <form action="{{ route('admin.users.toggle', $user->id) }}" method="POST" style="display: inline;">
                                    @csrf
                                    <button type="submit" class="btn-outline" style="padding: 4px 10px; font-size: 11.5px; border-color: {{ $user->is_active ? 'var(--danger)' : 'var(--success)' }}; color: {{ $user->is_active ? 'var(--danger)' : 'var(--success)' }};">
                                        {{ $user->is_active ? 'Disable Account' : 'Enable Account' }}
                                    </button>
                                </form>
                            @else
                                <span style="color: var(--neutral-gray); font-size: 12px;">(Current Session)</span>
                            @endif
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="7" style="text-align: center; color: var(--neutral-gray); padding: 30px;">
                            No users found.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
        <div style="padding: 16px 24px;">
            {{ $users->links() }}
        </div>
    </div>
@endsection
