<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response. sendRedirect("Login.html");
        return;
    }
    
    // Get and clear messages
    String message = (String) session. getAttribute("wishlistMessage");
    String messageType = (String) session.getAttribute("wishlistMessageType");
    session. removeAttribute("wishlistMessage");
    session.removeAttribute("wishlistMessageType");
    
    // Fetch wishlist items
    List<Book> wishlistBooks = new ArrayList<>();
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/books", "guest", "guest");
        
        String query = "SELECT w.WishlistID, w.ISBN, w.Title, " +
                      "bi.Author, bi.Price, bi.EditionNumber, bi.Publisher, bi.Copyright " +
                      "FROM Wishlist w " +
                      "JOIN BookInfo bi ON w.ISBN = bi.ISBN " +
                      "WHERE w.UserID = ? ORDER BY w.Title";
        stmt = conn.prepareStatement(query);
        stmt.setInt(1, user. getUserID());
        rs = stmt.executeQuery();
        
        while (rs.next()) {
            wishlistBooks.add(new Book(
                rs.getString("ISBN"),
                rs. getString("Author"),
                rs.getString("Title"),
                rs.getDouble("Price"),
                rs. getInt("EditionNumber"),
                rs.getString("Publisher"),
                rs.getString("Copyright")
            ));
        }
        
        // Store in session for OrderServlet (same as BrowseBooks. jsp)
        session.setAttribute("foundBooks", wishlistBooks);
        
    } catch (Exception e) {
        e. printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn. close();
        } catch (Exception e) {}
    }
%>
<! DOCTYPE html>
<html>
<head>
    <title>My Wishlist</title>
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
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .page-title { color: #333; margin: 0; }
        .item-count { color: #666; }
        .message {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .message-success { background-color: #d4edda; color: #155724; }
        .message-error { background-color: #f8d7da; color: #721c24; }
        .message-info { background-color: #cce5ff; color: #004085; }
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
        .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 13px;
            display: inline-block;
            margin-right: 5px;
        }
        .btn-cart { background-color: #4CAF50; color: white; }
        .btn-cart:hover { background-color: #45a049; }
        .btn-remove { background-color: #d32f2f; color: white; }
        .btn-remove:hover { background-color: #b71c1c; }
        .btn-primary { background-color: #1976D2; color: white; }
        .btn-primary:hover { background-color: #1565C0; }
        .empty-wishlist {
            text-align: center;
            padding: 50px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .empty-wishlist h3 { color: #666; }
        . empty-wishlist p { color: #999; margin-bottom: 20px; }
        .action-buttons {
            margin-top: 20px;
            text-align: center;
        }
        .action-buttons a { margin: 0 10px; padding: 10px 20px; }
    </style>
    <script>
        function confirmRemove(title) {
            return confirm("Remove '" + title + "' from your wishlist?");
        }
    </script>
</head>
<body>
    <div class="navbar">
        <h1>My Wishlist</h1>
        <div class="navbar-links">
            <a href="StudentDashboard.jsp">Dashboard</a>
            <a href="SearchBook.html">Search</a>
            <a href="BrowseBooks.jsp">Browse All</a>
            <a href="show-order.jsp">Cart</a>
            <a href="PurchaseHistory.jsp">My Purchases</a>
            <a href="LogoutServlet" class="logout">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <% if (message != null) { %>
            <div class="message message-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <div class="page-header">
            <h2 class="page-title">My Wishlist</h2>
            <span class="item-count"><%= wishlistBooks. size() %> item(s)</span>
        </div>
        
        <% if (! wishlistBooks.isEmpty()) { %>
            <table>
                <tr>
                    <th>Book Title</th>
                    <th>Author</th>
                    <th>Publisher</th>
                    <th>Price</th>
                    <th>Actions</th>
                </tr>
                <% for (int i = 0; i < wishlistBooks.size(); i++) { 
                    Book book = wishlistBooks. get(i);
                %>
                <tr>
                    <td><%= book.getTitle() %></td>
                    <td><%= book. getAuthor() %></td>
                    <td><%= book.getPublisher() %></td>
                    <td class="price">$<%= String.format("%.2f", book.getPrice()) %></td>
                    <td>
                        <a href="OrderServlet?selectedBook=<%= i %>" class="btn btn-cart">Add to Cart</a>
                        <a href="RemoveFromWishlistServlet?isbn=<%= book. getIsbn() %>" 
                           class="btn btn-remove" 
                           onclick="return confirmRemove('<%= book.getTitle() %>')">Remove</a>
                    </td>
                </tr>
                <% } %>
            </table>
            
            <div class="action-buttons">
                <a href="BrowseBooks.jsp" class="btn btn-primary">Continue Browsing</a>
                <a href="show-order.jsp" class="btn btn-cart">View Cart</a>
            </div>
        <% } else { %>
            <div class="empty-wishlist">
                <h3>Your Wishlist is Empty</h3>
                <p>Save books you're interested in for later!</p>
                <a href="BrowseBooks.jsp" class="btn btn-primary">Browse Books</a>
            </div>
        <% } %>
    </div>
</body>
</html>