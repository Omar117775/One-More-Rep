@extends('layouts.dashboard')

@section('title', 'Manual Payments & Cash Reviews')

@section('content')
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Pending Payment Verifications (Vodafone Cash & InstaPay)</div>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Invoice ID</th>
                    <th>Trainee</th>
                    <th>Payment Method</th>
                    <th>Reference / Sender Mobile</th>
                    <th>Amount</th>
                    <th>Submitted</th>
                    <th>Review Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($pendingPayments as $p)
                    <tr>
                        <td><strong>{{ $p['id'] }}</strong></td>
                        <td>
                            <div>{{ $p['trainee_name'] }}</div>
                            <div style="font-size: 11px; color: var(--neutral-gray)">{{ $p['trainee_email'] }}</div>
                        </td>
                        <td><span class="badge badge-gold">{{ $p['method'] }}</span></td>
                        <td><code>{{ $p['reference'] }}</code></td>
                        <td><strong>{{ $p['amount'] }}</strong></td>
                        <td style="color: var(--neutral-gray)">{{ $p['submitted_at'] }}</td>
                        <td>
                            <button class="btn-gold" style="padding: 5px 12px; font-size: 12px;">Approve & Activate</button>
                            <button class="btn-outline" style="padding: 4px 10px; font-size: 12px; color: var(--danger); border-color: var(--danger);">Reject</button>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
@endsection
