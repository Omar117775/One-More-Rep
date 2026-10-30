<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In — ONE MORE REP Portal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --deep-black: #080808;
            --secondary-black: #111111;
            --card-surface: #141414;
            --metallic-gold: #C6A15B;
            --metallic-bronze: #9B763B;
            --warm-white: #F3F0E8;
            --neutral-gray: #929292;
            --border-subtle: rgba(198, 161, 91, 0.22);
            --danger: #EF4444;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Manrope', -apple-system, sans-serif;
            background: var(--deep-black);
            color: var(--warm-white);
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 20px;
        }

        .login-card {
            width: 100%;
            max-width: 420px;
            background: var(--card-surface);
            border: 1px solid var(--border-subtle);
            border-radius: 16px;
            padding: 40px 32px;
            box-shadow: 0 10px 35px rgba(0, 0, 0, 0.6), 0 0 25px rgba(198, 161, 91, 0.08);
            text-align: center;
        }

        .spartan-logo {
            width: 58px;
            height: 58px;
            background: linear-gradient(135deg, var(--metallic-gold), var(--metallic-bronze));
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            color: var(--deep-black);
            font-size: 26px;
            margin-bottom: 20px;
            box-shadow: 0 6px 20px rgba(198, 161, 91, 0.3);
        }

        .login-title {
            font-size: 20px;
            font-weight: 800;
            letter-spacing: 1.5px;
            margin-bottom: 6px;
        }

        .login-subtitle {
            font-size: 13px;
            color: var(--neutral-gray);
            margin-bottom: 30px;
        }

        .form-group {
            text-align: left;
            margin-bottom: 20px;
        }

        label {
            display: block;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            font-weight: 700;
            color: var(--metallic-gold);
            margin-bottom: 8px;
        }

        input[type="email"], input[type="password"] {
            width: 100%;
            padding: 13px 16px;
            background: #0d0d0d;
            border: 1px solid rgba(255, 255, 255, 0.12);
            border-radius: 8px;
            color: var(--warm-white);
            font-size: 14px;
            font-family: inherit;
            outline: none;
            transition: border-color 0.2s;
        }

        input[type="email"]:focus, input[type="password"]:focus {
            border-color: var(--metallic-gold);
        }

        .btn-submit {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, var(--metallic-gold), var(--metallic-bronze));
            color: var(--deep-black);
            font-size: 13.5px;
            font-weight: 800;
            letter-spacing: 1.2px;
            text-transform: uppercase;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: opacity 0.2s;
            margin-top: 10px;
        }

        .btn-submit:hover {
            opacity: 0.9;
        }

        .error-banner {
            background: rgba(239, 68, 68, 0.12);
            border: 1px solid rgba(239, 68, 68, 0.35);
            color: var(--danger);
            padding: 12px;
            border-radius: 8px;
            font-size: 13px;
            margin-bottom: 20px;
            text-align: left;
        }

        .demo-accounts {
            margin-top: 28px;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            text-align: left;
            font-size: 11.5px;
            color: var(--neutral-gray);
            line-height: 1.6;
        }

        .demo-accounts strong {
            color: var(--metallic-gold);
        }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="spartan-logo">Ω</div>
        <h2 class="login-title">ONE MORE REP</h2>
        <p class="login-subtitle">Coach & Super Admin Command Console</p>

        @if ($errors->any())
            <div class="error-banner">
                @foreach ($errors->all() as $error)
                    <div>• {{ $error }}</div>
                @endforeach
            </div>
        @endif

        <form action="{{ route('login') }}" method="POST">
            @csrf
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" value="{{ old('email') }}" required autofocus autocomplete="email" placeholder="name@onemorerep.fit">
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required autocomplete="current-password" placeholder="••••••••">
            </div>

            <button type="submit" class="btn-submit">Sign In to Console</button>
        </form>

        <div class="demo-accounts">
            <div><strong>Coach:</strong> coach@onemorerep.fit / coach 1234</div>
            <div><strong>Super Admin:</strong> admin@onemorerep.fit / admin 1234</div>
        </div>
    </div>
</body>
</html>
