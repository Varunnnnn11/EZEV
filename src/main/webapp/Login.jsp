<%@page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - EZEV</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap');

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background: linear-gradient(135deg, #0a192f 0%, #112240 50%, #0a192f 100%);
            background-size: 400% 400%;
            animation: gradientShift 12s ease infinite;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
            overflow: hidden;
            position: relative;
        }

        @keyframes gradientShift {

            0%,
            100% {
                background-position: 0% 50%;
            }

            50% {
                background-position: 100% 50%;
            }
        }

        /* ── Floating Background Particles ── */
        .bg-particle {
            position: fixed;
            border-radius: 50%;
            background: rgba(0, 184, 148, 0.15);
            pointer-events: none;
            animation: floatUp linear infinite;
        }

        @keyframes floatUp {
            0% {
                transform: translateY(100vh) scale(0);
                opacity: 0;
            }

            10% {
                opacity: 1;
            }

            90% {
                opacity: 1;
            }

            100% {
                transform: translateY(-10vh) scale(1);
                opacity: 0;
            }
        }

        /* ── Login Card ── */
        .login-card {
            background: rgba(255, 255, 255, 0.97);
            width: 100%;
            max-width: 900px;
            border-radius: 24px;
            display: flex;
            box-shadow: 0 25px 80px rgba(0, 0, 0, 0.35);
            overflow: hidden;
            flex-wrap: wrap;
            position: relative;
            z-index: 1;
            /* Entrance animation */
            animation: cardEntrance 0.8s cubic-bezier(0.22, 1, 0.36, 1) both;
            /* 3D tilt */
            transition: transform 0.15s ease-out, box-shadow 0.15s ease-out;
            transform-style: preserve-3d;
            perspective: 1000px;
        }

        @keyframes cardEntrance {
            from {
                opacity: 0;
                transform: translateY(60px) scale(0.95);
            }

            to {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        /* ── Illustration Side ── */
        .illustration {
            width: 45%;
            background: linear-gradient(180deg, #0a192f 0%, #112240 60%, #0d2137 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 200px;
            position: relative;
            overflow: hidden;
        }

        /* Shooting stars in illustration */
        .shooting-star {
            position: absolute;
            width: 2px;
            height: 2px;
            background: white;
            border-radius: 50%;
            box-shadow: 0 0 6px 2px rgba(255, 255, 255, 0.6);
            animation: shoot 3s linear infinite;
            opacity: 0;
        }

        @keyframes shoot {
            0% {
                transform: translate(0, 0);
                opacity: 0;
            }

            5% {
                opacity: 1;
            }

            40% {
                opacity: 1;
            }

            50% {
                transform: translate(-120px, 80px);
                opacity: 0;
            }

            100% {
                opacity: 0;
            }
        }

        /* ── Form Side ── */
        .form-section {
            width: 55%;
            padding: 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            animation: formSlideIn 0.9s cubic-bezier(0.22, 1, 0.36, 1) 0.2s both;
        }

        @keyframes formSlideIn {
            from {
                opacity: 0;
                transform: translateX(30px);
            }

            to {
                opacity: 1;
                transform: translateX(0);
            }
        }

        h1 {
            font-size: 28px;
            margin-bottom: 5px;
            color: #2d3436;
            animation: fadeInUp 0.5s ease 0.4s both;
        }

        .subtitle {
            color: #636e72;
            margin-bottom: 25px;
            font-size: 14px;
            animation: fadeInUp 0.5s ease 0.5s both;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(12px);
            }

            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        /* ── Floating Label Input Group ── */
        .input-group {
            margin-bottom: 28px;
            position: relative;
            animation: fadeInUp 0.5s ease both;
        }

        .input-group:nth-child(1) {
            animation-delay: 0.55s;
        }

        .input-group:nth-child(2) {
            animation-delay: 0.65s;
        }

        .input-group label {
            position: absolute;
            top: 10px;
            left: 0;
            font-size: 14px;
            color: #b2bec3;
            pointer-events: none;
            transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
        }

        .input-group input:focus~label,
        .input-group input.filled~label {
            top: -14px;
            font-size: 11px;
            color: #00b894;
            letter-spacing: 0.5px;
        }

        .input-group input {
            width: 100%;
            padding: 10px 0;
            border: none;
            border-bottom: 2px solid #dfe6e9;
            font-size: 15px;
            font-family: 'Poppins', sans-serif;
            outline: none;
            background: transparent;
            transition: border-color 0.3s;
        }

        /* Animated underline */
        .input-group::after {
            content: '';
            position: absolute;
            bottom: 20px;
            left: 50%;
            width: 0;
            height: 2px;
            background: linear-gradient(90deg, #00b894, #0984e3);
            transition: all 0.4s cubic-bezier(0.22, 1, 0.36, 1);
            transform: translateX(-50%);
        }

        .input-group:focus-within::after {
            width: 100%;
        }

        .input-group input:focus {
            border-bottom-color: transparent;
        }

        .input-group input.input-error {
            border-bottom-color: #d63031;
        }

        .input-group input.input-ok {
            border-bottom-color: #00b894;
        }

        /* Validation hint text */
        .hint {
            font-size: 11px;
            margin-top: 4px;
            min-height: 14px;
            transition: all 0.3s;
            opacity: 0;
            transform: translateY(-4px);
        }

        .hint.visible {
            opacity: 1;
            transform: translateY(0);
        }

        .hint.error {
            color: #d63031;
        }

        .hint.ok {
            color: #00b894;
        }

        .toggle-password {
            position: absolute;
            right: 0;
            bottom: 10px;
            cursor: pointer;
            color: #b2bec3;
            user-select: none;
            transition: all 0.2s;
            font-size: 16px;
        }

        .toggle-password:hover {
            color: #636e72;
            transform: scale(1.15);
        }

        /* ── Button ── */
        button.login-btn {
            width: 100%;
            background: linear-gradient(135deg, #00b894, #00cec9);
            color: white;
            padding: 15px;
            border-radius: 30px;
            border: none;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            transition: all 0.3s cubic-bezier(0.22, 1, 0.36, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            position: relative;
            overflow: hidden;
            animation: fadeInUp 0.5s ease 0.75s both;
        }

        button.login-btn:hover {
            background: linear-gradient(135deg, #0984e3, #6c5ce7);
            box-shadow: 0 8px 25px rgba(9, 132, 227, 0.45);
            transform: translateY(-2px);
        }

        button.login-btn:active {
            transform: translateY(0) scale(0.98);
        }

        button.login-btn.loading {
            opacity: 0.75;
            cursor: not-allowed;
        }

        /* Button ripple */
        .ripple {
            position: absolute;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.4);
            transform: scale(0);
            animation: rippleEffect 0.6s ease-out;
            pointer-events: none;
        }

        @keyframes rippleEffect {
            to {
                transform: scale(4);
                opacity: 0;
            }
        }

        /* Spinner */
        .spinner {
            display: none;
            width: 16px;
            height: 16px;
            border: 2px solid rgba(255, 255, 255, 0.4);
            border-top-color: white;
            border-radius: 50%;
            animation: spin 0.7s linear infinite;
        }

        button.login-btn.loading .spinner {
            display: block;
        }

        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }

        /* ── Alert Box ── */
        .alert {
            padding: 10px;
            border-radius: 8px;
            font-size: 13px;
            text-align: center;
            margin-bottom: 15px;
            animation: alertBounce 0.5s cubic-bezier(0.22, 1, 0.36, 1);
        }

        .alert-error {
            background-color: #fab1a0;
            color: #d63031;
        }

        .alert-success {
            background-color: #55efc4;
            color: #006266;
        }

        @keyframes alertBounce {
            0% {
                opacity: 0;
                transform: translateY(-15px) scale(0.95);
            }

            60% {
                transform: translateY(3px) scale(1.02);
            }

            100% {
                opacity: 1;
                transform: translateY(0) scale(1);
            }
        }

        /* ── Shake for invalid ── */
        @keyframes shake {

            0%,
            100% {
                transform: translateX(0);
            }

            20% {
                transform: translateX(-8px);
            }

            40% {
                transform: translateX(8px);
            }

            60% {
                transform: translateX(-4px);
            }

            80% {
                transform: translateX(4px);
            }
        }

        .shake {
            animation: shake 0.4s ease;
        }

        /* ── PUPIL & EYELID ── */
        .pupil {
            transition: transform 0.08s ease-out;
        }

        .eyelid {
            transform-origin: top center;
            transform: scaleY(0);
            transition: transform 0.2s ease-in-out;
        }

        .illustration.blind .eyelid {
            transform: scaleY(1);
        }

        @keyframes blink {

            0%,
            92%,
            100% {
                transform: scaleY(0);
            }

            95% {
                transform: scaleY(1);
            }
        }

        .eyelid.blinking {
            animation: blink 4s infinite;
        }

        /* ── SVG Hover Animations ── */
        #car-suv {
            transition: transform 0.4s ease;
        }

        #car-sedan {
            transition: transform 0.4s ease;
        }

        /* Pulsing Charging LED */
        .charging-led {
            animation: pulse 2s ease-in-out infinite;
        }

        @keyframes pulse {

            0%,
            100% {
                opacity: 0.4;
                r: 5;
            }

            50% {
                opacity: 1;
                r: 7;
            }
        }

        /* Spinning Wheels */
        .wheel {
            animation: wheelSpin 2s linear infinite;
            transform-origin: center center;
        }

        @keyframes wheelSpin {
            to {
                transform: rotate(360deg);
            }
        }

        /* Electricity Flow on Cable */
        .cable-glow {
            animation: electricFlow 1.5s ease-in-out infinite;
        }

        @keyframes electricFlow {

            0%,
            100% {
                stroke: #112240;
                filter: none;
            }

            50% {
                stroke: #00b894;
                filter: drop-shadow(0 0 6px #00b894);
            }
        }

        /* ── Links ── */
        .form-links {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            margin-bottom: 20px;
            color: #636e72;
            animation: fadeInUp 0.5s ease 0.7s both;
        }

        .form-links a {
            color: #00b894;
            text-decoration: none;
            transition: color 0.2s;
        }

        .form-links a:hover {
            color: #0984e3;
        }

        .create-account {
            text-align: center;
            font-size: 12px;
            margin-top: 20px;
            color: #b2bec3;
            animation: fadeInUp 0.5s ease 0.85s both;
        }

        .create-account a {
            color: #0984e3;
            font-weight: bold;
            text-decoration: none;
            transition: color 0.2s;
        }

        .create-account a:hover {
            color: #6c5ce7;
        }

        @media (max-width: 768px) {
            .login-card {
                flex-direction: column;
            }

            .illustration {
                width: 100%;
                height: 220px;
            }

            .form-section {
                width: 100%;
                padding: 30px;
            }
        }
    </style>
</head>

<body>

<!-- Floating background particles (generated by JS) -->
<div id="particles"></div>

<div class="login-card" id="loginCard">

    <div class="illustration" id="illustration">
        <!-- Shooting stars -->
        <div class="shooting-star" style="top:10%; left:80%; animation-delay:0s;"></div>
        <div class="shooting-star" style="top:30%; left:60%; animation-delay:1.2s;"></div>
        <div class="shooting-star" style="top:50%; left:90%; animation-delay:2.5s;"></div>

        <svg viewBox="0 0 300 300" xmlns="http://www.w3.org/2000/svg" style="width:100%;">

            <!-- Twinkling Stars -->
            <circle cx="20" cy="20" r="1.5" fill="white" opacity="0">
                <animate attributeName="opacity" values="0;1;0" dur="3s" repeatCount="indefinite" />
            </circle>
            <circle cx="260" cy="30" r="1" fill="white" opacity="0">
                <animate attributeName="opacity" values="0;1;0" dur="2.5s" begin="0.8s"
                         repeatCount="indefinite" />
            </circle>
            <circle cx="50" cy="60" r="1" fill="white" opacity="0">
                <animate attributeName="opacity" values="0;1;0" dur="4s" begin="1.5s"
                         repeatCount="indefinite" />
            </circle>
            <circle cx="240" cy="130" r="1.5" fill="white" opacity="0">
                <animate attributeName="opacity" values="0;1;0" dur="2s" begin="0.3s"
                         repeatCount="indefinite" />
            </circle>
            <circle cx="280" cy="70" r="1" fill="white" opacity="0">
                <animate attributeName="opacity" values="0;1;0" dur="3.5s" begin="2s"
                         repeatCount="indefinite" />
            </circle>

            <!-- Charging Station -->
            <g id="charging-station" transform="translate(20, 40)">
                <rect x="0" y="0" width="80" height="200" rx="10" fill="#2c3e50" />
                <rect x="5" y="5" width="70" height="190" rx="5" fill="#34495e" opacity="0.6" />
                <text x="40" y="30" font-family="'Poppins', sans-serif" font-weight="bold" font-size="16"
                      fill="#00b894" text-anchor="middle">EZEV</text>
                <rect x="10" y="45" width="60" height="50" rx="5" fill="#000000" />

                <!-- Screen glow -->
                <rect x="12" y="47" width="56" height="46" rx="3" fill="#0a192f" opacity="0.8" />
                <text x="40" y="66" font-family="monospace" font-size="8" fill="#00b894" text-anchor="middle"
                      opacity="0.8">
                    <animate attributeName="opacity" values="0.4;1;0.4" dur="2s" repeatCount="indefinite" />
                    ⚡ READY
                </text>
                <rect x="18" y="72" width="44" height="4" rx="2" fill="#00b894" opacity="0.3">
                    <animate attributeName="width" values="0;44;0" dur="3s" repeatCount="indefinite" />
                </rect>

                <!-- Pulsing LED -->
                <circle class="charging-led" cx="40" cy="110" r="5" fill="#00b894" />

                <!-- Animated Cable -->
                <path class="cable-glow" d="M 80 80 Q 120 80 120 120 L 120 180" stroke="#112240"
                      stroke-width="8" fill="none" stroke-linecap="round" />

                <!-- Energy particles flowing through cable -->
                <circle r="3" fill="#00b894">
                    <animateMotion dur="2s" repeatCount="indefinite"
                                   path="M 80 80 Q 120 80 120 120 L 120 180" />
                    <animate attributeName="opacity" values="0;1;1;0" dur="2s" repeatCount="indefinite" />
                </circle>
                <circle r="2" fill="#55efc4">
                    <animateMotion dur="2s" begin="0.7s" repeatCount="indefinite"
                                   path="M 80 80 Q 120 80 120 120 L 120 180" />
                    <animate attributeName="opacity" values="0;1;1;0" dur="2s" begin="0.7s"
                             repeatCount="indefinite" />
                </circle>

                <rect x="110" y="180" width="20" height="30" rx="5" fill="#ffffff" />
            </g>

            <!-- SUV Car -->
            <g id="car-suv" transform="translate(100, 160)">
                <rect x="0" y="20" width="140" height="80" rx="15" fill="#00b894" />
                <rect x="10" y="0" width="120" height="40" rx="5" fill="#55efc4" />

                <!-- Wheels with spokes -->
                <g transform="translate(30, 100)">
                    <circle cx="0" cy="0" r="15" fill="#1e1e1e" />
                    <circle cx="0" cy="0" r="10" fill="#333" />
                    <g class="wheel">
                        <line x1="0" y1="-8" x2="0" y2="8" stroke="#555" stroke-width="1.5" />
                        <line x1="-8" y1="0" x2="8" y2="0" stroke="#555" stroke-width="1.5" />
                    </g>
                </g>
                <g transform="translate(110, 100)">
                    <circle cx="0" cy="0" r="15" fill="#1e1e1e" />
                    <circle cx="0" cy="0" r="10" fill="#333" />
                    <g class="wheel">
                        <line x1="0" y1="-8" x2="0" y2="8" stroke="#555" stroke-width="1.5" />
                        <line x1="-8" y1="0" x2="8" y2="0" stroke="#555" stroke-width="1.5" />
                    </g>
                </g>

                <!-- Eyes -->
                <g transform="translate(35, 50)">
                    <circle cx="0" cy="0" r="15" fill="white" />
                    <circle cx="70" cy="0" r="15" fill="white" />
                    <circle class="pupil suv-pupil" cx="0" cy="0" r="5" fill="black" />
                    <circle class="pupil suv-pupil" cx="70" cy="0" r="5" fill="black" />
                    <rect class="eyelid" x="-16" y="-16" width="32" height="32" fill="#00b894" />
                    <rect class="eyelid" x="54" y="-16" width="32" height="32" fill="#00b894" />
                </g>

                <!-- Idle bobbing -->
                <animateTransform attributeName="transform" type="translate" values="100,160;100,157;100,160"
                                  dur="3s" repeatCount="indefinite" />
            </g>

            <!-- Sedan Car -->
            <g id="car-sedan" transform="translate(190, 80) scale(0.6)">
                <path d="M 0 50 L 10 20 Q 40 10 100 10 Q 160 10 190 20 L 200 50 L 200 80 Q 100 90 0 80 Z"
                      fill="#f1f2f6" />

                <!-- Wheels with spokes -->
                <g transform="translate(40, 80)">
                    <circle cx="0" cy="0" r="15" fill="#1e1e1e" />
                    <circle cx="0" cy="0" r="10" fill="#333" />
                    <g class="wheel">
                        <line x1="0" y1="-8" x2="0" y2="8" stroke="#555" stroke-width="1.5" />
                        <line x1="-8" y1="0" x2="8" y2="0" stroke="#555" stroke-width="1.5" />
                    </g>
                </g>
                <g transform="translate(160, 80)">
                    <circle cx="0" cy="0" r="15" fill="#1e1e1e" />
                    <circle cx="0" cy="0" r="10" fill="#333" />
                    <g class="wheel">
                        <line x1="0" y1="-8" x2="0" y2="8" stroke="#555" stroke-width="1.5" />
                        <line x1="-8" y1="0" x2="8" y2="0" stroke="#555" stroke-width="1.5" />
                    </g>
                </g>

                <!-- Eyes -->
                <g transform="translate(50, 40)">
                    <circle cx="0" cy="0" r="12" fill="white" stroke="#bdc3c7" stroke-width="1" />
                    <circle cx="100" cy="0" r="12" fill="white" stroke="#bdc3c7" stroke-width="1" />
                    <circle class="pupil sedan-pupil" cx="0" cy="0" r="4" fill="#0a192f" />
                    <circle class="pupil sedan-pupil" cx="100" cy="0" r="4" fill="#0a192f" />
                    <rect class="eyelid" x="-13" y="-13" width="26" height="26" fill="#f1f2f6" />
                    <rect class="eyelid" x="87" y="-13" width="26" height="26" fill="#f1f2f6" />
                </g>

                <!-- Idle bobbing -->
                <animateTransform attributeName="transform" type="translate" values="190,80;190,78;190,80"
                                  dur="2.5s" begin="0.5s" repeatCount="indefinite" additive="replace" />
            </g>

        </svg>
    </div>

    <div class="form-section">
        <h1>Welcome Back</h1>
        <p class="subtitle">Log in to manage your charging.</p>

        <% String msg=(String) session.getAttribute("message"); if (msg !=null) { String
                alertClass=msg.contains("Success") ? "alert-success" : "alert-error" ; %>
        <div class="alert <%= alertClass %>">
            <%= msg %>
        </div>
        <% session.removeAttribute("message"); } %>

        <form action="LoginServlet" method="post" id="loginForm" novalidate>

            <div class="input-group">
                <input type="email" name="user_email" id="emailInput" class="track-input"
                       autocomplete="email">
                <label for="emailInput">Email Address</label>
                <div class="hint" id="emailHint"></div>
            </div>

            <div class="input-group">
                <input type="password" name="user_password" id="password"
                       autocomplete="current-password">
                <label for="password">Password</label>
                <span class="toggle-password" id="togglePassword"
                      title="Show / hide password">👁️</span>
                <div class="hint" id="passwordHint"></div>
            </div>

            <div class="form-links">
                <label style="cursor:pointer"><input type="checkbox"> Remember me</label>
                <a href="#">Forgot password?</a>
            </div>

            <button type="submit" class="login-btn" id="submitBtn">
                <span class="spinner"></span>
                <span id="btnText">Log In</span>
            </button>

            <p class="create-account">
                New here? <a href="Register.jsp">Create Account</a>
            </p>
        </form>
    </div>
</div>

<script>
    /* ═══════════════════════════════════════════
       FLOATING BACKGROUND PARTICLES
       ═══════════════════════════════════════════ */
    (function createParticles() {
        const container = document.getElementById('particles');
        for (let i = 0; i < 20; i++) {
            const p = document.createElement('div');
            p.className = 'bg-particle';
            const size = Math.random() * 8 + 3;
            p.style.cssText = `
                    width: ${size}px; height: ${size}px;
                    left: ${Math.random() * 100}%;
                    animation-duration: ${Math.random() * 10 + 8}s;
                    animation-delay: ${Math.random() * 10}s;
                `;
            container.appendChild(p);
        }
    })();

    /* ═══════════════════════════════════════════
       3D PARALLAX TILT ON CARD
       ═══════════════════════════════════════════ */
    const card = document.getElementById('loginCard');
    document.addEventListener('mousemove', e => {
        const cx = window.innerWidth / 2;
        const cy = window.innerHeight / 2;
        const dx = (e.clientX - cx) / cx;
        const dy = (e.clientY - cy) / cy;
        card.style.transform = `rotateY(${dx * 3}deg) rotateX(${-dy * 3}deg)`;
        card.style.boxShadow = `${-dx * 15}px ${dy * 15}px 60px rgba(0,0,0,0.3)`;
    });
    document.addEventListener('mouseleave', () => {
        card.style.transform = 'rotateY(0) rotateX(0)';
        card.style.boxShadow = '0 25px 80px rgba(0,0,0,0.35)';
    });

    /* ═══════════════════════════════════════════
       DOM REFERENCES
       ═══════════════════════════════════════════ */
    const emailInput = document.getElementById('emailInput');
    const passwordInput = document.getElementById('password');
    const illustration = document.getElementById('illustration');
    const suvPupils = document.querySelectorAll('.suv-pupil');
    const sedanPupils = document.querySelectorAll('.sedan-pupil');
    const allEyelids = document.querySelectorAll('.eyelid');
    const toggleBtn = document.getElementById('togglePassword');
    const submitBtn = document.getElementById('submitBtn');
    const btnText = document.getElementById('btnText');
    const emailHint = document.getElementById('emailHint');
    const passwordHint = document.getElementById('passwordHint');

    /* ═══════════════════════════════════════════
       HELPERS
       ═══════════════════════════════════════════ */
    function setHint(el, msg, type) {
        el.textContent = msg;
        el.className = 'hint' + (msg ? ' visible ' + type : '');
    }
    function markFilled(input) {
        input.value.trim() ? input.classList.add('filled') : input.classList.remove('filled');
    }

    /* Floating label state */
    [emailInput, passwordInput].forEach(inp => {
        inp.addEventListener('input', () => markFilled(inp));
        inp.addEventListener('change', () => markFilled(inp));
    });

    /* ═══════════════════════════════════════════
       REAL-TIME VALIDATION
       ═══════════════════════════════════════════ */
    emailInput.addEventListener('input', () => {
        const v = emailInput.value;
        if (!v) {
            setHint(emailHint, '', '');
            emailInput.classList.remove('input-error', 'input-ok');
            return;
        }
        const ok = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);
        emailInput.classList.toggle('input-error', !ok);
        emailInput.classList.toggle('input-ok', ok);
        setHint(emailHint, ok ? '✓ Looks good!' : 'Enter a valid email address.', ok ? 'ok' : 'error');
    });

    emailInput.addEventListener('blur', () => {
        if (!emailInput.value) {
            setHint(emailHint, '', '');
            emailInput.classList.remove('input-error', 'input-ok');
        }
    });

    passwordInput.addEventListener('input', () => {
        const v = passwordInput.value;
        if (!v) { setHint(passwordHint, '', ''); return; }
        if (v.length < 6) { setHint(passwordHint, 'Too short — at least 6 characters.', 'error'); return; }
        if (v.length < 10) { setHint(passwordHint, 'Decent — a longer password is stronger.', 'ok'); return; }
        setHint(passwordHint, '✓ Strong password!', 'ok');
    });

    /* ═══════════════════════════════════════════
       EYE MOVEMENT — MOUSE + EMAIL TYPING
       ═══════════════════════════════════════════ */
    const suvGroup = document.getElementById('car-suv');
    const sedanGroup = document.getElementById('car-sedan');
    let emailFocused = false;

    function setPupils(xOff, yOff) {
        [...suvPupils, ...sedanPupils].forEach(p =>
            p.style.transform = `translate(${xOff}px, ${yOff}px)`
        );
    }

    /* Mouse tracking */
    function movePupilsMouse(pupils, svgGroup, maxMove, e) {
        const rect = svgGroup.getBoundingClientRect();
        const cx = rect.left + rect.width / 2;
        const cy = rect.top + rect.height / 2;
        const dx = e.clientX - cx;
        const dy = e.clientY - cy;
        const angle = Math.atan2(dy, dx);
        const dist = Math.min(Math.hypot(dx, dy), 80);
        const factor = (dist / 80) * maxMove;
        pupils.forEach(p => p.style.transform =
            `translate(${Math.cos(angle) * factor}px, ${Math.sin(angle) * factor}px)`);
    }

    document.addEventListener('mousemove', e => {
        if (illustration.classList.contains('blind')) return;
        if (emailFocused) return;
        movePupilsMouse(suvPupils, suvGroup, 6, e);
        movePupilsMouse(sedanPupils, sedanGroup, 4, e);
    });

    document.addEventListener('mouseleave', () => {
        if (!emailFocused) setPupils(0, 0);
    });

    /* Email typing → left-to-right scan */
    const EMAIL_MAX_CHARS = 35;
    const MAX_X = 7;

    function updateEyesForEmail() {
        const pos = emailInput.selectionStart ?? emailInput.value.length;
        const ratio = Math.min(pos / EMAIL_MAX_CHARS, 1);
        const xOff = (ratio * 2 - 1) * MAX_X;
        const yOff = ratio * 2;
        setPupils(xOff, yOff);
    }

    emailInput.addEventListener('focus', () => {
        emailFocused = true;
        stopBlink();
        updateEyesForEmail();
    });
    emailInput.addEventListener('input', updateEyesForEmail);
    emailInput.addEventListener('keyup', updateEyesForEmail);
    emailInput.addEventListener('click', updateEyesForEmail);

    emailInput.addEventListener('blur', () => {
        emailFocused = false;
        setPupils(0, 0);
        startBlink();
    });

    /* ═══════════════════════════════════════════
       PERIODIC BLINK
       ═══════════════════════════════════════════ */
    function startBlink() { allEyelids.forEach(el => el.classList.add('blinking')); }
    function stopBlink() { allEyelids.forEach(el => el.classList.remove('blinking')); }
    startBlink();

    /* ═══════════════════════════════════════════
       PASSWORD PRIVACY (BLIND)
       ═══════════════════════════════════════════ */
    passwordInput.addEventListener('focus', () => {
        if (passwordInput.type === 'password') {
            stopBlink();
            illustration.classList.add('blind');
        }
    });
    passwordInput.addEventListener('blur', () => {
        illustration.classList.remove('blind');
        startBlink();
    });

    /* ═══════════════════════════════════════════
       TOGGLE PASSWORD
       ═══════════════════════════════════════════ */
    toggleBtn.addEventListener('click', () => {
        const isHidden = passwordInput.type === 'password';
        passwordInput.type = isHidden ? 'text' : 'password';
        toggleBtn.textContent = isHidden ? '🙈' : '👁️';
        if (isHidden) {
            illustration.classList.remove('blind');
            startBlink();
        } else if (document.activeElement === passwordInput) {
            stopBlink();
            illustration.classList.add('blind');
        }
    });

    /* ═══════════════════════════════════════════
       BUTTON RIPPLE EFFECT
       ═══════════════════════════════════════════ */
    submitBtn.addEventListener('click', function (e) {
        const rect = this.getBoundingClientRect();
        const ripple = document.createElement('span');
        ripple.className = 'ripple';
        const size = Math.max(rect.width, rect.height);
        ripple.style.width = ripple.style.height = size + 'px';
        ripple.style.left = (e.clientX - rect.left - size / 2) + 'px';
        ripple.style.top = (e.clientY - rect.top - size / 2) + 'px';
        this.appendChild(ripple);
        ripple.addEventListener('animationend', () => ripple.remove());
    });

    /* ═══════════════════════════════════════════
       SUBMIT — LOADING STATE + VALIDATION
       ═══════════════════════════════════════════ */
    document.getElementById('loginForm').addEventListener('submit', function (e) {
        const email = emailInput.value;
        const pass = passwordInput.value;
        let valid = true;

        if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            emailInput.parentElement.classList.add('shake');
            emailInput.classList.add('input-error');
            setHint(emailHint, 'Please enter a valid email.', 'error');
            valid = false;
        }
        if (!pass || pass.length < 6) {
            passwordInput.parentElement.classList.add('shake');
            setHint(passwordHint, 'Password must be at least 6 characters.', 'error');
            valid = false;
        }

        if (!valid) {
            e.preventDefault();
            setTimeout(() => {
                document.querySelectorAll('.shake').forEach(el => el.classList.remove('shake'));
            }, 500);
            return;
        }

        submitBtn.classList.add('loading');
        submitBtn.disabled = true;
        btnText.textContent = 'Logging in…';
    });
</script>
</body>

</html>