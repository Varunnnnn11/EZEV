<%@page import="com.ezev.entities.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
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
  <title>AI Route Planner - EzEv</title>
  
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  
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

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      background: var(--bright-snow);
      color: var(--coffee-bean);
      min-height: 100vh;
    }

    .container { max-width: 1400px; margin: 0 auto; padding: 30px; }

    .header {
      background: white; padding: 20px; border-radius: 16px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.05); margin-bottom: 30px;
    }

    .header h1 { font-size: 2rem; color: var(--deep-navy); margin-bottom: 5px; }
    .header p { color: var(--dusk-blue); }

    .main-grid {
      display: grid; grid-template-columns: 400px 1fr; gap: 30px;
      align-items: start;
    }

    .sidebar {
      background: white; border-radius: 20px; padding: 30px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08); position: sticky; top: 30px;
    }

    .section-title {
      font-size: 1.1rem; color: var(--deep-navy); margin-bottom: 15px;
      font-weight: 700; display: flex; align-items: center; gap: 10px;
    }

    .input-group { margin-bottom: 20px; }
    .input-label { display: block; font-size: 0.9rem; font-weight: 600; color: var(--coffee-bean); margin-bottom: 8px; }

    input, select {
      width: 100%; padding: 12px 16px; border: 2px solid var(--pale-slate);
      border-radius: 12px; font-size: 1rem; font-family: inherit;
      transition: all 0.3s; background: var(--bright-snow);
    }

    input:focus, select:focus {
      outline: none; border-color: var(--dusk-blue);
      background: white; box-shadow: 0 0 0 4px rgba(46, 80, 119, 0.1);
    }

    .btn {
      width: 100%; padding: 16px; background: linear-gradient(135deg, var(--dusk-blue), var(--deep-navy));
      color: white; border: none; border-radius: 12px; font-size: 1.1rem;
      font-weight: 700; cursor: pointer; transition: all 0.3s;
      display: flex; align-items: center; justify-content: center; gap: 10px;
    }

    .btn:hover { transform: translateY(-2px); box-shadow: 0 10px 25px rgba(46, 80, 119, 0.3); }
    .btn:disabled { background: var(--pale-slate); cursor: not-allowed; transform: none; }

    .map-container {
      background: white; border-radius: 20px; padding: 20px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08); height: 600px;
    }

    #map { width: 100%; height: 100%; border-radius: 12px; }

    .results-section {
      background: white; border-radius: 20px; padding: 30px;
      box-shadow: 0 4px 20px rgba(0,0,0,0.08); margin-top: 30px;
      display: none;
    }

    .results-section.active { display: block; }

    .station-card {
      display: flex; align-items: center; gap: 20px; padding: 20px;
      border: 2px solid var(--pale-slate); border-radius: 16px;
      margin-bottom: 15px; transition: all 0.3s;
    }

    .station-card:hover { border-color: var(--dusk-blue); transform: translateX(5px); }

    .station-icon {
      width: 60px; height: 60px; background: linear-gradient(135deg, var(--dusk-blue), var(--deep-navy));
      border-radius: 12px; display: flex; align-items: center; justify-content: center;
      font-size: 1.5rem; flex-shrink: 0;
    }

    .station-info { flex: 1; }
    .station-name { font-size: 1.1rem; font-weight: 700; color: var(--coffee-bean); margin-bottom: 5px; }
    .station-address { font-size: 0.9rem; color: var(--dusk-blue); }

    .station-stats {
      display: flex; gap: 20px; margin-top: 10px; flex-wrap: wrap;
    }

    .stat-item {
      font-size: 0.85rem; padding: 6px 12px; background: var(--bright-snow);
      border-radius: 8px; display: flex; align-items: center; gap: 6px;
    }

    .book-btn {
      padding: 10px 24px; background: var(--success-green); color: white;
      border: none; border-radius: 10px; font-weight: 600;
      cursor: pointer; text-decoration: none; display: inline-block;
    }

    .book-btn:hover { background: #059669; }

    .loading {
      text-align: center; padding: 40px;
    }

    .spinner {
      width: 50px; height: 50px; border: 4px solid var(--pale-slate);
      border-top-color: var(--dusk-blue); border-radius: 50%;
      animation: spin 1s linear infinite; margin: 0 auto 20px;
    }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    .alert {
      padding: 15px; border-radius: 12px; margin-bottom: 20px;
      font-weight: 600; text-align: center;
    }

    .alert-error { background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA; }
    .alert-success { background: #D1FAE5; color: #065F46; border: 1px solid #A7F3D0; }

    @media (max-width: 1200px) {
      .main-grid { grid-template-columns: 1fr; }
      .sidebar { position: static; }
    }
  </style>
</head>
<body>

  <div class="container">
    <div class="header">
      <h1>🗺️ AI Route Planner</h1>
      <p>Plan your EV journey with smart charging recommendations</p>
    </div>

    <div class="main-grid">
      
      <aside class="sidebar">
        <h2 class="section-title">⚙️ Trip Details</h2>

        <div class="input-group">
          <label class="input-label">Vehicle Model</label>
          <select id="vehicleModel">
            <option value="Tata Nexon EV (312 km)" data-range="312">Tata Nexon EV (312 km)</option>
            <option value="Tata Tiago EV (250 km)" data-range="250">Tata Tiago EV (250 km)</option>
            <option value="MG ZS EV (419 km)" data-range="419">MG ZS EV (419 km)</option>
            <option value="Hyundai Ioniq 5 (631 km)" data-range="631">Hyundai Ioniq 5 (631 km)</option>
            <option value="Tesla Model 3 (500 km)" data-range="500">Tesla Model 3 (500 km)</option>
          </select>
        </div>

        <div class="input-group">
          <label class="input-label">Current Battery Level (%)</label>
          <input type="range" id="batterySlider" min="10" max="100" value="60" oninput="updateBatteryDisplay()">
          <div style="display: flex; justify-content: space-between; margin-top: 8px;">
            <span style="font-size: 0.85rem; color: #666;">10%</span>
            <span id="batteryValue" style="font-weight: 700; color: var(--success-green); font-size: 1.1rem;">60%</span>
            <span style="font-size: 0.85rem; color: #666;">100%</span>
          </div>
          <div style="margin-top: 10px; padding: 10px; background: var(--bright-snow); border-radius: 8px;">
            <div style="font-size: 0.85rem; color: #666;">Current Range</div>
            <div id="currentRange" style="font-size: 1.3rem; font-weight: 700; color: var(--dusk-blue);">250 km</div>
          </div>
        </div>

        <div class="input-group">
          <label class="input-label">Starting Location</label>
          <input type="text" id="startLocation" placeholder="e.g. Indore" value="Indore">
        </div>

        <div class="input-group">
          <label class="input-label">Destination</label>
          <input type="text" id="destination" placeholder="e.g. Delhi" value="Delhi">
        </div>

        <button class="btn" id="calculateBtn" onclick="calculateRoute()">
          <span>✨</span>
          <span>Calculate with AI</span>
        </button>
      </aside>

      <main>
        <div class="map-container">
          <div id="map"></div>
        </div>

        <section class="results-section" id="resultsSection">
          <h2 class="section-title">⚡ Recommended Charging Stops</h2>
          <div id="resultsContainer"></div>
        </section>
      </main>
    </div>
  </div>

  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  
  <script>
    let map;
    
    window.addEventListener('load', function() {
      map = L.map('map').setView([22.7196, 75.8577], 6);
      
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors'
      }).addTo(map);
      
      updateBatteryDisplay();
    });

    function updateBatteryDisplay() {
      const slider = document.getElementById('batterySlider');
      const value = slider.value;
      document.getElementById('batteryValue').textContent = value + '%';
      
      const select = document.getElementById('vehicleModel');
      const maxRange = parseInt(select.options[select.selectedIndex].dataset.range);
      const currentRange = Math.round((maxRange * value) / 100);
      
      document.getElementById('currentRange').textContent = currentRange + ' km';
    }

    function calculateRoute() {
      const btn = document.getElementById('calculateBtn');
      const resultsSection = document.getElementById('resultsSection');
      const resultsContainer = document.getElementById('resultsContainer');
      
      // Get values
      const vehicleSelect = document.getElementById('vehicleModel');
      const vehicleModel = vehicleSelect.value;
      const maxRange = parseInt(vehicleSelect.options[vehicleSelect.selectedIndex].dataset.range);
      const batteryLevel = parseInt(document.getElementById('batterySlider').value);
      const startLocation = document.getElementById('startLocation').value.trim();
      const destination = document.getElementById('destination').value.trim();
      
      // Validation
      if (!startLocation || !destination) {
        alert('Please enter both starting location and destination');
        return;
      }
      
      // Show loading
      btn.disabled = true;
      btn.innerHTML = '<div class="spinner"></div><span>AI is planning your route...</span>';
      resultsSection.classList.remove('active');
      
      // Make API call
      fetch('PlanRouteServlet', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({
          vehicleModel: vehicleModel,
          maxRange: maxRange,
          batteryLevel: batteryLevel,
          startLocation: startLocation,
          destination: destination
        })
      })
      .then(response => response.json())
      .then(data => {
        console.log('API Response:', data);
        
        if (data.success) {
          displayResults(data);
          resultsSection.classList.add('active');
        } else {
          resultsContainer.innerHTML = 
            '<div class="alert alert-error">❌ ' + (data.message || 'Route planning failed') + '</div>';
          resultsSection.classList.add('active');
        }
      })
      .catch(error => {
        console.error('Error:', error);
        resultsContainer.innerHTML = 
          '<div class="alert alert-error">❌ Network error. Please try again.</div>';
        resultsSection.classList.add('active');
      })
      .finally(() => {
        btn.disabled = false;
        btn.innerHTML = '<span>✨</span><span>Calculate with AI</span>';
      });
    }

    function displayResults(data) {
      const container = document.getElementById('resultsContainer');
      
      // Summary
      let html = '<div class="alert alert-success">';
      html += '✅ Route planned: ' + data.totalDistance + ' km | ';
      html += 'Estimated cost: ₹' + data.estimatedCost + ' | ';
      html += 'Confidence: ' + data.confidence;
      html += '</div>';
      
      // AI suggestion
      if (data.aiSuggestion) {
        html += '<div style="padding: 15px; background: #FFF4E6; border-radius: 12px; margin-bottom: 20px;">';
        html += '<strong>🤖 AI Suggestion:</strong> Charging recommended at: ' + data.aiSuggestion;
        html += '</div>';
      }
      
      // Stations
      if (data.stations && data.stations.length > 0) {
        data.stations.forEach((station, index) => {
          html += '<div class="station-card">';
          html += '<div class="station-icon">⚡</div>';
          html += '<div class="station-info">';
          html += '<div class="station-name">' + (index + 1) + '. ' + station.name + '</div>';
          html += '<div class="station-address">📍 ' + station.address + '</div>';
          html += '<div class="station-stats">';
          html += '<div class="stat-item">🔌 ' + station.connectorType + '</div>';
          html += '<div class="stat-item">💰 ₹' + station.price.toFixed(2) + '/kWh</div>';
          html += '<div class="stat-item">📏 ' + station.distanceFromStart + ' km from start</div>';
          html += '</div>';
          html += '</div>';
          html += '<a href="Booking.jsp?stationId=' + station.id + '" class="book-btn">Book Now</a>';
          html += '</div>';
        });
        
        // Update map
        updateMap(data.stations);
      } else {
        html += '<p>No stations found for this route.</p>';
      }
      
      container.innerHTML = html;
    }

    function updateMap(stations) {
      // Clear existing markers
      map.eachLayer(layer => {
        if (layer instanceof L.Marker) {
          map.removeLayer(layer);
        }
      });
      
      const icon = L.icon({
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/3448/3448636.png',
        iconSize: [32, 32],
        iconAnchor: [16, 32]
      });
      
      const bounds = [];
      
      stations.forEach((station, index) => {
        const marker = L.marker([station.latitude, station.longitude], {icon: icon});
        marker.bindPopup(
          '<b>' + (index + 1) + '. ' + station.name + '</b><br>' +
          station.address + '<br>' +
          '₹' + station.price.toFixed(2) + '/kWh'
        );
        marker.addTo(map);
        bounds.push([station.latitude, station.longitude]);
      });
      
      if (bounds.length > 0) {
        map.fitBounds(bounds, {padding: [50, 50]});
      }
    }
  </script>
</body>
</html>
