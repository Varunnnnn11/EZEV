<%@page import="java.util.List"%>
<%@page import="org.hibernate.query.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.ezev.helper.FactoryProvider"%>
<%@page import="com.ezev.entities.Station"%>
<%@page import="com.ezev.entities.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // 1. SECURITY: Check if user is logged in
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
  <title>EzEv Dashboard - Smart EV Management</title>
  
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">

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

    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      background-color: var(--bright-snow);
      color: var(--coffee-bean);
      line-height: 1.6;
      overflow-x: hidden;
    }

    /* Grid Background */
    .grid-bg {
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background-image: 
        linear-gradient(var(--pale-slate) 1px, transparent 1px),
        linear-gradient(90deg, var(--pale-slate) 1px, transparent 1px);
      background-size: 30px 30px; opacity: 0.2; z-index: -1;
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

    .logo-icon {
      width: 40px; height: 40px; background: var(--bright-snow);
      border-radius: 10px; display: flex; align-items: center; justify-content: center;
      color: var(--dusk-blue); font-size: 1.5rem;
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
    .main-content { margin-left: 280px; padding: 30px; min-height: 100vh; }

    /* Header */
    .header {
      display: flex; justify-content: space-between; align-items: center; margin-bottom: 40px;
    }
    .header h1 { font-size: 2.5rem; color: var(--coffee-bean); font-weight: 800; }
    
    .header-actions { display: flex; gap: 12px; }

    .btn {
      padding: 12px 24px; border: none; border-radius: 12px;
      font-size: 0.9rem; font-weight: 600; cursor: pointer;
      transition: all 0.3s ease; display: flex; align-items: center; gap: 8px;
      text-decoration: none;
    }
    .btn-primary { background: var(--dusk-blue); color: white; }
    .btn-primary:hover { background: var(--deep-navy); transform: translateY(-2px); box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1); }
    .btn-secondary { background: var(--pale-slate); color: var(--coffee-bean); }
    .btn-secondary:hover { background: #c2c7cf; }

    /* Stats Grid */
    .stats-grid {
      display: grid; 
      grid-template-columns: repeat(3, 1fr);
      gap: 24px; 
      margin-bottom: 40px;
    }

    .stat-card {
      background: white; padding: 24px; border-radius: 20px;
      box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); transition: all 0.3s ease;
      position: relative; overflow: hidden;
    }
    .stat-card:hover { transform: translateY(-5px); box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1); }
    .stat-card::before { content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; background: var(--dusk-blue); }

    .stat-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; }
    .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
    
    .stat-icon.blue { background: rgba(46, 80, 119, 0.1); }
    .stat-icon.green { background: rgba(16, 185, 129, 0.1); }
    .stat-icon.orange { background: rgba(245, 158, 11, 0.1); }
    .stat-icon.red { background: rgba(239, 68, 68, 0.1); }

    .stat-value { font-size: 2rem; font-weight: 800; color: var(--coffee-bean); margin-bottom: 4px; }
    .stat-label { font-size: 0.85rem; color: var(--dusk-blue); margin-bottom: 8px; }
    .stat-change { font-size: 0.8rem; font-weight: 600; display: flex; align-items: center; gap: 4px; }
    .stat-change.up { color: var(--success-green); }
    .stat-change.down { color: var(--error-red); }

    /* Dashboard Grid */
    .dashboard-grid { display: grid; grid-template-columns: 1.5fr 1fr; gap: 24px; margin-bottom: 40px; }

    .card { background: white; border-radius: 20px; padding: 30px; box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05); }
    .card-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; }
    .card-title { font-size: 1.3rem; font-weight: 700; color: var(--coffee-bean); }
    .card-action { font-size: 0.85rem; color: var(--dusk-blue); text-decoration: none; font-weight: 600; transition: color 0.3s; }
    .card-action:hover { color: var(--deep-navy); }

    /* Bookings Table */
    .bookings-table { width: 100%; border-collapse: collapse; }
    .bookings-table thead { background: var(--pale-slate); }
    .bookings-table th { padding: 12px; text-align: left; font-size: 0.85rem; font-weight: 600; color: var(--coffee-bean); border-radius: 8px; }
    .bookings-table td { padding: 16px 12px; border-bottom: 1px solid var(--pale-slate); font-size: 0.9rem; }
    .bookings-table tr:hover { background: rgba(210, 215, 223, 0.1); }
    
    .status-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; }
    .status-badge.completed { background: rgba(16, 185, 129, 0.1); color: var(--success-green); }
    .status-badge.active { background: rgba(245, 158, 11, 0.1); color: var(--warning-orange); }

    /* Nearby Chargers */
    .charger-item {
      padding: 16px;
      border-bottom: 1px solid var(--pale-slate);
      transition: all 0.3s ease;
      cursor: pointer;
    }
    .charger-item:hover {
      background: rgba(210, 215, 223, 0.1);
      transform: translateX(5px);
    }
    .charger-item:last-child {
      border-bottom: none;
    }
    .charger-name {
      font-size: 1rem;
      font-weight: 600;
      color: var(--coffee-bean);
      margin-bottom: 4px;
    }
    .charger-address {
      font-size: 0.85rem;
      color: var(--dusk-blue);
      margin-bottom: 8px;
    }
    .charger-details {
      display: flex;
      gap: 16px;
      font-size: 0.8rem;
      color: var(--coffee-bean);
    }
    .charger-detail {
      display: flex;
      align-items: center;
      gap: 4px;
    }

    /* Responsive */
    @media (max-width: 1024px) {
      .sidebar { transform: translateX(-100%); }
      .main-content { margin-left: 0; }
      .stats-grid { grid-template-columns: repeat(2, 1fr); }
      .dashboard-grid { grid-template-columns: 1fr; }
    }
    @media (max-width: 640px) {
      .stats-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
  <div class="grid-bg"></div>

  <aside class="sidebar">
    <div class="logo">
      <img src="ezev-logo.png" alt="EzEv Logo" style="height: 50px; width: auto; background: white; padding: 5px; border-radius: 8px;">
      <span style="margin-left: 10px;">EzEv</span>
    </div>

    <ul class="nav-menu">
      <li class="nav-item">
        <a href="Dashboard.jsp" class="nav-link active">
          <span class="nav-icon">📊</span>
          <span>Dashboard</span>
        </a>
      </li>
      <li class="nav-item">
        <a href="FindChargers.jsp" class="nav-link">
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
      <div class="avatar"><%= user.getUserName().substring(0,1) %></div>
      <div class="user-info">
        <h4><%= user.getUserName() %></h4>
        <p>Premium Member</p>
      </div>
    </div>
  </aside>

  <main class="main-content">
    <header class="header">
      <div>
        <h1>Welcome Back, <%= user.getUserName() %>! 👋</h1>
        <p style="color: var(--dusk-blue); font-size: 1rem;">Here's what's happening with your EV today</p>
      </div>
      <div class="header-actions">
        <a href="FindChargers.jsp" class="btn btn-secondary">
          <span>📍</span>
          <span>Near You</span>
        </a>
        <a href="FindChargers.jsp" class="btn btn-primary">
          <span>+</span>
          <span>Book Charger</span>
        </a>
      </div>
    </header>

    <section class="stats-grid">
      
      <div class="stat-card">
        <div class="stat-header">
          <div>
            <div class="stat-value"><%= user.getPoints() %></div>
            <div class="stat-label">Total Points</div>
          </div>
          <div class="stat-icon blue">🎯</div>
        </div>
        <div class="stat-change up">
          <span>↑</span> <span>Earned today</span>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-header">
          <div>
            <div class="stat-value">24</div>
            <div class="stat-label">Charging Sessions</div>
          </div>
          <div class="stat-icon green">⚡</div>
        </div>
        <div class="stat-change up">
          <span>↑</span> <span>+8 this month</span>
        </div>
      </div>

      <div class="stat-card">
        <div class="stat-header">
          <div>
            <div class="stat-value">₹<%= user.getWalletBalance() == null ? "0.0" : user.getWalletBalance() %></div>
            <div class="stat-label">Wallet Balance</div>
          </div>
          <div class="stat-icon orange">💰</div>
        </div>
        <div class="stat-change up">
          <span>+</span> <span>Ready to use</span>
        </div>
      </div>
      
    </section>

    <section class="dashboard-grid">
      
      <div class="card">
        <div class="card-header">
          <h2 class="card-title">Recent Bookings</h2>
          <a href="#" class="card-action">View All →</a>
        </div>
        <table class="bookings-table">
          <thead>
            <tr>
              <th>Station</th>
              <th>Date</th>
              <th>Amount</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            <%
                Session bookingSession = null;
                try {
                    bookingSession = FactoryProvider.getFactory().openSession();
                    // Get bookings for current user, ordered by date (latest first)
                    Query<com.ezev.entities.Booking> bookingQuery = bookingSession.createQuery(
                        "FROM Booking b WHERE b.user.userId = :userId ORDER BY b.bookingDate DESC", 
                        com.ezev.entities.Booking.class
                    );
                    bookingQuery.setParameter("userId", user.getUserId());
                    bookingQuery.setMaxResults(5); // Show only last 5 bookings
                    
                    List<com.ezev.entities.Booking> bookings = bookingQuery.list();
                    
                    if (bookings.isEmpty()) {
            %>
                        <tr>
                            <td colspan="4" style="text-align: center; padding: 30px; color: #888;">
                                No bookings yet. Book your first charging slot! 🚗⚡
                            </td>
                        </tr>
            <%
                    } else {
                        java.text.SimpleDateFormat dateFormat = new java.text.SimpleDateFormat("MMM dd, yyyy");
                        for (com.ezev.entities.Booking booking : bookings) {
                            String statusClass = booking.getStatus().equalsIgnoreCase("Confirmed") ? "completed" : "active";
                            String formattedDate = dateFormat.format(booking.getBookingDate());
            %>
                        <tr>
                            <td><strong><%= booking.getStation().getStationName() %></strong></td>
                            <td><%= formattedDate %></td>
                            <td>₹<%= String.format("%.2f", booking.getAmount()) %></td>
                            <td><span class="status-badge <%= statusClass %>"><%= booking.getStatus() %></span></td>
                        </tr>
            <%
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
            %>
                    <tr>
                        <td colspan="4" style="text-align: center; padding: 30px; color: #EF4444;">
                            Error loading bookings: <%= e.getMessage() %>
                        </td>
                    </tr>
            <%
                } finally {
                    if (bookingSession != null && bookingSession.isOpen()) {
                        bookingSession.close();
                    }
                }
            %>
          </tbody>
        </table>
      </div>

      <div class="card">
        <div class="card-header">
          <h2 class="card-title">Nearby Chargers</h2>
          <a href="FindChargers.jsp" class="card-action">View on Map →</a>
        </div>
        <div>
          <%
              Session nearbySession = null;
              try {
                  nearbySession = FactoryProvider.getFactory().openSession();
                  Query<Station> nearbyQuery = nearbySession.createQuery(
                      "FROM Station WHERE status = 'Active' ORDER BY stationId DESC", 
                      Station.class
                  );
                  nearbyQuery.setMaxResults(5);
                  
                  List<Station> nearbyStations = nearbyQuery.list();
                  
                  if (nearbyStations.isEmpty()) {
          %>
                      <div style="text-align: center; padding: 40px; color: #888;">
                          No stations found nearby
                      </div>
          <%
                  } else {
                      for (Station station : nearbyStations) {
                          String safeName = station.getStationName() != null ? station.getStationName() : "Charging Station";
                          String safeAddr = station.getStationAddress() != null ? station.getStationAddress() : "Address not available";
                          String safeType = station.getConnectorType() != null ? station.getConnectorType() : "Type 2";
          %>
                      <div class="charger-item" onclick="window.location.href='FindChargers.jsp'">
                          <div class="charger-name">⚡ <%= safeName %></div>
                          <div class="charger-address">📍 <%= safeAddr %></div>
                          <div class="charger-details">
                              <span class="charger-detail">
                                  <span>🔌</span>
                                  <span><%= safeType %></span>
                              </span>
                              <span class="charger-detail">
                                  <span>💰</span>
                                  <span>₹<%= String.format("%.2f", station.getPricePerUnit()) %>/kWh</span>
                              </span>
                              <span class="charger-detail">
                                  <span>✅</span>
                                  <span>Available</span>
                              </span>
                          </div>
                      </div>
          <%
                      }
                  }
              } catch (Exception e) {
                  e.printStackTrace();
          %>
                  <div style="text-align: center; padding: 40px; color: #EF4444;">
                      Error loading nearby stations
                  </div>
          <%
              } finally {
                  if (nearbySession != null && nearbySession.isOpen()) {
                      nearbySession.close();
                  }
              }
          %>
        </div>
      </div>
      
    </section>

    <section class="card">
      <div class="card-header">
        <h2 class="card-title">Quick Actions</h2>
      </div>
      <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px;">
          <div class="stat-card" style="text-align: center; cursor: pointer;" onclick="window.location.href='#'">
            <div style="font-size: 2rem;">🗺️</div>
            <h3>Plan Trip</h3>
          </div>
          <div class="stat-card" style="text-align: center; cursor: pointer;" onclick="window.location.href='FindChargers.jsp'">
            <div style="font-size: 2rem;">🔍</div>
            <h3>Find Charger</h3>
          </div>
          <div class="stat-card" style="text-align: center; cursor: pointer;" onclick="window.location.href='#'">
            <div style="font-size: 2rem;">🎁</div>
            <h3>Rewards</h3>
          </div>
      </div>
    </section>

  </main>

  <script>
    // Smooth hover effects for UI
    document.querySelectorAll('.stat-card').forEach(item => {
      item.addEventListener('mouseenter', function() { this.style.transform = 'translateY(-5px)'; });
      item.addEventListener('mouseleave', function() { this.style.transform = 'translateY(0)'; });
    });
  </script>
</body>
</html>
