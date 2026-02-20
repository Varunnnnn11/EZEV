<%@page import="com.ezev.entities.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Security Check
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Host & Earn - EzEv</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --bright-snow: #FAFAFA;
            --pale-slate: #D2D7DF;
            --dusk-blue: #2E5077;
            --deep-navy: #00003D;
            --coffee-bean: #14010B;
            --success-green: #10B981;
            --warning-orange: #F59E0B;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--bright-snow);
            color: var(--coffee-bean);
            min-height: 100vh;
        }

        /* Background Grid Pattern */
        .grid-bg {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background-image: 
                linear-gradient(var(--pale-slate) 1px, transparent 1px),
                linear-gradient(90deg, var(--pale-slate) 1px, transparent 1px);
            background-size: 30px 30px; opacity: 0.2; z-index: -1;
        }

        /* Navbar */
        .navbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 20px 40px; background: white; border-bottom: 1px solid var(--pale-slate);
            position: sticky; top: 0; z-index: 100;
        }
        .logo { font-size: 1.5rem; font-weight: 800; color: var(--deep-navy); text-decoration: none; display: flex; align-items: center; gap: 10px; }
        .nav-link { text-decoration: none; color: var(--dusk-blue); font-weight: 600; font-size: 0.95rem; }

        /* Main Layout */
        .main-container {
            max-width: 1200px; margin: 40px auto; display: grid;
            grid-template-columns: 1.2fr 0.8fr; gap: 40px; padding: 0 20px;
        }

        /* Left Column: Form */
        .form-section h1 { font-size: 2.2rem; margin-bottom: 10px; color: var(--deep-navy); }
        .form-section p { color: var(--dusk-blue); margin-bottom: 30px; }

        .form-card {
            background: white; padding: 35px; border-radius: 24px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.05); border: 1px solid white;
        }

        .input-group { margin-bottom: 20px; }
        .input-group label { display: block; font-size: 0.9rem; font-weight: 700; margin-bottom: 8px; color: var(--deep-navy); }
        
        .input-wrapper { position: relative; }
        .input-wrapper i {
            position: absolute; left: 15px; top: 50%; transform: translateY(-50%);
            color: var(--dusk-blue); font-size: 1.1rem;
        }
        
        input, select, textarea {
            width: 100%; padding: 14px 14px 14px 45px;
            border: 2px solid var(--pale-slate); border-radius: 12px;
            font-size: 1rem; font-family: inherit; transition: all 0.3s;
            background: var(--bright-snow);
        }
        textarea { resize: vertical; min-height: 100px; padding-left: 15px; } /* No icon for textarea */
        
        input:focus, select:focus, textarea:focus {
            border-color: var(--dusk-blue); outline: none; background: white;
            box-shadow: 0 0 0 4px rgba(46, 80, 119, 0.1);
        }

        .row { display: flex; gap: 20px; }
        .col { flex: 1; }

        /* Location Button */
        .location-btn {
            background: rgba(16, 185, 129, 0.1); color: var(--success-green);
            border: none; padding: 10px 15px; border-radius: 8px;
            font-weight: 700; cursor: pointer; display: flex; align-items: center; gap: 8px;
            font-size: 0.9rem; transition: 0.3s; margin-top: 8px; width: 100%; justify-content: center;
        }
        .location-btn:hover { background: rgba(16, 185, 129, 0.2); transform: translateY(-1px); }

        /* Submit Button */
        .btn-submit {
            width: 100%; padding: 16px; margin-top: 10px;
            background: linear-gradient(135deg, var(--dusk-blue), var(--deep-navy));
            color: white; border: none; border-radius: 12px;
            font-size: 1.1rem; font-weight: 700; cursor: pointer;
            box-shadow: 0 10px 20px rgba(46, 80, 119, 0.3); transition: all 0.3s;
        }
        .btn-submit:hover { transform: translateY(-3px); box-shadow: 0 15px 30px rgba(46, 80, 119, 0.4); }

        /* Right Column: Preview & Earnings */
        .preview-section { position: sticky; top: 100px; height: fit-content; }

        .preview-card {
            background: linear-gradient(135deg, #ffffff 0%, #f3f4f6 100%);
            border-radius: 24px; padding: 30px;
            border: 2px dashed var(--pale-slate); text-align: center;
        }
        
        .preview-badge {
            background: var(--deep-navy); color: white; padding: 5px 12px;
            border-radius: 20px; font-size: 0.75rem; text-transform: uppercase; font-weight: 700;
            display: inline-block; margin-bottom: 15px;
        }

        .preview-image {
            width: 80px; height: 80px; background: white; border-radius: 16px;
            display: flex; align-items: center; justify-content: center;
            font-size: 2.5rem; box-shadow: 0 10px 20px rgba(0,0,0,0.1); margin: 0 auto 20px;
        }

        .preview-title { font-size: 1.4rem; font-weight: 800; color: var(--coffee-bean); margin-bottom: 5px; }
        .preview-address { font-size: 0.9rem; color: var(--dusk-blue); margin-bottom: 20px; }

        .preview-stats {
            display: flex; justify-content: center; gap: 15px; margin-bottom: 25px;
            background: white; padding: 15px; border-radius: 16px;
        }
        .stat-box { text-align: center; }
        .stat-val { font-weight: 800; color: var(--deep-navy); font-size: 1.1rem; }
        .stat-lbl { font-size: 0.75rem; color: #888; text-transform: uppercase; font-weight: 600; }

        .earnings-card {
            margin-top: 25px; background: var(--deep-navy); color: white;
            padding: 25px; border-radius: 20px; position: relative; overflow: hidden;
        }
        .earnings-card::before {
            content: ''; position: absolute; top: -50px; right: -50px;
            width: 100px; height: 100px; background: rgba(255,255,255,0.1); border-radius: 50%;
        }
        .earnings-val { font-size: 2.5rem; font-weight: 800; color: var(--success-green); }
        
        @media (max-width: 900px) {
            .main-container { grid-template-columns: 1fr; }
            .preview-section { display: none; } /* Hide preview on mobile for simplicity */
        }
    </style>
</head>
<body>

    <div class="grid-bg"></div>

    <nav class="navbar">
        <a href="Dashboard.jsp" class="logo">
            <img src="ezev-logo.png" alt="EzEv" style="height: 40px;"> EzEv
        </a>
        <a href="Dashboard.jsp" class="nav-link">Cancel & Exit</a>
    </nav>

    <div class="main-container">
        
        <section class="form-section">
            <h1>Host a Charger</h1>
            <p>Turn your parking spot into income. Join 500+ hosts on EzEv.</p>

            <div class="form-card">
                <form action="AddStationServlet" method="post">
                    <input type="hidden" name="stationCategory" value="RESIDENTIAL">

                    <div class="input-group">
                        <label>Station Nickname</label>
                        <div class="input-wrapper">
                            <i class="fa-solid fa-charging-station"></i>
                            <input type="text" name="stationName" id="inputName" placeholder="e.g. Varun's Home Charger" required oninput="updatePreview()">
                        </div>
                    </div>

                    <div class="input-group">
                        <label>Location & Address</label>
                        <textarea name="stationAddress" id="inputAddress" placeholder="Full address details (Street, Landmark, City)" required oninput="updatePreview()"></textarea>
                        <button type="button" class="location-btn" onclick="getLocation()">
                            <i class="fa-solid fa-location-crosshairs"></i> Detect My Current Location
                        </button>
                    </div>

                    <div class="row">
                        <div class="col">
                            <div class="input-group">
                                <label>Latitude</label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-map-pin"></i>
                                    <input type="number" step="any" name="latitude" id="lat" placeholder="0.00" required>
                                </div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="input-group">
                                <label>Longitude</label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-map-pin"></i>
                                    <input type="number" step="any" name="longitude" id="lng" placeholder="0.00" required>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col">
                            <div class="input-group">
                                <label>Connector Type</label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-plug"></i>
                                    <select name="connectorType" id="inputType" onchange="updatePreview()">
                                        <option value="Wall Socket">Standard Wall Socket (3-Pin)</option>
                                        <option value="Type 2 AC">Type 2 AC (7.2kW)</option>
                                        <option value="DC Fast">DC Fast (CCS2)</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div class="col">
                            <div class="input-group">
                                <label>Price per Unit (₹/kWh)</label>
                                <div class="input-wrapper">
                                    <i class="fa-solid fa-indian-rupee-sign"></i>
                                    <input type="number" step="0.01" name="pricePerUnit" id="inputPrice" placeholder="e.g. 15.00" required oninput="updatePreview()">
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="input-group">
                        <label>Description / Access Instructions</label>
                        <textarea name="stationDescription" rows="3" placeholder="e.g. Call before arriving. Gate code is 1234."></textarea>
                    </div>

                    <button type="submit" class="btn-submit">Publish Station</button>
                </form>
            </div>
        </section>

        <section class="preview-section">
            <div class="preview-card">
                <span class="preview-badge">Live Preview</span>
                <div class="preview-image">⚡</div>
                <h3 class="preview-title" id="prevName">My Station</h3>
                <p class="preview-address" id="prevAddress">Address will appear here</p>

                <div class="preview-stats">
                    <div class="stat-box">
                        <div class="stat-val" id="prevType">Socket</div>
                        <div class="stat-lbl">Type</div>
                    </div>
                    <div class="stat-box">
                        <div class="stat-val" id="prevPrice">₹0</div>
                        <div class="stat-lbl">Per Unit</div>
                    </div>
                </div>
            </div>

            <div class="earnings-card">
                <div style="font-size: 0.9rem; opacity: 0.8; margin-bottom: 5px;">Potential Monthly Earnings</div>
                <div class="earnings-val" id="calcEarnings">₹0</div>
                <div style="font-size: 0.8rem; margin-top: 10px; opacity: 0.6;">*Based on 4 hours daily usage</div>
            </div>
        </section>

    </div>

    <script>
        // 1. Live Preview Logic
        function updatePreview() {
            // Get values
            const name = document.getElementById('inputName').value || "My Station";
            const address = document.getElementById('inputAddress').value || "Address will appear here";
            const type = document.getElementById('inputType').value;
            const price = parseFloat(document.getElementById('inputPrice').value) || 0;

            // Update Preview Card
            document.getElementById('prevName').innerText = name;
            document.getElementById('prevAddress').innerText = address.substring(0, 30) + (address.length > 30 ? "..." : "");
            document.getElementById('prevType').innerText = type.split(" ")[0]; // Just take first word
            document.getElementById('prevPrice').innerText = "₹" + price;

            // Update Earnings Calculator (Price * 4 hours * 7kW avg * 30 days) - Rough estimate
            // Assuming 1 hour charge = 7 units approx for AC, 2 units for socket
            let unitsPerHour = type.includes("Socket") ? 2 : 7;
            let monthlyEarnings = price * unitsPerHour * 4 * 30; 
            
            document.getElementById('calcEarnings').innerText = "₹" + monthlyEarnings.toLocaleString();
        }

        // 2. Geolocation Logic
        function getLocation() {
            const btn = document.querySelector('.location-btn');
            const originalText = btn.innerHTML;
            
            if (navigator.geolocation) {
                btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Detecting...';
                
                navigator.geolocation.getCurrentPosition(function(position) {
                    document.getElementById('lat').value = position.coords.latitude.toFixed(6);
                    document.getElementById('lng').value = position.coords.longitude.toFixed(6);
                    btn.innerHTML = '<i class="fa-solid fa-check"></i> Location Found!';
                    btn.style.background = "rgba(16, 185, 129, 0.2)";
                }, function(error) {
                    alert("Error getting location: " + error.message);
                    btn.innerHTML = originalText;
                });
            } else {
                alert("Geolocation is not supported by this browser.");
            }
        }
    </script>
</body>
</html>