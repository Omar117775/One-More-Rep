@extends('layouts.dashboard')

@section('title', 'Subscription Plans & Tiers')

@section('content')
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 24px; margin-bottom: 30px;">
        @foreach($plans as $plan)
            <div class="kpi-card" style="padding: 28px;">
                <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 12px;">
                    <div style="font-size: 18px; font-weight: 800; color: var(--warm-white);">{{ $plan['name'] }}</div>
                    <span class="badge badge-gold">{{ $plan['duration'] }}</span>
                </div>
                <div style="font-size: 28px; font-weight: 800; color: var(--metallic-gold); margin-bottom: 6px;">
                    {{ $plan['price_egp'] }} EGP <span style="font-size: 14px; color: var(--neutral-gray);">(${{ $plan['price_usd'] }})</span>
                </div>
                <div style="font-size: 12px; color: var(--neutral-gray); margin-bottom: 20px;">
                    <strong>{{ $plan['active_members'] }}</strong> Active Subscribers
                </div>
                <div style="border-top: 1px solid var(--border-subtle); padding-top: 16px;">
                    <div style="font-size: 11px; text-transform: uppercase; letter-spacing: 0.8px; color: var(--metallic-gold); font-weight: 700; margin-bottom: 8px;">Plan Inclusions:</div>
                    @foreach($plan['features'] as $feat)
                        <div style="font-size: 13px; color: var(--warm-white); margin-bottom: 6px;">✓ {{ $feat }}</div>
                    @endforeach
                </div>
            </div>
        @endforeach
    </div>
@endsection
