<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java. sql.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect("Login.html");
        return;
    }
    
    // Fetch recent purchases
    List<Map<String, Object>> recentPurchases = new ArrayList<>();
    int wishlistCount = 0;
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/books", "guest", "guest");
        
        // Get recent purchases
        String query = "SELECT ph.*, bi.Title, bi.Author FROM PurchaseHistory ph " +
                      "JOIN BookInfo bi ON ph.ISBN = bi.ISBN " +
                      "WHERE ph.UserID = ?  ORDER BY ph.PurchaseDate DESC LIMIT 5";
        stmt = conn. prepareStatement(query);
        stmt. setInt(1, user.getUserID());
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            Map<String, Object> purchase = new HashMap<>();
            purchase.put("title", rs.getString("Title"));
            purchase.put("author", rs.getString("Author"));
            purchase. put("price", rs.getDouble("Price"));
            purchase.put("date", rs.getTimestamp("PurchaseDate"));
            recentPurchases. add(purchase);
        }
        
        rs.close();
        stmt.close();
        
        // Get wishlist count
        String wishlistQuery = "SELECT COUNT(*) FROM Wishlist WHERE UserID = ?";
        stmt = conn.prepareStatement(wishlistQuery);
        stmt.setInt(1, user.getUserID());
        rs = stmt.executeQuery();
        if (rs.next()) {
            wishlistCount = rs.getInt(1);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (Exception e) {}
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Student Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .navbar {
            background-color: #1976D2;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        . navbar h1 { font-size: 24px; margin: 0; }
        .navbar-links a {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 4px;
            margin-left: 10px;
        }
        .navbar-links a:hover { background-color: rgba(255,255,255,0.1); }
        . navbar-links a. logout { background-color: #d32f2f; }
        .navbar-links a.wishlist { background-color: #e91e63; }
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .welcome-msg {
            background-color: #1976D2;
            color: white;
            padding: 30px;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        .welcome-msg h2 { margin: 0 0 10px 0; }
        .welcome-msg p { margin: 0; }
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
        }
        .dashboard-card {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            padding: 25px;
        }
        .dashboard-card h3 {
            color: #333;
            margin: 0 0 20px 0;
            padding-bottom: 10px;
            border-bottom: 2px solid #1976D2;
        }
        .dashboard-card ul {
            list-style: none;
            padding: 0;
            margin: 0;
        }
        .dashboard-card ul li { margin: 12px 0; }
        .dashboard-card ul li a {
            color: #1976D2;
            text-decoration: none;
            font-size: 16px;
        }
        .dashboard-card ul li a:hover { text-decoration: underline; }
        .dashboard-card ul li a.highlight {
            color: #ff9800;
            font-weight: bold;
        }
        .dashboard-card ul li a.wishlist-link {
            color: #e91e63;
            font-weight: bold;
        }
        . badge {
            background-color: #e91e63;
            color: white;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 12px;
            margin-left: 5px;
        }
        .purchase-item {
            padding: 12px 0;
            border-bottom: 1px solid #eee;
        }
        .purchase-item:last-child { border-bottom: none; }
        . purchase-title { font-weight: bold; color: #333; }
        .purchase-info { font-size: 14px; color: #666; margin-top: 5px; }
        .no-purchases {
            color: #666;
            font-style: italic;
            text-align: center;
            padding: 20px;
        }
        .view-all {
            display: block;
            text-align: center;
            margin-top: 15px;
            color: #1976D2;
            text-decoration: none;
        }
        .view-all:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>Online Bookstore</h1>
        <div class="navbar-links">
            <a href="SearchBook.html">Search</a>
            <a href="AdvancedSearch. jsp">Advanced Search</a>
            <a href="BrowseBooks.jsp">Browse All</a>
            <a href="Wishlist.jsp" class="wishlist">❤️ Wishlist (<%= wishlistCount %>)</a>
            <a href="show-order.jsp">Cart</a>
            <a href="PurchaseHistory. jsp">My Purchases</a>
            <a href="LogoutServlet" class="logout">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="welcome-msg">
            <h2>Welcome back, <%= user.getUsername() %>!</h2>
            <p>Browse our collection and find your next great read.</p>
        </div>
        
        <div class="dashboard-grid">
            <!-- Quick Actions -->
            <div class="dashboard-card">
                <h3>Quick Actions</h3>
                <ul>
                    <li><a href="SearchBook.html">Simple Search (ISBN/Author)</a></li>
                    <li><a href="AdvancedSearch. jsp" class="highlight">Advanced Search & Filters</a></li>
                    <li><a href="BrowseBooks.jsp">Browse All Books</a></li>
                    <li><a href="Wishlist.jsp" class="wishlist-link">❤️ My Wishlist <span class="badge"><%= wishlistCount %></span></a></li>
                    <li><a href="show-order.jsp">View Shopping Cart</a></li>
                    <li><a href="PurchaseHistory. jsp">View Purchase History</a></li>
                </ul>
            </div>
            
            <!-- Recent Purchases -->
            <div class="dashboard-card">
                <h3>Recent Purchases</h3>
                <% if (recentPurchases.isEmpty()) { %>
                    <p class="no-purchases">No purchases yet. Start shopping!</p>
                <% } else { %>
                    <% for (Map<String, Object> purchase : recentPurchases) { %>
                        <div class="purchase-item">
                            <div class="purchase-title"><%= purchase.get("title") %></div>
                            <div class="purchase-info">
                                by <%= purchase.get("author") %> | 
                                $<%= String.format("%.2f", purchase.get("price")) %>
                            </div>
                        </div>
                    <% } %>
                    <a href="PurchaseHistory.jsp" class="view-all">View All Purchases</a>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>