@extends('layouts.dashboard')

@section('title', 'Vouchers & Promotions')

@section('content')
    <div class="table-card">
        <div class="table-header">
            <div class="table-title">Voucher Discount Registry</div>
        </div>
        <table>
            <thead>
                <tr>
                    <th>Voucher Code</th>
                    <th>Benefit / Discount</th>
                    <th>Type</th>
                    <th>Redemptions</th>
                    <th>Valid Until</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                @foreach($vouchers as $v)
                    <tr>
                        <td><strong style="color: var(--metallic-gold); letter-spacing: 1px;">{{ $v['code'] }}</strong></td>
                        <td>{{ $v['discount'] }}</td>
                        <td><span class="badge badge-gold">{{ $v['type'] }}</span></td>
                        <td>{{ $v['used_count'] }} / {{ $v['max_uses'] }}</td>
                        <td>{{ $v['expires_at'] }}</td>
                        <td>
                            <span class="badge {{ $v['is_active'] ? 'badge-active' : 'badge-danger' }}">
                                {{ $v['is_active'] ? 'Active' : 'Expired / Exhausted' }}
                            </span>
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>
@endsection
