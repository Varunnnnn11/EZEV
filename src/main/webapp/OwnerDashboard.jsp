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

        .grid-bg {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background-image:
                    linear-gradient(var(--pale-slate) 1px, transparent 1px),
                    linear-gradient(90deg, var(--pale-slate) 1px, transparent 1px);
            background-size: 30px 30px; opacity: 0.2; z-index: -1;
        }

        .navbar {
            display: flex; justify-content: space-between; align-items: center;
            padding: 15px 40px; background: white; border-bottom: 1px solid var(--pale-slate);
            position: sticky; top: 0; z-index: 100;
        }
        .logo { font-size: 1.4rem; font-weight: 800; color: var(--deep-navy); text-decoration: none; display: flex; align-items: center; gap: 10px; }
        .nav-link { text-decoration: none; color: var(--dusk-blue); font-weight: 600; font-size: 0.95rem; display: flex; align-items: center; gap: 8px; }
        .nav-link:hover { color: var(--deep-navy); }

        .container { max-width: 1100px; margin: 40px auto; padding: 0 20px; }

        .page-header { margin-bottom: 30px; }
        .page-header h1 { font-size: 2.2rem; color: var(--deep-navy); margin-bottom: 5px; }
        .page-header p { color: var(--dusk-blue); }

        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-bottom: 40px; }
        .stat-card {
            background: white; padding: 25px; border-radius: 16px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid var(--pale-slate);
            display: flex; align-items: center; justify-content: space-between;
        }
        .stat-card.clickable {
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
            position: relative;
        }
        .stat-card.clickable:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 30px rgba(46, 80, 119, 0.15);
            border-color: var(--dusk-blue);
        }
        .stat-card.clickable::after {
            content: 'View Details →';
            position: absolute;
            bottom: 8px;
            right: 14px;
            font-size: 0.72rem;
            font-weight: 700;
            color: var(--dusk-blue);
            opacity: 0;
            transition: opacity 0.2s ease;
            letter-spacing: 0.3px;
        }
        .stat-card.clickable:hover::after { opacity: 1; }

        .stat-info h3 { font-size: 2rem; margin: 0; color: var(--deep-navy); }
        .stat-info p { margin: 0; font-size: 0.9rem; color: #666; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; }
        .bg-orange { background: rgba(245, 158, 11, 0.1); color: var(--warning-orange); }
        .bg-green { background: rgba(16, 185, 129, 0.1); color: var(--success-green); }
        .bg-blue { background: rgba(46, 80, 119, 0.1); color: var(--dusk-blue); }

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

        .empty-state {
            grid-column: 1 / -1; background: white; padding: 60px; border-radius: 20px;
            text-align: center; border: 2px dashed var(--pale-slate);
        }
        .empty-icon { font-size: 4rem; color: var(--pale-slate); margin-bottom: 20px; }
        .empty-text { font-size: 1.2rem; color: var(--dusk-blue); font-weight: 600; }

        .alert { padding: 15px; border-radius: 12px; margin-bottom: 30px; text-align: center; font-weight: 700; animation: slideIn 0.5s ease; }
        .alert-success { background: #D1FAE5; color: #065F46; border: 1px solid #A7F3D0; }
        .alert-error { background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA; }

        @keyframes slideIn { from { transform: translateY(-20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

        /* ===================== MODAL STYLES ===================== */
        .modal-overlay {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0, 0, 61, 0.5);
            backdrop-filter: blur(4px);
            z-index: 999;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .modal-overlay.active { display: flex; animation: fadeIn 0.25s ease; }

        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        .modal {
            background: white;
            border-radius: 24px;
            width: 100%;
            max-width: 720px;
            max-height: 85vh;
            overflow: hidden;
            display: flex;
            flex-direction: column;
            box-shadow: 0 25px 60px rgba(0,0,61,0.25);
            animation: slideUp 0.3s ease;
        }
        @keyframes slideUp { from { transform: translateY(30px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

        .modal-header {
            background: linear-gradient(135deg, var(--dusk-blue), var(--deep-navy));
            padding: 24px 28px;
            color: white;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-shrink: 0;
        }
        .modal-header h2 { font-size: 1.3rem; font-weight: 800; display: flex; align-items: center; gap: 10px; }
        .modal-close {
            background: rgba(255,255,255,0.2); border: none; color: white;
            width: 36px; height: 36px; border-radius: 50%; cursor: pointer;
            font-size: 1rem; display: flex; align-items: center; justify-content: center;
            transition: background 0.2s;
        }
        .modal-close:hover { background: rgba(255,255,255,0.35); }

        .modal-body {
            overflow-y: auto;
            padding: 24px 28px;
            flex: 1;
        }

        .station-list { display: flex; flex-direction: column; gap: 16px; }

        .station-item {
            border: 1px solid var(--pale-slate);
            border-radius: 16px;
            overflow: hidden;
            transition: box-shadow 0.2s;
        }
        .station-item:hover { box-shadow: 0 6px 20px rgba(0,0,61,0.08); }

        .station-item-header {
            background: linear-gradient(90deg, rgba(46,80,119,0.07), rgba(0,0,61,0.04));
            padding: 14px 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid var(--pale-slate);
        }
        .station-item-name {
            font-weight: 800;
            font-size: 1rem;
            color: var(--deep-navy);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .station-item-name i { color: var(--dusk-blue); }

        .badge {
            font-size: 0.75rem;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 20px;
            letter-spacing: 0.4px;
        }
        .badge-active { background: #D1FAE5; color: #065F46; }
        .badge-inactive { background: #FEE2E2; color: #991B1B; }

        .station-item-body {
            padding: 16px 18px;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px 20px;
        }

        .detail-cell { display: flex; flex-direction: column; gap: 2px; }
        .detail-cell .d-label { font-size: 0.78rem; font-weight: 600; color: #999; text-transform: uppercase; letter-spacing: 0.5px; }
        .detail-cell .d-val { font-size: 0.95rem; font-weight: 700; color: var(--coffee-bean); }
        .detail-cell .d-val.green { color: var(--success-green); }
        .detail-cell .d-val.orange { color: var(--warning-orange); }

        .station-item-footer {
            background: var(--bright-snow);
            padding: 10px 18px;
            border-top: 1px solid var(--pale-slate);
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 0.83rem;
            color: #777;
        }
        .station-item-footer i { color: var(--dusk-blue); }

        .modal-empty {
            text-align: center;
            padding: 50px 20px;
        }
        .modal-empty .empty-icon { font-size: 3rem; color: var(--pale-slate); margin-bottom: 15px; }
        .modal-empty p { color: var(--dusk-blue); font-weight: 600; }

        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: 1fr; }
            .container { padding: 0 15px; }
            .station-item-body { grid-template-columns: 1fr; }
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

        String hqlRequests = "SELECT b FROM Booking b WHERE b.station.ownerId = :uid AND b.status = 'Pending' ORDER BY b.bookingDate DESC";
        Query<Booking> qReq = s.createQuery(hqlRequests, Booking.class);
        qReq.setParameter("uid", user.getUserId());
        List<Booking> requests = qReq.list();

        int pendingCount = requests.size();
        double potentialEarnings = 0;
        for(Booking b : requests) potentialEarnings += b.getAmount();

        String hqlStations = "FROM Station WHERE ownerId = :uid";
        Query<Station> qSt = s.createQuery(hqlStations, Station.class);
        qSt.setParameter("uid", user.getUserId());
        List<Station> stations = qSt.list();
        int totalStations = stations.size();
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
        <div class="stat-card clickable" onclick="openStationsModal()" title="Click to view station details">
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

<!-- ===================== ACTIVE STATIONS MODAL ===================== -->
<div class="modal-overlay" id="stationsModal" onclick="handleOverlayClick(event)">
    <div class="modal">
        <div class="modal-header">
            <h2><i class="fa-solid fa-charging-station"></i> My Active Stations</h2>
            <button class="modal-close" onclick="closeStationsModal()">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <div class="station-list">
                <%
                    org.hibernate.Session s2 = FactoryProvider.getFactory().openSession();
                    String hqlModal = "FROM Station WHERE ownerId = :uid";
                    Query<Station> qModal = s2.createQuery(hqlModal, Station.class);
                    qModal.setParameter("uid", user.getUserId());
                    List<Station> modalStations = qModal.list();

                    if (modalStations.isEmpty()) {
                %>
                <div class="modal-empty">
                    <div class="empty-icon"><i class="fa-solid fa-charging-station"></i></div>
                    <p>You haven't added any stations yet.</p>
                </div>
                <%
                } else {
                    for (Station st : modalStations) {
                        String badgeClass = st.getStatus().equalsIgnoreCase("Active") ? "badge-active" : "badge-inactive";
                %>
                <div class="station-item">
                    <div class="station-item-header">
                        <div class="station-item-name">
                            <i class="fa-solid fa-bolt"></i>
                            <%= st.getStationName() %>
                        </div>
                        <span class="badge <%= badgeClass %>">
                <i class="fa-solid fa-circle" style="font-size:0.55rem;vertical-align:middle;margin-right:4px;"></i>
                <%= st.getStatus() %>
            </span>
                    </div>

                    <div class="station-item-body">
                        <div class="detail-cell">
                            <span class="d-label"><i class="fa-solid fa-location-dot"></i> Address</span>
                            <span class="d-val"><%= st.getStationAddress() %></span>
                        </div>
                        <div class="detail-cell">
                            <span class="d-label"><i class="fa-solid fa-plug"></i> Connector Type</span>
                            <span class="d-val"><%= st.getConnectorType() %></span>
                        </div>
                        <div class="detail-cell">
                            <span class="d-label"><i class="fa-solid fa-tag"></i> Category</span>
                            <span class="d-val"><%= st.getStationCategory() %></span>
                        </div>
                        <div class="detail-cell">
                            <span class="d-label"><i class="fa-solid fa-indian-rupee-sign"></i> Price per Unit</span>
                            <span class="d-val green">₹<%= String.format("%.2f", st.getPricePerUnit()) %></span>
                        </div>
                        <div class="detail-cell">
                            <span class="d-label"><i class="fa-solid fa-building"></i> Provider</span>
                            <span class="d-val"><%= st.getProviderName() %></span>
                        </div>
                        <div class="detail-cell">
                            <span class="d-label"><i class="fa-solid fa-map-pin"></i> Coordinates</span>
                            <span class="d-val" style="font-size:0.82rem"><%= st.getLatitude() %>, <%= st.getLongitude() %></span>
                        </div>
                    </div>

                    <div class="station-item-footer">
                        <i class="fa-solid fa-circle-info"></i>
                        <%= st.getStationDescription() != null ? st.getStationDescription() : "No description provided." %>
                        &nbsp;|&nbsp;
                        <i class="fa-solid fa-id-badge"></i> Station ID: #<%= st.getStationId() %>
                    </div>
                </div>
                <%
                        }
                    }
                    s2.close();
                %>
            </div>
        </div>
    </div>
</div>

<script>
    function openStationsModal() {
        document.getElementById('stationsModal').classList.add('active');
        document.body.style.overflow = 'hidden';
    }

    function closeStationsModal() {
        document.getElementById('stationsModal').classList.remove('active');
        document.body.style.overflow = '';
    }

    function handleOverlayClick(e) {
        if (e.target === document.getElementById('stationsModal')) {
            closeStationsModal();
        }
    }

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') closeStationsModal();
    });
</script>

</body>
</html>