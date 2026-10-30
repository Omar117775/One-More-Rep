<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Dashboard') — ONE MORE REP</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --deep-black: #080808;
            --secondary-black: #111111;
            --dark-graphite: #191919;
            --card-surface: #141414;
            --card-surface-hover: #1c1c1c;
            --metallic-gold: #C6A15B;
            --metallic-bronze: #9B763B;
            --warm-white: #F3F0E8;
            --neutral-gray: #929292;
            --border-subtle: rgba(198, 161, 91, 0.18);
            --border-glow: rgba(198, 161, 91, 0.45);
            --danger: #EF4444;
            --success: #10B981;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Manrope', -apple-system, BlinkMacSystemFont, sans-serif;
            background-color: var(--deep-black);
            color: var(--warm-white);
            display: flex;
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* Sidebar */
        .sidebar {
            width: 260px;
            background: var(--secondary-black);
            border-right: 1px solid var(--border-subtle);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0;
            bottom: 0;
            left: 0;
            z-index: 100;
        }

        .brand-header {
            padding: 24px;
            display: flex;
            align-items: center;
            gap: 14px;
            border-bottom: 1px solid var(--border-subtle);
        }

        .spartan-icon {
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, var(--metallic-gold), var(--metallic-bronze));
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            color: var(--deep-black);
            font-size: 18px;
            box-shadow: 0 4px 14px rgba(198, 161, 91, 0.25);
        }

        .brand-title {
            font-size: 16px;
            font-weight: 800;
            letter-spacing: 1.5px;
            color: var(--warm-white);
        }

        .brand-subtitle {
            font-size: 10px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--metallic-gold);
            font-weight: 600;
        }

        .nav-menu {
            list-style: none;
            padding: 20px 14px;
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .nav-item a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 14px;
            border-radius: 8px;
            color: var(--neutral-gray);
            text-decoration: none;
            font-size: 13.5px;
            font-weight: 600;
            transition: all 0.2s ease;
        }

        .nav-item a:hover {
            color: var(--warm-white);
            background: var(--dark-graphite);
        }

        .nav-item.active a {
            color: var(--metallic-gold);
            background: rgba(198, 161, 91, 0.12);
            border: 1px solid var(--border-subtle);
        }

        .user-panel {
            padding: 18px 20px;
            background: var(--dark-graphite);
            border-top: 1px solid var(--border-subtle);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .user-info {
            display: flex;
            flex-direction: column;
        }

        .user-name {
            font-size: 13px;
            font-weight: 700;
            color: var(--warm-white);
        }

        .user-role {
            font-size: 11px;
            color: var(--metallic-gold);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .btn-logout {
            background: none;
            border: none;
            color: var(--neutral-gray);
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            padding: 6px 10px;
            border-radius: 6px;
            transition: all 0.2s;
        }

        .btn-logout:hover {
            color: var(--danger);
            background: rgba(239, 68, 68, 0.1);
        }

        /* Main Content */
        .main-wrapper {
            margin-left: 260px;
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .topbar {
            height: 70px;
            background: var(--secondary-black);
            border-bottom: 1px solid var(--border-subtle);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 32px;
            position: sticky;
            top: 0;
            z-index: 90;
        }

        .page-title {
            font-size: 20px;
            font-weight: 800;
            letter-spacing: 0.5px;
            color: var(--warm-white);
        }

        .portal-badge {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            padding: 4px 10px;
            border-radius: 20px;
            background: rgba(198, 161, 91, 0.15);
            color: var(--metallic-gold);
            border: 1px solid var(--border-subtle);
        }

        .content-body {
            padding: 32px;
            flex: 1;
        }

        /* KPI Cards */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .kpi-card {
            background: var(--card-surface);
            border: 1px solid var(--border-subtle);
            border-radius: 12px;
            padding: 22px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.4);
            transition: transform 0.2s, border-color 0.2s;
        }

        .kpi-card:hover {
            transform: translateY(-2px);
            border-color: var(--border-glow);
        }

        .kpi-label {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--neutral-gray);
            font-weight: 600;
            margin-bottom: 8px;
        }

        .kpi-value {
            font-size: 32px;
            font-weight: 800;
            color: var(--metallic-gold);
        }

        .kpi-sub {
            font-size: 11px;
            color: var(--neutral-gray);
            margin-top: 6px;
        }

        /* Generic Table Card */
        .table-card {
            background: var(--card-surface);
            border: 1px solid var(--border-subtle);
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.4);
            margin-bottom: 30px;
        }

        .table-header {
            padding: 20px 24px;
            border-bottom: 1px solid var(--border-subtle);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .table-title {
            font-size: 16px;
            font-weight: 700;
            color: var(--warm-white);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        th {
            background: var(--secondary-black);
            padding: 14px 24px;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--neutral-gray);
            font-weight: 700;
            border-bottom: 1px solid var(--border-subtle);
        }

        td {
            padding: 16px 24px;
            font-size: 13.5px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            color: var(--warm-white);
        }

        tr:hover td {
            background: rgba(255, 255, 255, 0.02);
        }

        /* Badges */
        .badge {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 6px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .badge-active, .badge-success {
            background: rgba(16, 185, 129, 0.15);
            color: #10B981;
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .badge-inactive, .badge-danger {
            background: rgba(239, 68, 68, 0.15);
            color: #EF4444;
            border: 1px solid rgba(239, 68, 68, 0.3);
        }

        .badge-gold {
            background: rgba(198, 161, 91, 0.15);
            color: var(--metallic-gold);
            border: 1px solid var(--border-subtle);
        }

        /* Flash Alerts */
        .alert {
            padding: 14px 20px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 13.5px;
            font-weight: 600;
        }

        .alert-success {
            background: rgba(16, 185, 129, 0.15);
            color: #10B981;
            border: 1px solid rgba(16, 185, 129, 0.4);
        }

        .alert-error {
            background: rgba(239, 68, 68, 0.15);
            color: #EF4444;
            border: 1px solid rgba(239, 68, 68, 0.4);
        }

        /* Buttons */
        .btn-gold {
            background: linear-gradient(135deg, var(--metallic-gold), var(--metallic-bronze));
            color: var(--deep-black);
            padding: 9px 18px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 700;
            text-decoration: none;
            border: none;
            cursor: pointer;
            display: inline-block;
            transition: opacity 0.2s;
        }

        .btn-gold:hover {
            opacity: 0.9;
        }

        .btn-outline {
            background: transparent;
            color: var(--metallic-gold);
            border: 1px solid var(--border-subtle);
            padding: 8px 16px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-outline:hover {
            background: rgba(198, 161, 91, 0.1);
            border-color: var(--metallic-gold);
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <aside class="sidebar">
        <div class="brand-header">
            <div class="spartan-icon">Ω</div>
            <div>
                <div class="brand-title">ONE MORE REP</div>
                <div class="brand-subtitle">
                    @if(Auth::user()->isSuperAdmin())
                        SUPER ADMIN CONSOLE
                    @else
                        COACH SUITE
                    @endif
                </div>
            </div>
        </div>

        <ul class="nav-menu">
            @if(Auth::user()->isSuperAdmin())
                <li class="nav-item {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                    <a href="{{ route('admin.dashboard') }}"><span>📊</span> Global Analytics</a>
                </li>
                <li class="nav-item {{ request()->routeIs('admin.users*') ? 'active' : '' }}">
                    <a href="{{ route('admin.users') }}"><span>👥</span> Users Directory</a>
                </li>
                <li class="nav-item {{ request()->routeIs('admin.subscriptions*') ? 'active' : '' }}">
                    <a href="{{ route('admin.subscriptions') }}"><span>💳</span> Subscription Plans</a>
                </li>
                <li class="nav-item {{ request()->routeIs('admin.vouchers*') ? 'active' : '' }}">
                    <a href="{{ route('admin.vouchers') }}"><span>🎟️</span> Vouchers & Promos</a>
                </li>
                <li class="nav-item {{ request()->routeIs('admin.payments*') ? 'active' : '' }}">
                    <a href="{{ route('admin.payments') }}"><span>💰</span> Payments & Cash</a>
                </li>
            @elseif(Auth::user()->isCoach())
                <li class="nav-item {{ request()->routeIs('coach.dashboard') ? 'active' : '' }}">
                    <a href="{{ route('coach.dashboard') }}"><span>⚔️</span> Coach Overview</a>
                </li>
                <li class="nav-item {{ request()->routeIs('coach.trainees*') ? 'active' : '' }}">
                    <a href="{{ route('coach.trainees') }}"><span>🏋️</span> Trainees Assigned</a>
                </li>
                <li class="nav-item {{ request()->routeIs('coach.programs*') ? 'active' : '' }}">
                    <a href="{{ route('coach.programs') }}"><span>📋</span> Workout Programs</a>
                </li>
                <li class="nav-item {{ request()->routeIs('coach.exercises*') ? 'active' : '' }}">
                    <a href="{{ route('coach.exercises') }}"><span>💪</span> Exercise Catalog</a>
                </li>
            @endif
        </ul>

        <div class="user-panel">
            <div class="user-info">
                <span class="user-name">{{ Auth::user()->name }}</span>
                <span class="user-role">{{ Auth::user()->roles->pluck('name')->first() }}</span>
            </div>
            <form action="{{ route('logout') }}" method="POST">
                @csrf
                <button type="submit" class="btn-logout" title="Sign Out">Sign Out</button>
            </form>
        </div>
    </aside>

    <!-- Main Content -->
    <div class="main-wrapper">
        <header class="topbar">
            <h1 class="page-title">@yield('title', 'Overview')</h1>
            <span class="portal-badge">
                {{ Auth::user()->isSuperAdmin() ? 'Global Administration' : 'Coach Portal' }}
            </span>
        </header>

        <main class="content-body">
            @if(session('success'))
                <div class="alert alert-success">{{ session('success') }}</div>
            @endif
            @if(session('error'))
                <div class="alert alert-error">{{ session('error') }}</div>
            @endif

            @yield('content')
        </main>
    </div>
</body>
</html>
