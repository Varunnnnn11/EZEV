<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Join EZEV - Go Electric</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600&display=swap');
        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: #e0f7fa; 
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
        }

        .login-card {
            background: white;
            width: 100%;
            max-width: 900px;
            border-radius: 20px;
            display: flex;
            box-shadow: 0 10px 40px rgba(10, 25, 47, 0.2);
            overflow: hidden;
            flex-wrap: wrap; 
        }

        /* ILLUSTRATION SIDE */
        .illustration {
            width: 45%;
            background-color: #0a192f; /* Deep Navy Background */
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 200px;
            position: relative;
            overflow: hidden;
        }

        /* FORM SIDE */
        .form-section {
            width: 55%;
            padding: 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        h1 { font-size: 28px; margin-bottom: 5px; color: #0a192f; }
        
        .input-group { margin-bottom: 15px; position: relative; }
        label { display: block; font-size: 12px; color: #636e72; margin-bottom: 5px; }
        
        input {
            width: 100%; padding: 10px 0; border: none; border-bottom: 2px solid #dfe6e9;
            font-size: 15px; font-family: 'Poppins', sans-serif; outline: none; background: transparent;
            transition: border-color 0.3s;
        }
        input:focus { border-bottom-color: #00b894; }

        .toggle-password {
            position: absolute; right: 0; bottom: 10px; cursor: pointer; color: #b2bec3;
        }

        button.register-btn {
            width: 100%; background-color: #0a192f; color: white; padding: 15px;
            border-radius: 30px; border: none; font-size: 16px; font-weight: 600;
            cursor: pointer; margin-top: 15px; transition: 0.3s;
        }
        button.register-btn:hover { 
            background-color: #00b894; 
            box-shadow: 0 4px 15px rgba(0, 184, 148, 0.4); 
        }

        /* --- ANIMATION CLASSES --- */
        .pupil { transition: transform 0.1s ease-out; }
        
        .eyelid { 
            transform-origin: top center; 
            transform: scaleY(0); 
            transition: transform 0.2s ease-in-out; 
        }
        
        .illustration.blind .eyelid { transform: scaleY(1); }

        @media (max-width: 768px) {
            .login-card { flex-direction: column; }
            .illustration { width: 100%; height: 240px; }
            .form-section { width: 100%; padding: 30px; }
        }
    </style>
</head>
<body>

    <div class="login-card">
        
        <div class="illustration" id="illustration">
             <svg viewBox="0 0 300 300" xmlns="http://www.w3.org/2000/svg" style="width:100%;">
                
                <g id="charging-station" transform="translate(20, 40)">
                    <rect x="0" y="0" width="80" height="200" rx="10" fill="#2c3e50"/>
                    <rect x="5" y="5" width="70" height="190" rx="5" fill="#34495e" opacity="0.6"/>
                    
                    <text x="40" y="30" font-family="'Poppins', sans-serif" font-weight="bold" font-size="16" fill="#00b894" text-anchor="middle">EZEV</text>

                    <rect x="10" y="45" width="60" height="50" rx="5" fill="#000000"/>
                    
                    <circle cx="40" cy="110" r="5" fill="#00b894"/>
                    
                    <path d="M 80 80 Q 120 80 120 120 L 120 180" stroke="#112240" stroke-width="8" fill="none"/>
                    <rect x="110" y="180" width="20" height="30" rx="5" fill="#ffffff"/>
                </g>

                <g id="car-sedan" transform="translate(110, 160)">
                    <path d="M 0 50 L 10 20 Q 40 10 100 10 Q 160 10 190 20 L 200 50 L 200 80 Q 100 90 0 80 Z" fill="#f1f2f6"/>
                    <circle cx="40" cy="80" r="15" fill="#1e1e1e"/>
                    <circle cx="160" cy="80" r="15" fill="#1e1e1e"/>
                    <g transform="translate(50, 40)">
                        <circle cx="0" cy="0" r="12" fill="white" stroke="#bdc3c7" stroke-width="1"/> 
                        <circle cx="100" cy="0" r="12" fill="white" stroke="#bdc3c7" stroke-width="1"/>
                        <circle class="pupil" cx="0" cy="0" r="4" fill="#0a192f"/> 
                        <circle class="pupil" cx="100" cy="0" r="4" fill="#0a192f"/>
                        <rect class="eyelid" x="-13" y="-13" width="26" height="26" fill="#f1f2f6"/>
                        <rect class="eyelid" x="87" y="-13" width="26" height="26" fill="#f1f2f6"/>
                    </g>
                </g>

                <g id="car-suv" transform="translate(180, 80) scale(0.6)">
                    <rect x="0" y="20" width="140" height="80" rx="15" fill="#00b894"/>
                    <rect x="10" y="0" width="120" height="40" rx="5" fill="#55efc4"/>
                    <circle cx="30" cy="100" r="15" fill="#1e1e1e"/>
                    <circle cx="110" cy="100" r="15" fill="#1e1e1e"/>
                    <g transform="translate(35, 50)">
                         <circle cx="0" cy="0" r="15" fill="white"/> <circle cx="70" cy="0" r="15" fill="white"/>
                         <circle class="pupil" cx="0" cy="0" r="5" fill="black"/> <circle class="pupil" cx="70" cy="0" r="5" fill="black"/>
                         <rect class="eyelid" x="-16" y="-16" width="32" height="32" fill="#00b894"/>
                         <rect class="eyelid" x="54" y="-16" width="32" height="32" fill="#00b894"/>
                    </g>
                </g>

            </svg>
        </div>

        <div class="form-section">
            <h1>Create Account</h1>
            <p style="color:#636e72; margin-bottom:25px; font-size:14px;">Join the EZEV fleet.</p>

            <form action="RegisterServlet" method="post">
                <div class="input-group">
                    <label>Full Name</label>
                    <input type="text" name="user_name" class="track-input" required>
                </div>
                <div class="input-group">
                    <label>Email Address</label>
                    <input type="email" name="user_email" class="track-input" required>
                </div>
                <div class="input-group">
                    <label>Phone Number</label>
                    <input type="number" name="user_phone" class="track-input" required>
                </div>
                <div class="input-group">
                    <label>Password</label>
                    <input type="password" name="user_password" id="password" required>
                    <span class="toggle-password" id="togglePassword">👁️</span>
                </div>
                <input type="hidden" name="user_type" value="normal">
                <button type="submit" class="register-btn">Register</button>
                <p style="text-align:center; font-size:12px; margin-top:15px; color:#b2bec3;">
                    Already a member? <a href="Login.jsp" style="color:#0a192f; font-weight:bold; text-decoration:none;">Login Here</a>
                </p>
            </form>
        </div>
    </div>

    <script>
        const trackInputs = document.querySelectorAll('.track-input');
        const passwordInput = document.getElementById('password');
        const illustration = document.getElementById('illustration');
        const pupils = document.querySelectorAll('.pupil');
        const toggleBtn = document.getElementById('togglePassword');

        // EYE TRACKING
        trackInputs.forEach(input => {
            input.addEventListener('input', (e) => {
                const val = e.target.value.length;
                const percentage = Math.min(val / 30, 1);
                const moveRange = 10; 
                const xOffset = (percentage * moveRange) - (moveRange / 2);
                const yOffset = percentage * 3;
                
                pupils.forEach(pupil => {
                    pupil.style.transform = `translate(${xOffset}px, ${yOffset}px)`;
                });
            });
            input.addEventListener('blur', () => {
                pupils.forEach(pupil => {
                    pupil.style.transform = `translate(0px, 0px)`;
                });
            });
        });

        // PRIVACY MODE
        passwordInput.addEventListener('focus', () => {
            if(passwordInput.type === 'password') illustration.classList.add('blind');
        });
        passwordInput.addEventListener('blur', () => illustration.classList.remove('blind'));

        // TOGGLE PASSWORD
        toggleBtn.addEventListener('click', () => {
            if (passwordInput.type === "password") {
                passwordInput.type = "text";
                toggleBtn.textContent = "🙈"; 
                illustration.classList.remove('blind'); 
            } else {
                passwordInput.type = "password";
                toggleBtn.textContent = "👁️";
                if (document.activeElement === passwordInput) illustration.classList.add('blind');
            }
        });
    </script>
</body>
</html>