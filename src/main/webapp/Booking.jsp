<%@page import="com.ezev.entities.Station"%>
<%@page import="com.ezev.helper.FactoryProvider"%>
<%@page import="org.hibernate.Session"%>
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

    // Get station ID from parameter
    String stationIdParam = request.getParameter("stationId");
    Station station = null;
    
    if (stationIdParam != null && !stationIdParam.trim().isEmpty()) {
        Session hibSession = null;
        try {
            int stationId = Integer.parseInt(stationIdParam);
            hibSession = FactoryProvider.getFactory().openSession();
            station = hibSession.get(Station.class, stationId);
            
            if (station != null) {
                System.out.println("Loaded station: " + station.getStationName());
            }
        } catch (Exception e) {
            System.err.println("Error loading station: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (hibSession != null && hibSession.isOpen()) {
                hibSession.close();
            }
        }
    }
    
    if (station == null) {
        session.setAttribute("message", "Station not found!");
        response.sendRedirect("FindChargers.jsp");
        return;
    }
    
    // Safe string escaping for JavaScript
    String safeName = station.getStationName() != null ? 
        station.getStationName().replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"") : "Station";
    String safeAddress = station.getStationAddress() != null ? 
        station.getStationAddress().replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"") : "Address";
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Book Slot - <%= station.getStationName() %></title>
  <style>
    :root {
      --bright-snow: #FAFAFA;
      --pale-slate: #D2D7DF;
      --dusk-blue: #2E5077;
      --deep-navy: #00003D;
      --coffee-bean: #14010B;
      --success-green: #10B981;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      background-color: var(--bright-snow);
      color: var(--coffee-bean);
      line-height: 1.6;
    }
    .grid-bg {
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background-image: linear-gradient(var(--pale-slate) 1px, transparent 1px),
                        linear-gradient(90deg, var(--pale-slate) 1px, transparent 1px);
      background-size: 30px 30px; opacity: 0.2; z-index: -1;
    }
    .container { max-width: 1200px; margin: 0 auto; padding: 0 24px; }
    .header {
      background: rgba(250, 250, 250, 0.95);
      padding: 20px 0; position: sticky; top: 0; z-index: 1000;
      border-bottom: 1px solid var(--pale-slate);
    }
    .nav-container { display: flex; justify-content: space-between; align-items: center; }
    .nav-menu { display: flex; list-style: none; gap: 35px; }
    .nav-link { text-decoration: none; color: var(--coffee-bean); font-weight: 500; }
    .nav-link:hover { color: var(--dusk-blue); }
    .btn {
      padding: 14px 28px; border: none; border-radius: 12px;
      font-size: 1rem; font-weight: 600; cursor: pointer;
      transition: all 0.3s; text-decoration: none; display: inline-block;
    }
    .btn-primary {
      background: linear-gradient(135deg, var(--dusk-blue), var(--deep-navy));
      color: white;
    }
    .btn-primary:hover { transform: translateY(-2px); }
    .page-wrapper { padding: 40px 0 80px; }
    .page-title { font-size: 2.2rem; margin-bottom: 30px; font-weight: 800; }
    .booking-grid {
      display: grid; grid-template-columns: 1fr 380px;
      gap: 40px; align-items: start;
    }
    .section-card {
      background: white; border-radius: 24px; padding: 30px;
      margin-bottom: 24px; border: 1px solid var(--pale-slate);
    }
    .section-title {
      font-size: 1.25rem; color: var(--dusk-blue); font-weight: 700;
      display: flex; align-items: center; gap: 10px; margin-bottom: 20px;
      padding-bottom: 15px; border-bottom: 1px solid var(--pale-slate);
    }
    .step-num {
      background: var(--dusk-blue); color: white;
      width: 28px; height: 28px; border-radius: 50%;
      display: flex; align-items: center; justify-content: center;
    }
    .date-scroll { display: flex; gap: 12px; overflow-x: auto; margin-bottom: 20px; }
    .date-card {
      min-width: 80px; padding: 12px; border: 2px solid var(--pale-slate);
      border-radius: 12px; text-align: center; cursor: pointer;
      transition: all 0.2s; background: white;
    }
    .date-card:hover { border-color: var(--dusk-blue); }
    .date-card.active {
      background: var(--dusk-blue); color: white; border-color: var(--dusk-blue);
    }
    .day-name { font-size: 0.8rem; text-transform: uppercase; font-weight: 600; display: block; }
    .day-num { font-size: 1.2rem; font-weight: 700; }
    .time-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 12px; }
    .time-slot {
      padding: 10px; border: 1px solid var(--pale-slate); border-radius: 8px;
      text-align: center; font-size: 0.9rem; cursor: pointer; transition: all 0.2s;
    }
    .time-slot:hover { background: #F1F5F9; border-color: var(--dusk-blue); }
    .time-slot.active {
      background: var(--dusk-blue); color: white; border-color: var(--dusk-blue);
    }
    .time-slot.disabled {
      background: #F8FAFC; color: #CBD5E1; cursor: not-allowed;
    }
    .connector-select {
      display: flex; align-items: center; gap: 15px; padding: 15px;
      border: 2px solid var(--pale-slate); border-radius: 12px;
      cursor: pointer; transition: all 0.2s;
    }
    .connector-select.active {
      border-color: var(--dusk-blue); background: rgba(46, 80, 119, 0.05);
    }
    .radio-circle {
      width: 20px; height: 20px; border: 2px solid var(--pale-slate);
      border-radius: 50%; display: flex; align-items: center; justify-content: center;
    }
    .connector-select.active .radio-circle { border-color: var(--dusk-blue); }
    .connector-select.active .radio-circle::after {
      content: ''; width: 10px; height: 10px;
      background: var(--dusk-blue); border-radius: 50%;
    }
    .input-group { margin-bottom: 15px; }
    .input-label {
      display: block; margin-bottom: 8px; font-weight: 600; font-size: 0.9rem;
    }
    .input-field {
      width: 100%; padding: 12px; border: 2px solid var(--pale-slate);
      border-radius: 10px; font-size: 1rem; outline: none;
    }
    .input-field:focus { border-color: var(--dusk-blue); }
    .summary-card {
      background: white; border: 2px solid var(--pale-slate);
      border-radius: 24px; padding: 30px; position: sticky; top: 100px;
    }
    .summary-row {
      display: flex; justify-content: space-between; margin-bottom: 12px;
      font-size: 0.95rem; color: var(--dusk-blue);
    }
    .summary-total {
      display: flex; justify-content: space-between; margin-top: 20px;
      padding-top: 20px; border-top: 1px solid var(--pale-slate);
      font-weight: 800; font-size: 1.2rem;
    }
    .info-badge {
      background: rgba(16, 185, 129, 0.1); color: var(--success-green);
      padding: 8px 12px; border-radius: 8px; font-size: 0.85rem;
      font-weight: 600; display: inline-flex; gap: 6px;
    }
    @media (max-width: 900px) {
      .booking-grid { grid-template-columns: 1fr; }
      .summary-card { position: static; }
    }
  </style>
</head>
<body>
  <div class="grid-bg"></div>
  
  <header class="header">
    <div class="container">
      <nav class="nav-container">
        <a href="Dashboard.jsp">
          <img src="ezev-logo.png" alt="EzEv" style="height: 50px;">
        </a>
        <ul class="nav-menu">
          <li><a href="Dashboard.jsp" class="nav-link">Dashboard</a></li>
          <li><a href="FindChargers.jsp" class="nav-link">Find Chargers</a></li>
          <li><a href="#" class="nav-link">My Bookings</a></li>
        </ul>
      </nav>
    </div>
  </header>

  <div class="container page-wrapper">
    <h1 class="page-title">Complete your Reservation</h1>

    <div class="booking-grid">
      <div class="booking-form">
        
        <div class="section-card">
          <h2 class="section-title"><span class="step-num">1</span> Select Date & Time</h2>
          <div class="date-scroll" id="dateScroll"></div>
          <h4 style="margin-bottom: 12px;">Available Slots</h4>
          <div class="time-grid" id="timeGrid"></div>
        </div>

        <div class="section-card">
          <h2 class="section-title"><span class="step-num">2</span> Connector Type</h2>
          <div class="connector-select active">
            <div class="radio-circle"></div>
            <div style="flex-grow: 1;">
              <h4><%= station.getConnectorType() %></h4>
              <span>₹<%= String.format("%.2f", station.getPricePerUnit()) %> / kWh</span>
            </div>
            <div style="font-size: 1.5rem;">⚡</div>
          </div>
        </div>

        <div class="section-card">
          <h2 class="section-title"><span class="step-num">3</span> Vehicle Details</h2>
          <div class="input-group">
            <label class="input-label">Vehicle Model *</label>
            <select class="input-field" id="vehicleModel" required>
              <option value="">Select your vehicle</option>
              <option>Tata Nexon EV</option>
              <option>Tata Tiago EV</option>
              <option>MG ZS EV</option>
              <option>Hyundai Ioniq 5</option>
              <option>Tesla Model 3</option>
              <option>Other</option>
            </select>
          </div>
          <div class="input-group">
            <label class="input-label">Vehicle Number (Optional)</label>
            <input type="text" class="input-field" id="vehicleNumber" placeholder="KA 01 AB 1234">
          </div>
          <div class="input-group">
            <label class="input-label">Battery Capacity (kWh)</label>
            <input type="number" class="input-field" id="batteryCapacity" placeholder="40.5" step="0.1">
          </div>
        </div>
      </div>

      <aside class="booking-summary">
        <div class="summary-card">
          <h3 style="margin-bottom: 20px;">Order Summary</h3>
          <div style="margin-bottom: 20px;">
            <h4><%= station.getStationName() %></h4>
            <p style="font-size: 0.85rem; color: var(--dusk-blue);"><%= station.getStationAddress() %></p>
          </div>
          
          <div style="border-top: 1px solid var(--pale-slate); border-bottom: 1px solid var(--pale-slate); padding: 15px 0; margin-bottom: 20px;">
            <div class="summary-row">
              <span>Provider</span>
              <span style="font-weight: 600;"><%= station.getProviderName() %></span>
            </div>
            <div class="summary-row">
              <span>Date</span>
              <span style="font-weight: 600;" id="selectedDate">Select date</span>
            </div>
            <div class="summary-row">
              <span>Time Slot</span>
              <span style="font-weight: 600;" id="selectedTime">Select time</span>
            </div>
            <div class="summary-row">
              <span>Connector</span>
              <span style="font-weight: 600;"><%= station.getConnectorType() %></span>
            </div>
          </div>

          <div class="summary-row">
            <span>Booking Fee</span>
            <span>₹50.00</span>
          </div>
          <div class="summary-row">
            <span>Energy Rate</span>
            <span>₹<%= String.format("%.2f", station.getPricePerUnit()) %>/kWh</span>
          </div>

          <div class="info-badge" style="margin: 15px 0; width: 100%;">
            <span>✓</span>
            <span>Free Cancellation (30 min before)</span>
          </div>

          <div class="summary-total">
            <span>Total to Pay Now</span>
            <span>₹50.00</span>
          </div>

          <button class="btn btn-primary" style="width: 100%; margin-top: 20px;" onclick="confirmBooking()">
            Confirm & Pay
          </button>
        </div>
      </aside>
    </div>
  </div>

  <script>
    console.log('=== BOOKING PAGE LOADED ===');
    
    var stationData = {
      id: <%= station.getStationId() %>,
      name: '<%= safeName %>',
      address: '<%= safeAddress %>',
      price: <%= station.getPricePerUnit() %>
    };
    
    console.log('Station data:', stationData);

    var selectedDate = null;
    var selectedTime = null;

    function generateDates() {
      var dateScroll = document.getElementById('dateScroll');
      var today = new Date();
      
      for (var i = 0; i < 7; i++) {
        var date = new Date(today);
        date.setDate(today.getDate() + i);
        
        var dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        var dayName = i === 0 ? 'Today' : dayNames[date.getDay()];
        var dayNum = date.getDate();
        
        var dateCard = document.createElement('div');
        dateCard.className = 'date-card' + (i === 0 ? ' active' : '');
        dateCard.innerHTML = '<span class="day-name">' + dayName + '</span><span class="day-num">' + dayNum + '</span>';
        dateCard.dataset.date = date.toISOString().split('T')[0];
        dateCard.onclick = (function(card) {
          return function() { selectDate(card); };
        })(dateCard);
        
        dateScroll.appendChild(dateCard);
      }
      
      selectedDate = today.toISOString().split('T')[0];
      updateSummary();
    }

    function generateTimeSlots() {
      var timeGrid = document.getElementById('timeGrid');
      
      for (var hour = 9; hour <= 20; hour++) {
        for (var min = 0; min < 60; min += 30) {
          var timeStr = hour.toString().padStart(2, '0') + ':' + min.toString().padStart(2, '0');
          var displayHour = hour > 12 ? hour - 12 : hour;
          var displayTime = displayHour + ':' + min.toString().padStart(2, '0') + ' ' + (hour >= 12 ? 'PM' : 'AM');
          
          var timeSlot = document.createElement('div');
          timeSlot.className = 'time-slot';
          timeSlot.textContent = displayTime;
          timeSlot.dataset.time = timeStr;
          
          if (Math.random() < 0.2) {
            timeSlot.classList.add('disabled');
          } else {
            timeSlot.onclick = (function(slot) {
              return function() { selectTime(slot); };
            })(timeSlot);
          }
          
          timeGrid.appendChild(timeSlot);
        }
      }
      
      var firstAvailable = timeGrid.querySelector('.time-slot:not(.disabled)');
      if (firstAvailable) firstAvailable.click();
    }

    function selectDate(element) {
      document.querySelectorAll('.date-card').forEach(function(d) {
        d.classList.remove('active');
      });
      element.classList.add('active');
      selectedDate = element.dataset.date;
      updateSummary();
    }

    function selectTime(element) {
      document.querySelectorAll('.time-slot').forEach(function(s) {
        s.classList.remove('active');
      });
      element.classList.add('active');
      selectedTime = element.dataset.time;
      updateSummary();
    }

    function updateSummary() {
      if (selectedDate) {
        var date = new Date(selectedDate);
        var options = { month: 'short', day: 'numeric', year: 'numeric' };
        document.getElementById('selectedDate').textContent = date.toLocaleDateString('en-US', options);
      }
      
      if (selectedTime) {
        var parts = selectedTime.split(':');
        var hour = parseInt(parts[0]);
        var min = parts[1];
        var endHour = hour + 1;
        var displayStart = (hour > 12 ? hour - 12 : hour) + ':' + min + ' ' + (hour >= 12 ? 'PM' : 'AM');
        var displayEnd = (endHour > 12 ? endHour - 12 : endHour) + ':' + min + ' ' + (endHour >= 12 ? 'PM' : 'AM');
        document.getElementById('selectedTime').textContent = displayStart + ' - ' + displayEnd;
      }
    }

    function confirmBooking() {
      console.log('=== CONFIRM BOOKING CLICKED ===');
      
      if (!selectedDate || !selectedTime) {
        alert('Please select date and time');
        console.error('Missing:', {date: selectedDate, time: selectedTime});
        return;
      }

      var vehicleModel = document.getElementById('vehicleModel').value;
      if (!vehicleModel) {
        alert('Please select your vehicle model');
        return;
      }

      console.log('Creating booking form...');
      
      var form = document.createElement('form');
      form.method = 'POST';
      form.action = 'BookingServlet';

      var fields = {
        stationId: stationData.id,
        bookingDate: selectedDate,
        bookingTime: selectedTime,
        vehicleModel: vehicleModel,
        vehicleNumber: document.getElementById('vehicleNumber').value || '',
        batteryCapacity: document.getElementById('batteryCapacity').value || '0',
        amount: '50.00'
      };

      console.log('Form data:', fields);

      for (var key in fields) {
        var input = document.createElement('input');
        input.type = 'hidden';
        input.name = key;
        input.value = fields[key];
        form.appendChild(input);
      }

      document.body.appendChild(form);
      console.log('Submitting form to BookingServlet...');
      form.submit();
    }

    window.addEventListener('load', function() {
      console.log('Initializing booking page...');
      generateDates();
      generateTimeSlots();
      console.log('Page ready!');
    });
  </script>
</body>
</html>
