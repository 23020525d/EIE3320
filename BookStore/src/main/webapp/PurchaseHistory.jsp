<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java. util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect("Login.html");
        return;
    }
    
    List<Map<String, Object>> purchases = new ArrayList<>();
    double totalSpent = 0;
    String errorMsg = null;
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/books", "guest", "guest");
        
        String query = "SELECT ph.PurchaseID, ph.ISBN, ph.Price, ph.Quantity, ph.PurchaseDate, " +
                      "bi.Title, bi.Author FROM PurchaseHistory ph " +
                      "JOIN BookInfo bi ON ph. ISBN = bi.ISBN " +
                      "WHERE ph.UserID = ? ORDER BY ph.PurchaseDate DESC";
        stmt = conn.prepareStatement(query);
        stmt.setInt(1, user. getUserID());
        rs = stmt.executeQuery();
        
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
        
        while (rs. next()) {
            Map<String, Object> purchase = new HashMap<>();
            purchase. put("purchaseId", rs.getInt("PurchaseID"));
            purchase.put("isbn", rs.getString("ISBN"));
            purchase. put("title", rs.getString("Title"));
            purchase.put("author", rs.getString("Author"));
            purchase. put("price", rs.getDouble("Price"));
            purchase.put("quantity", rs.getInt("Quantity"));
            
            Timestamp ts = rs.getTimestamp("PurchaseDate");
            purchase.put("date", ts != null ? sdf. format(ts) : "N/A");
            
            purchases.add(purchase);
            totalSpent += rs.getDouble("Price") * rs.getInt("Quantity");
        }
    } catch (Exception e) {
        errorMsg = e.getMessage();
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt. close();
            if (conn != null) conn.close();
        } catch (Exception e) {}
    }
%>
<! DOCTYPE html>
<html>
<head>
    <title>Purchase History</title>
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
        .navbar h1 { font-size: 24px; margin: 0; }
        .navbar-links a {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 4px;
            margin-left: 10px;
        }
        .navbar-links a:hover { background-color: rgba(255,255,255,0.1); }
        . navbar-links a.logout { background-color: #d32f2f; }
        .container {
            max-width: 1000px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .summary {
            background-color: #4CAF50;
            color: white;
            padding: 20px 30px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        . summary h3 { margin: 0; }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #1976D2;
            color: white;
        }
        tr:hover { background-color: #f5f5f5; }
        .price { color: #d32f2f; font-weight: bold; }
        .no-history {
            text-align: center;
            padding: 50px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0. 1);
        }
        .no-history h3 { color: #666; }
        . no-history p { color: #999; margin-bottom: 20px; }
        . btn {
            display: inline-block;
            padding: 10px 20px;
            background-color: #1976D2;
            color: white;
            text-decoration: none;
            border-radius: 4px;
        }
        .btn:hover { background-color: #1565C0; }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>Purchase History</h1>
        <div class="navbar-links">
            <a href="StudentDashboard.jsp">Dashboard</a>
            <a href="SearchBook.html">Search</a>
            <a href="BrowseBooks.jsp">Browse All</a>
            <a href="show-order.jsp">Cart</a>
            <a href="LogoutServlet" class="logout">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <% if (errorMsg != null) { %>
            <div class="error">
                Error: <%= errorMsg %>
            </div>
        <% } %>
        
        <% if (! purchases.isEmpty()) { %>
            <div class="summary">
                <div>
                    <h3>Total Purchases: <%= purchases.size() %></h3>
                </div>
                <div>
                    <h3>Total Spent: $<%= String.format("%.2f", totalSpent) %></h3>
                </div>
            </div>
            
            <table>
                <tr>
                    <th>Order #</th>
                    <th>Book Title</th>
                    <th>Author</th>
                    <th>Qty</th>
                    <th>Price</th>
                    <th>Date</th>
                </tr>
                <% for (Map<String, Object> p : purchases) { %>
                <tr>
                    <td>#<%= p.get("purchaseId") %></td>
                    <td><%= p.get("title") %></td>
                    <td><%= p.get("author") %></td>
                    <td><%= p.get("quantity") %></td>
                    <td class="price">$<%= String.format("%.2f", p.get("price")) %></td>
                    <td><%= p.get("date") %></td>
                </tr>
                <% } %>
            </table>
        <% } else { %>
            <div class="no-history">
                <h3>No Purchase History</h3>
                <p>You haven't made any purchases yet.</p>
                <a href="SearchBook.html" class="btn">Start Shopping</a>
            </div>
        <% } %>
    </div>
</body>
</html>