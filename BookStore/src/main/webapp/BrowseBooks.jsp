<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect("Login.html");
        return;
    }
    
    // Get and clear messages
    String message = (String) session.getAttribute("wishlistMessage");
    String messageType = (String) session.getAttribute("wishlistMessageType");
    session. removeAttribute("wishlistMessage");
    session.removeAttribute("wishlistMessageType");
    
    List<Book> books = new ArrayList<>();
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/books", "guest", "guest");
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT * FROM BookInfo ORDER BY Title");
        
        while (rs.next()) {
            books.add(new Book(
                rs. getString("ISBN"),
                rs. getString("Author"),
                rs.getString("Title"),
                rs.getDouble("Price"),
                rs. getInt("EditionNumber"),
                rs.getString("Publisher"),
                rs.getString("Copyright")
            ));
        }
        
        session.setAttribute("foundBooks", books);
        
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
    <title>Browse All Books</title>
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
        . page-title { color: #333; margin: 0; }
        .book-count { color: #666; }
        .message {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        . message-success { background-color: #d4edda; color: #155724; }
        .message-error { background-color: #f8d7da; color: #721c24; }
        . message-info { background-color: #cce5ff; color: #004085; }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #1976D2;
            color: white;
        }
        tr:hover { background-color: #f5f5f5; }
        . btn {
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
        . btn-wishlist { background-color: #e91e63; color: white; }
        .btn-wishlist:hover { background-color: #c2185b; }
        .price { color: #d32f2f; font-weight: bold; }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>Browse All Books</h1>
        <div class="navbar-links">
            <a href="StudentDashboard.jsp">Dashboard</a>
            <a href="SearchBook.html">Search</a>
            <a href="Wishlist.jsp">❤️ Wishlist</a>
            <a href="show-order.jsp">Cart</a>
            <a href="PurchaseHistory. jsp">My Purchases</a>
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
            <h2 class="page-title">All Available Books</h2>
            <span class="book-count">Total: <%= books.size() %> books</span>
        </div>
        
        <table>
            <tr>
                <th>Title</th>
                <th>Author</th>
                <th>Edition</th>
                <th>Publisher</th>
                <th>Year</th>
                <th>Price</th>
                <th>Actions</th>
            </tr>
            <% for (int i = 0; i < books.size(); i++) { 
                Book book = books.get(i);
            %>
            <tr>
                <td><%= book.getTitle() %></td>
                <td><%= book.getAuthor() %></td>
                <td><%= book. getEdition() %></td>
                <td><%= book.getPublisher() %></td>
                <td><%= book.getCopyright() %></td>
                <td class="price">$<%= String.format("%.2f", book.getPrice()) %></td>
                <td>
                    <a href="OrderServlet?selectedBook=<%= i %>" class="btn btn-cart">Add to Cart</a>
                    <a href="AddToWishlistServlet?isbn=<%= book.getIsbn() %>&redirect=BrowseBooks.jsp" class="btn btn-wishlist">❤️ Wishlist</a>
                </td>
            </tr>
            <% } %>
        </table>
    </div>
</body>
</html>