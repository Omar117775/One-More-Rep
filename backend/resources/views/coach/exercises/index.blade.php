@extends('layouts.dashboard')

@section('title', 'Exercise Catalog')

@section('content')
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Exercise Library</div>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Exercise Name</th>
                    <th>Muscle Group</th>
                    <th>Equipment</th>
                    <th>Instructions Preview</th>
                    <th>Scope</th>
                </tr>
            </thead>
            <tbody>
                @forelse($exercises as $ex)
                    <tr>
                        <td><strong>{{ $ex->name }}</strong></td>
                        <td><span class="badge badge-gold">{{ ucfirst($ex->muscle_group) }}</span></td>
                        <td>{{ ucfirst($ex->equipment ?? 'None') }}</td>
                        <td style="max-width: 320px; font-size: 12.5px; color: var(--neutral-gray)">
                            {{ \Illuminate\Support\Str::limit($ex->instructions, 70) }}
                        </td>
                        <td>
                            <span class="badge {{ $ex->is_public ? 'badge-active' : 'badge-gold' }}">
                                {{ $ex->is_public ? 'Global Public' : 'Coach Custom' }}
                            </span>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="5" style="text-align: center; color: var(--neutral-gray); padding: 30px;">
                            No exercises available.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
        <div style="padding: 16px 24px;">
            {{ $exercises->links() }}
        </div>
    </div>
@endsection
