<%@page import="java.util.List"%>
<%@page import="org.hibernate.query.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.ezev.helper.FactoryProvider"%>
<%@page import="com.ezev.entities.Station"%>
<%@page import="com.ezev.entities.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Check if user is logged in
    User user = (User) session.getAttribute("currentUser");
    
    if (user == null) {
        session.setAttribute("message", "Please login first!");
        response.sendRedirect("Login.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Find Chargers - EzEv</title>
  
  <!-- Leaflet CSS -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
  <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css" />
  
  <style>
    :root {
      --bright-snow: #FAFAFA;
      --pale-slate: #D2D7DF;
      --dusk-blue: #2E5077;
      --deep-navy: #00003D;
      --coffee-bean: #14010B;
      --success-green: #10B981;
      --warning-orange: #F59E0B;
      --error-red: #EF4444;
    }

    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      background-color: var(--bright-snow);
      color: var(--coffee-bean);
      line-height: 1.6;
      overflow-x: hidden;
    }

    /* Grid Background */
    .grid-bg {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background-image: 
        linear-gradient(var(--pale-slate) 1px, transparent 1px),
        linear-gradient(90deg, var(--pale-slate) 1px, transparent 1px);
      background-size: 30px 30px;
      opacity: 0.2;
      z-index: -1;
    }

    /* Sidebar */
    .sidebar {
      position: fixed; left: 0; top: 0; width: 280px; height: 100vh;
      background: linear-gradient(180deg, var(--deep-navy) 0%, var(--dusk-blue) 100%);
      padding: 30px 20px; color: white; z-index: 100; overflow-y: auto;
    }

    .logo {
      font-size: 1.8rem; font-weight: 800; margin-bottom: 40px;
      color: var(--bright-snow); display: flex; align-items: center; gap: 10px;
    }

    .nav-menu { list-style: none; }
    .nav-item { margin-bottom: 8px; }

    .nav-link {
      display: flex; align-items: center; gap: 12px; padding: 12px 16px;
      color: rgba(255, 255, 255, 0.7); text-decoration: none; border-radius: 12px;
      transition: all 0.3s ease; font-size: 0.95rem;
    }

    .nav-link:hover, .nav-link.active {
      background: rgba(255, 255, 255, 0.1); color: white; transform: translateX(5px);
    }
    .nav-link.active { background: rgba(255, 255, 255, 0.15); }

    .user-profile {
      margin-top: 40px; padding: 16px; background: rgba(255, 255, 255, 0.1);
      border-radius: 12px; display: flex; align-items: center; gap: 12px;
    }

    .avatar {
      width: 45px; height: 45px; border-radius: 50%; background: var(--bright-snow);
      display: flex; align-items: center; justify-content: center;
      color: var(--dusk-blue); font-weight: 700; font-size: 1.1rem;
    }

    .user-info h4 { font-size: 0.9rem; margin-bottom: 2px; }
    .user-info p { font-size: 0.75rem; color: rgba(255, 255, 255, 0.6); }

    /* Main Content */
    .main-content {
      margin-left: 280px;
      padding: 30px;
      min-height: 100vh;
    }

    /* Page Header */
    .page-header {
      margin-bottom: 30px;
    }

    .page-header h1 {
      font-size: 2.5rem;
      color: var(--coffee-bean);
      margin-bottom: 8px;
      font-weight: 800;
    }

    .page-header p {
      font-size: 1.1rem;
      color: var(--dusk-blue);
    }

    /* Search Section */
    .search-section {
      background: white;
      padding: 24px;
      border-radius: 20px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
      margin-bottom: 24px;
    }

    .search-bar {
      display: flex;
      gap: 12px;
      margin-bottom: 16px;
    }

    .search-input-wrapper {
      flex: 1;
      position: relative;
    }

    .search-icon {
      position: absolute;
      left: 16px;
      top: 50%;
      transform: translateY(-50%);
      font-size: 1.2rem;
    }

    .search-input {
      width: 100%;
      padding: 14px 14px 14px 48px;
      border: 2px solid var(--pale-slate);
      border-radius: 12px;
      font-size: 0.95rem;
      transition: all 0.3s;
      background: var(--bright-snow);
    }

    .search-input:focus {
      outline: none;
      border-color: var(--dusk-blue);
      background: white;
    }

    .search-btn {
      padding: 14px 36px;
      background: linear-gradient(135deg, var(--dusk-blue), var(--deep-navy));
      color: white;
      border: none;
      border-radius: 12px;
      font-size: 0.95rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
    }

    .search-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 20px rgba(46, 80, 119, 0.3);
    }

    .quick-filters {
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
    }

    .quick-filter {
      padding: 6px 18px;
      background: var(--bright-snow);
      border: 2px solid var(--pale-slate);
      border-radius: 20px;
      font-size: 0.85rem;
      color: var(--coffee-bean);
      cursor: pointer;
      transition: all 0.3s;
    }

    .quick-filter:hover,
    .quick-filter.active {
      background: var(--dusk-blue);
      color: white;
      border-color: var(--dusk-blue);
    }

    /* View Toggle */
    .view-toggle {
      display: flex;
      gap: 12px;
      margin-bottom: 24px;
      background: white;
      padding: 8px;
      border-radius: 12px;
      width: fit-content;
      box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    }

    .view-btn {
      padding: 10px 24px;
      background: transparent;
      border: none;
      border-radius: 8px;
      font-size: 0.9rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
      color: var(--coffee-bean);
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .view-btn.active {
      background: var(--dusk-blue);
      color: white;
    }

    /* Map Container */
    .map-container {
      background: white;
      border-radius: 20px;
      padding: 20px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
      display: none;
    }

    .map-container.active {
      display: block;
    }

    #map {
      width: 100%;
      height: 600px;
      border-radius: 12px;
      border: 2px solid var(--pale-slate);
    }

    /* List Container */
    .list-container {
      display: none;
    }

    .list-container.active {
      display: block;
    }

    /* Station Cards */
    .stations-grid {
      display: grid;
      gap: 20px;
    }

    .station-card {
      background: white;
      border-radius: 16px;
      padding: 24px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
      transition: all 0.3s ease;
      display: grid;
      grid-template-columns: auto 1fr auto;
      gap: 20px;
      align-items: center;
      border: 2px solid transparent;
    }

    .station-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 12px 30px rgba(0, 0, 0, 0.12);
      border-color: var(--dusk-blue);
    }

    .station-icon {
      width: 70px;
      height: 70px;
      background: linear-gradient(135deg, var(--dusk-blue), var(--deep-navy));
      border-radius: 14px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 2rem;
      flex-shrink: 0;
    }

    .station-info {
      flex: 1;
    }

    .station-name {
      font-size: 1.3rem;
      font-weight: 700;
      color: var(--coffee-bean);
      margin-bottom: 8px;
    }

    .station-address {
      font-size: 0.9rem;
      color: var(--dusk-blue);
      margin-bottom: 12px;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .station-details {
      display: flex;
      gap: 20px;
      flex-wrap: wrap;
    }

    .station-detail-item {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 0.85rem;
      color: var(--coffee-bean);
      background: var(--bright-snow);
      padding: 6px 12px;
      border-radius: 8px;
    }

    .station-actions {
      display: flex;
      flex-direction: column;
      gap: 10px;
      align-items: flex-end;
    }

    .distance-badge {
      background: rgba(16, 185, 129, 0.1);
      color: var(--success-green);
      padding: 6px 14px;
      border-radius: 18px;
      font-size: 0.85rem;
      font-weight: 600;
      white-space: nowrap;
    }

    .availability-badge {
      padding: 6px 14px;
      border-radius: 18px;
      font-size: 0.8rem;
      font-weight: 600;
    }

    .availability-badge.available {
      background: rgba(16, 185, 129, 0.1);
      color: var(--success-green);
    }

    .btn {
      padding: 10px 24px;
      border: none;
      border-radius: 10px;
      font-size: 0.9rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
      text-decoration: none;
      display: inline-block;
      text-align: center;
    }

    .btn-primary {
      background: var(--dusk-blue);
      color: white;
    }

    .btn-primary:hover {
      background: var(--deep-navy);
      transform: translateY(-2px);
      box-shadow: 0 6px 15px rgba(46, 80, 119, 0.3);
    }

    .btn-secondary {
      background: var(--pale-slate);
      color: var(--coffee-bean);
    }

    .btn-secondary:hover {
      background: #c2c7cf;
    }

    /* Empty State */
    .empty-state {
      text-align: center;
      padding: 60px 20px;
      background: white;
      border-radius: 20px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
    }

    .empty-state-icon {
      font-size: 4rem;
      margin-bottom: 20px;
    }

    .empty-state h3 {
      font-size: 1.5rem;
      color: var(--coffee-bean);
      margin-bottom: 10px;
    }

    .empty-state p {
      color: var(--dusk-blue);
      font-size: 1rem;
    }

    /* Marker Cluster Styling */
    .marker-cluster-small {
      background-color: rgba(46, 80, 119, 0.6);
    }
    .marker-cluster-small div {
      background-color: rgba(46, 80, 119, 0.8);
    }

    /* Responsive */
    @media (max-width: 1024px) {
      .sidebar { transform: translateX(-100%); }
      .main-content { margin-left: 0; }
    }

    @media (max-width: 768px) {
      .page-header h1 { font-size: 1.8rem; }
      .search-bar { flex-direction: column; }
      .search-btn { width: 100%; }
      #map { height: 400px; }
      .station-card {
        grid-template-columns: 1fr;
        text-align: center;
      }
      .station-icon {
        margin: 0 auto;
      }
      .station-actions {
        align-items: center;
        flex-direction: row;
        justify-content: center;
      }
    }
  </style>
</head>
<body>
  <div class="grid-bg"></div>

  <!-- Sidebar -->
  <aside class="sidebar">
    <div class="logo">
      <img src="ezev-logo.png" alt="EzEv Logo" style="height: 50px; width: auto; background: white; padding: 5px; border-radius: 8px;">
      <span style="margin-left: 10px;">EzEv</span>
    </div>

    <ul class="nav-menu">
      <li class="nav-item">
        <a href="Dashboard.jsp" class="nav-link">
          <span class="nav-icon">📊</span>
          <span>Dashboard</span>
        </a>
      </li>
      <li class="nav-item">
        <a href="FindChargers.jsp" class="nav-link active">
          <span class="nav-icon">🔌</span>
          <span>Find Chargers</span>
        </a>
      </li>
      <li class="nav-item">
        <a href="PlanRoute.jsp" class="nav-link">
          <span class="nav-icon">🗺️</span>
          <span>Plan Route</span>
        </a>
      </li>
        <li class="nav-item">
          <a href="AddCharger.jsp" class="nav-link" >⚡</span>
          <span>Host a Charger</span>
        </a>
      </li>
      
      <li class="nav-item">
        <a href="OwnerDashboard.jsp" class="nav-link">
          <span class="nav-icon">🔔</span>
          <span>Requests</span>
        </a>
      </li>
      <li class="nav-item">
        <a href="LogoutServlet" class="nav-link" onclick="return confirm('Are you sure you want to logout?');">
          <span class="nav-icon">⬅️</span>
          <span>Logout</span>
        </a>
      </li>
    </ul>

    <div class="user-profile">
      <div class="avatar"><%= user.getUserName().substring(0,1).toUpperCase() %></div>
      <div class="user-info">
        <h4><%= user.getUserName() %></h4>
        <p>Premium Member</p>
      </div>
    </div>
  </aside>

  <!-- Main Content -->
  <main class="main-content">
    <!-- Page Header -->
    <div class="page-header">
      <h1>Find Charging Stations 🔍</h1>
      <p>Discover nearby EV chargers within 10km radius</p>
    </div>

    <!-- Search Section -->
    <div class="search-section">
      <div class="search-bar">
        <div class="search-input-wrapper">
          <span class="search-icon">🔍</span>
          <input 
            type="text" 
            class="search-input" 
            id="searchInput"
            placeholder="Search by station name, location, or address..."
          >
        </div>
        <button class="search-btn" onclick="searchStations()">Search</button>
      </div>

      <div class="quick-filters">
        <span class="quick-filter active" data-filter="all" onclick="filterStations('all', this)">All Stations</span>
        <span class="quick-filter" data-filter="available" onclick="filterStations('available', this)">Available Now</span>
        <span class="quick-filter" data-filter="type2" onclick="filterStations('type2', this)">Type 2</span>
        <span class="quick-filter" data-filter="ccs" onclick="filterStations('ccs', this)">CCS/CHAdeMO</span>
        <span class="quick-filter" data-filter="10km" onclick="filterStations('10km', this)">Within 10km</span>
      </div>
    </div>

    <!-- View Toggle -->
    <div class="view-toggle">
      <button class="view-btn active" onclick="showMapView()" id="mapViewBtn">
        <span>🗺️</span>
        <span>Map View</span>
      </button>
      <button class="view-btn" onclick="showListView()" id="listViewBtn">
        <span>📋</span>
        <span>List View</span>
      </button>
    </div>

    <!-- Map Container -->
    <div class="map-container active" id="mapContainer">
      <div id="map"></div>
    </div>

    <!-- List Container -->
    <div class="list-container" id="listContainer">
      <div class="stations-grid" id="stationsGrid">
        <!-- Stations will be loaded here dynamically -->
      </div>
    </div>

  </main>

  <!-- Leaflet JS -->
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <script src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"></script>
  
 <script>
    let map;
    let markers;
    let allMarkers = [];
    let userLocation = null;
    
    // 1. CLEAN DATA INJECTION
    const stationsData = [
    <%
      Session s = null;
      try {
        s = FactoryProvider.getFactory().openSession();
        Query<Station> q = s.createQuery("FROM Station WHERE status = :status", Station.class);
        q.setParameter("status", "Active");
        List<Station> list = q.getResultList();
        
        System.out.println("===== LOADING STATIONS =====");
        System.out.println("Found " + list.size() + " active stations");
        
        for(int i = 0; i < list.size(); i++) {
            Station st = list.get(i);
            
            // Skip invalid coordinates
            if(st.getLatitude() == 0.0 && st.getLongitude() == 0.0) {
                System.out.println("Skipping station with invalid coordinates: " + st.getStationName());
                continue;
            }
            
            // Safe escaping
            String name = st.getStationName() != null ? 
                st.getStationName().replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").trim() : "Station";
            String provider = st.getProviderName() != null ? 
                st.getProviderName().replace("\\", "\\\\").replace("'", "\\'").trim() : "Provider";
            String type = st.getConnectorType() != null ? 
                st.getConnectorType().replace("'", "\\'") : "Type 2";
            String address = st.getStationAddress() != null ? 
                st.getStationAddress().replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"").replace("\n", " ").trim() : "Address not available";
            double price = st.getPricePerUnit();
            
            System.out.println("Station " + (i+1) + ": " + name + " | Lat: " + st.getLatitude() + " | Lng: " + st.getLongitude());
    %>
        {
            id: <%= st.getStationId() %>,
            name: '<%= name %>',
            provider: '<%= provider %>',
            type: '<%= type %>',
            address: '<%= address %>',
            lat: <%= st.getLatitude() %>,
            lng: <%= st.getLongitude() %>,
            price: <%= price %>,
            distance: null
        }<%= (i < list.size() - 1) ? "," : "" %>
    <%
        }
        
        System.out.println("===== STATIONS LOADED SUCCESSFULLY =====");
        
      } catch (Exception e) {
         System.err.println("ERROR loading stations: " + e.getMessage());
         e.printStackTrace();
      } finally {
        if(s != null && s.isOpen()) {
          s.close();
        }
      }
    %>
    ];

    console.log('=== STATIONS DATA ===');
    console.log('Total stations loaded:', stationsData.length);
    if(stationsData.length > 0) {
        console.log('First station:', stationsData[0]);
    } else {
        console.error('NO STATIONS LOADED FROM DATABASE!');
    }

    // Initialize Map
    window.addEventListener('load', function() {
      try {
        map = L.map('map').setView([20.5937, 78.9629], 5);
        
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '© EzEv | © OpenStreetMap',
          maxZoom: 19
        }).addTo(map);

        markers = L.markerClusterGroup({
          maxClusterRadius: 50,
          spiderfyOnMaxZoom: true
        });

        const stationIcon = L.icon({
          iconUrl: 'https://cdn-icons-png.flaticon.com/512/3448/3448636.png',
          iconSize: [38, 38],
          iconAnchor: [19, 38],
          popupAnchor: [0, -38]
        });

        const userIcon = L.icon({
          iconUrl: 'https://cdn-icons-png.flaticon.com/512/149/149071.png',
          iconSize: [40, 40],
          iconAnchor: [20, 40],
          popupAnchor: [0, -40]
        });

        // Add markers
        stationsData.forEach(function(station) {
            if (station.lat && station.lng) {
                var marker = L.marker([station.lat, station.lng], {icon: stationIcon});
                
                var popupContent = 
                    '<div style="min-width: 250px; font-family: Arial, sans-serif;">' +
                    '<h3 style="margin: 0 0 10px 0; color: #2E5077;">⚡ ' + station.name + '</h3>' +
                    '<p style="margin: 5px 0;"><b>🏢 Provider:</b> ' + station.provider + '</p>' +
                    '<p style="margin: 5px 0;"><b>🔌 Type:</b> ' + station.type + '</p>' +
                    '<p style="margin: 5px 0;"><b>💰 Price:</b> ₹' + station.price.toFixed(2) + '/kWh</p>' +
                    '<p style="margin: 5px 0; font-size: 0.85rem;">📍 ' + station.address + '</p>' +
                    '<a href="Booking.jsp?stationId=' + station.id + '" ' +
                    'style="display: block; margin-top: 12px; padding: 10px; text-align: center; background: #2E5077; color: white; text-decoration: none; border-radius: 8px;">' +
                    '📅 Book Charging Slot</a>' +
                    '</div>';
                
                marker.bindPopup(popupContent);
                marker.stationData = station;
                markers.addLayer(marker);
                allMarkers.push(marker);
            }
        });

        map.addLayer(markers);
        console.log('Added ' + allMarkers.length + ' markers to map');
        
        // Initial render of list view
        renderListView(stationsData);

        // Get User Location
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(
            function(pos) {
              userLocation = { 
                lat: pos.coords.latitude, 
                lng: pos.coords.longitude 
              };
              
              console.log('User location:', userLocation);
              
              stationsData.forEach(function(st) {
                st.distance = calculateDistance(
                  userLocation.lat, 
                  userLocation.lng, 
                  st.lat, 
                  st.lng
                );
              });
              
              stationsData.sort(function(a, b) { return a.distance - b.distance; });
              renderListView(stationsData);
              
              L.marker([userLocation.lat, userLocation.lng], {icon: userIcon})
                .addTo(map)
                .bindPopup("<b>📍 You are here</b>")
                .openPopup();
              
              map.setView([userLocation.lat, userLocation.lng], 12);
            },
            function(error) {
              console.log('Geolocation error:', error.message);
            }
          );
        }

      } catch (err) {
        console.error("Map error:", err);
      }
    });

    function calculateDistance(lat1, lon1, lat2, lon2) {
      var R = 6371;
      var dLat = (lat2 - lat1) * Math.PI / 180;
      var dLon = (lon2 - lon1) * Math.PI / 180;
      var a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLon/2) * Math.sin(dLon/2);
      return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    }

    function showMapView() {
      document.getElementById('mapContainer').classList.add('active');
      document.getElementById('listContainer').classList.remove('active');
      document.getElementById('mapViewBtn').classList.add('active');
      document.getElementById('listViewBtn').classList.remove('active');
      setTimeout(function() { map.invalidateSize(); }, 100);
    }

    function showListView() {
      document.getElementById('mapContainer').classList.remove('active');
      document.getElementById('listContainer').classList.add('active');
      document.getElementById('mapViewBtn').classList.remove('active');
      document.getElementById('listViewBtn').classList.add('active');
    }

    function renderListView(data) {
        var grid = document.getElementById('stationsGrid');
        
        console.log('Rendering list view with', data.length, 'stations');
        
        if(!data || data.length === 0) {
            grid.innerHTML = 
                '<div class="empty-state">' +
                '<div class="empty-state-icon">🔍</div>' +
                '<h3>No stations found</h3>' +
                '<p>Try adjusting your search or filters</p>' +
                '</div>';
            return;
        }
        
        var html = '';
        data.forEach(function(st) {
            var distanceBadge = '';
            if (st.distance !== null && st.distance !== undefined) {
                distanceBadge = '<span class="distance-badge">📍 ' + st.distance.toFixed(1) + ' km away</span>';
            }
            
            html += 
                '<div class="station-card">' +
                '<div class="station-icon">⚡</div>' +
                '<div class="station-info">' +
                '<h3 class="station-name">' + st.name + '</h3>' +
                '<div class="station-address">📍 ' + st.address + '</div>' +
                '<div class="station-details">' +
                '<span class="station-detail-item">🏢 ' + st.provider + '</span>' +
                '<span class="station-detail-item">🔌 ' + st.type + '</span>' +
                '<span class="station-detail-item">💰 ₹' + st.price.toFixed(2) + '/kWh</span>' +
                '</div>' +
                '</div>' +
                '<div class="station-actions">' +
                distanceBadge +
                '<span class="availability-badge available">✅ Available</span>' +
                '<a href="Booking.jsp?stationId=' + st.id + '" class="btn btn-primary">Book Now</a>' +
                '</div>' +
                '</div>';
        });
        
        grid.innerHTML = html;
        console.log('List view rendered successfully');
    }
    
    function searchStations() {
        var val = document.getElementById('searchInput').value.toLowerCase().trim();
        
        if(!val) {
            renderListView(stationsData);
            markers.clearLayers();
            allMarkers.forEach(function(m) { markers.addLayer(m); });
            return;
        }
        
        var filtered = stationsData.filter(function(s) {
            return s.name.toLowerCase().includes(val) || 
                   s.address.toLowerCase().includes(val) ||
                   s.provider.toLowerCase().includes(val);
        });
        
        console.log('Search results:', filtered.length);
        renderListView(filtered);
        
        markers.clearLayers();
        allMarkers.forEach(function(m) {
            var found = filtered.find(function(f) { return f.id === m.stationData.id; });
            if(found) markers.addLayer(m);
        });
        
        if(filtered.length > 0 && markers.getBounds().isValid()) {
            map.fitBounds(markers.getBounds(), {padding: [50, 50]});
        }
    }
    
    function filterStations(filterType, element) {
        document.querySelectorAll('.quick-filter').forEach(function(f) { 
            f.classList.remove('active'); 
        });
        element.classList.add('active');

        var filtered = stationsData;

        if (filterType === 'type2') {
            filtered = stationsData.filter(function(s) { 
                return s.type.toLowerCase().includes('type 2'); 
            });
        } else if (filterType === 'ccs') {
            filtered = stationsData.filter(function(s) {
                return s.type.toLowerCase().includes('ccs') || 
                       s.type.toLowerCase().includes('chademo');
            });
        } else if (filterType === '10km') {
            if (!userLocation) {
                alert('Please allow location access to use distance filter');
                return;
            }
            filtered = stationsData.filter(function(s) { 
                return s.distance !== null && s.distance <= 10; 
            });
        }

        console.log('Filter "' + filterType + '":', filtered.length, 'stations');
        renderListView(filtered);

        markers.clearLayers();
        allMarkers.forEach(function(m) {
            var found = filtered.find(function(f) { return f.id === m.stationData.id; });
            if(found) markers.addLayer(m);
        });
        
        if(filtered.length > 0 && markers.getBounds().isValid()) {
            map.fitBounds(markers.getBounds(), {padding: [50, 50]});
        }
    }
    
    var searchInput = document.getElementById('searchInput');
    if(searchInput) {
        searchInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchStations();
            }
        });
    }
</script>
</body>
</html>