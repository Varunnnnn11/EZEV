<%@page import="java.util.List"%>
<%@page import="org.hibernate.query.Query"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.ezev.helper.FactoryProvider"%>
<%@page import="com.ezev.entities.Booking"%>
<%@page import="com.ezev.entities.Station"%>
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
    <title>Host Command Center - EzEv</title>
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
            --error-red: #EF4444;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--bright-snow);
            color: var(--coffee-bean);
            min-height: 100vh;
        }

        /* Background Pattern */
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
            padding: 15px 40px; background: white; border-bottom: 1px solid var(--pale-slate);
            position: sticky; top: 0; z-index: 100;
        }
        .logo { font-size: 1.4rem; font-weight: 800; color: var(--deep-navy); text-decoration: none; display: flex; align-items: center; gap: 10px; }
        .nav-link { text-decoration: none; color: var(--dusk-blue); font-weight: 600; font-size: 0.95rem; display: flex; align-items: center; gap: 8px; }
        .nav-link:hover { color: var(--deep-navy); }

        .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }

        /* Header Section */
        .page-header { margin-bottom: 30px; }
        .page-header h1 { font-size: 2.2rem; color: var(--deep-navy); margin-bottom: 5px; }
        .page-header p { color: var(--dusk-blue); }

        /* Stats Row */
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 40px; }
        .stat-card {
            background: white; padding: 25px; border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid var(--pale-slate);
            display: flex; align-items: center; justify-content: space-between;
        }
        .stat-info h3 { font-size: 2rem; margin: 0; color: var(--deep-navy); }
        .stat-info p { margin: 0; font-size: 0.9rem; color: #666; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
        .bg-orange { background: rgba(245, 158, 11, 0.1); color: var(--warning-orange); }
        .bg-green { background: rgba(16, 185, 129, 0.1); color: var(--success-green); }
        .bg-blue { background: rgba(46, 80, 119, 0.1); color: var(--dusk-blue); }

        /* Requests Grid */
        .section-title { font-size: 1.4rem; color: var(--coffee-bean); margin-bottom: 20px; border-left: 5px solid var(--warning-orange); padding-left: 15px; }
        
        .request-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(340px, 1fr)); gap: 25px; }

        .request-card {
            background: white; border-radius: 20px; overflow: hidden;
            box-shadow: 0 10px 30px rgba(0,0,0,0.05); transition: transform 0.3s ease;
            border: 1px solid transparent;
        }
        .request-card:hover { transform: translateY(-5px); border-color: var(--dusk-blue); }

        .card-header {
            background: linear-gradient(135deg, var(--dusk-blue), var(--deep-navy));
            padding: 15px 20px; color: white; display: flex; justify-content: space-between; align-items: center;
        }
        .station-name { font-weight: 700; font-size: 1rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 200px; }
        .req-date { font-size: 0.85rem; opacity: 0.9; background: rgba(255,255,255,0.2); padding: 4px 10px; border-radius: 20px; }

        .card-body { padding: 20px; }
        
        .user-row { display: flex; align-items: center; gap: 15px; margin-bottom: 15px; padding-bottom: 15px; border-bottom: 1px dashed var(--pale-slate); }
        .user-avatar { width: 45px; height: 45px; background: var(--bright-snow); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 700; color: var(--dusk-blue); font-size: 1.2rem; border: 2px solid var(--pale-slate); }
        .user-details h4 { margin: 0; font-size: 1rem; color: var(--coffee-bean); }
        .user-details p { margin: 0; font-size: 0.85rem; color: #666; }

        .info-row { display: flex; justify-content: space-between; margin-bottom: 8px; font-size: 0.9rem; }
        .info-label { color: #888; font-weight: 600; }
        .info-val { color: var(--deep-navy); font-weight: 700; }
        .price-val { color: var(--success-green); font-size: 1.1rem; }

        .card-actions { padding: 15px 20px; background: var(--bright-snow); display: flex; gap: 10px; }
        .btn { flex: 1; padding: 12px; border: none; border-radius: 10px; font-weight: 700; cursor: pointer; transition: 0.3s; font-size: 0.9rem; display: flex; align-items: center; justify-content: center; gap: 8px; text-decoration: none; }
        
        .btn-accept { background: var(--success-green); color: white; }
        .btn-accept:hover { background: #059669; box-shadow: 0 5px 15px rgba(16, 185, 129, 0.3); }
        
        .btn-decline { background: white; color: var(--error-red); border: 1px solid var(--pale-slate); }
        .btn-decline:hover { background: #FEF2F2; border-color: var(--error-red); }

        /* Empty State */
        .empty-state {
            grid-column: 1 / -1; background: white; padding: 60px; border-radius: 20px;
            text-align: center; border: 2px dashed var(--pale-slate);
        }
        .empty-icon { font-size: 4rem; color: var(--pale-slate); margin-bottom: 20px; }
        .empty-text { font-size: 1.2rem; color: var(--dusk-blue); font-weight: 600; }

        /* Alerts */
        .alert { padding: 15px; border-radius: 12px; margin-bottom: 30px; text-align: center; font-weight: 700; animation: slideIn 0.5s ease; }
        .alert-success { background: #D1FAE5; color: #065F46; border: 1px solid #A7F3D0; }
        .alert-error { background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA; }

        @keyframes slideIn { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
        
        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: 1fr; }
            .container { padding: 0 15px; }
        }
    </style>
</head>
<body>

    <div class="grid-bg"></div>

    <nav class="navbar">
        <a href="Dashboard.jsp" class="logo">
            <img src="ezev-logo.png" alt="EzEv" style="height: 40px;">
            <span>Host Panel</span>
        </a>
        <a href="Dashboard.jsp" class="nav-link">
            <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
        </a>
    </nav>

    <div class="container">
        
        <% 
            String msg = (String) session.getAttribute("message");
            if(msg != null) {
                String cssClass = msg.contains("Accepted") ? "alert-success" : "alert-error";
        %>
            <div class="alert <%= cssClass %>">
                <%= msg %>
            </div>
        <% 
                session.removeAttribute("message");
            } 
        %>

        <div class="page-header">
            <h1>Welcome, <%= user.getUserName() %>! 👋</h1>
            <p>Manage your charging stations and incoming requests here.</p>
        </div>

        <%
            Session s = FactoryProvider.getFactory().openSession();
            
            // 1. Get Pending Requests
            String hqlRequests = "SELECT b FROM Booking b WHERE b.station.ownerId = :uid AND b.status = 'Pending' ORDER BY b.bookingDate DESC";
            Query<Booking> qReq = s.createQuery(hqlRequests, Booking.class);
            qReq.setParameter("uid", user.getUserId());
            List<Booking> requests = qReq.list();

            // 2. Calculate Stats (Simple Estimates)
            int pendingCount = requests.size();
            double potentialEarnings = 0;
            for(Booking b : requests) potentialEarnings += b.getAmount();

            // 3. Get Total Hosted Stations Count
            String hqlCount = "SELECT count(*) FROM Station WHERE ownerId = :uid";
            Query qCount = s.createQuery(hqlCount);
            qCount.setParameter("uid", user.getUserId());
            Long totalStations = (Long) qCount.uniqueResult();
        %>

        <section class="stats-grid">
            <div class="stat-card">
                <div class="stat-info">
                    <h3><%= pendingCount %></h3>
                    <p>Pending Requests</p>
                </div>
                <div class="stat-icon bg-orange"><i class="fa-solid fa-bell"></i></div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3>₹<%= String.format("%.0f", potentialEarnings) %></h3>
                    <p>Potential Earnings</p>
                </div>
                <div class="stat-icon bg-green"><i class="fa-solid fa-indian-rupee-sign"></i></div>
            </div>
            <div class="stat-card">
                <div class="stat-info">
                    <h3><%= totalStations %></h3>
                    <p>Active Stations</p>
                </div>
                <div class="stat-icon bg-blue"><i class="fa-solid fa-charging-station"></i></div>
            </div>
        </section>

        <h2 class="section-title">Incoming Requests (<%= pendingCount %>)</h2>

        <div class="request-grid">
            <%
                if (requests.isEmpty()) {
            %>
                <div class="empty-state">
                    <div class="empty-icon"><i class="fa-regular fa-clipboard"></i></div>
                    <div class="empty-text">No pending requests</div>
                    <p>Relax! You will be notified when someone books your charger.</p>
                </div>
            <%
                } else {
                    for (Booking b : requests) {
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM dd");
                        String dateStr = sdf.format(b.getBookingDate());
            %>
                <div class="request-card">
                    <div class="card-header">
                        <span class="station-name"><i class="fa-solid fa-bolt"></i> <%= b.getStation().getStationName() %></span>
                        <span class="req-date"><%= dateStr %></span>
                    </div>
                    
                    <div class="card-body">
                        <div class="user-row">
                            <div class="user-avatar">
                                <%= b.getUser().getUserName().substring(0, 1).toUpperCase() %>
                            </div>
                            <div class="user-details">
                                <h4><%= b.getUser().getUserName() %></h4>
                                <p>Verified User</p>
                            </div>
                        </div>

                        <div class="info-row">
                            <span class="info-label">Vehicle</span>
                            <span class="info-val"><%= b.getVehicleModel() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Time Slot</span>
                            <span class="info-val"><%= b.getBookingTime() %></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Earnings</span>
                            <span class="info-val price-val">₹<%= String.format("%.2f", b.getAmount()) %></span>
                        </div>
                    </div>

                    <div class="card-actions">
                        <a href="HandleRequestServlet?id=<%= b.getBookingId() %>&action=decline" 
                           class="btn btn-decline"
                           onclick="return confirm('Decline request? Money will be refunded.');">
                            Decline
                        </a>
                        <a href="HandleRequestServlet?id=<%= b.getBookingId() %>&action=accept" class="btn btn-accept">
                            Accept <i class="fa-solid fa-check"></i>
                        </a>
                    </div>
                </div>
            <%
                    }
                }
                s.close();
            %>
        </div>

    </div>

</body>
</html>