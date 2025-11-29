<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util. ArrayList" %>
<%@ page import="java. util.Date" %>
<%@ page import="bookstore.*" %>
<%
    ArrayList<Book> books = (ArrayList<Book>)session.getAttribute("foundBooks");
    int numBooks = books != null ? books.size() : 0;
    User user = (User) session.getAttribute("currentUser");
%>
<! DOCTYPE html>
<html>
<head>
    <title>Search Results</title>
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
        .page-title { color: #333; margin: 0; }
        .result-count { color: #666; font-size: 14px; }
        .datetime {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-size: 14px;
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
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #1976D2;
            color: white;
        }
        tr:hover { background-color: #f5f5f5; }
        .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            background-color: #4CAF50;
            color: white;
            display: inline-block;
        }
        .btn:hover { background-color: #45a049; }
        . btn-back { background-color: #1976D2; }
        .btn-back:hover { background-color: #1565C0; }
        .price { color: #d32f2f; font-weight: bold; }
        . no-results {
            text-align: center;
            padding: 50px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0. 1);
        }
        .no-results h3 { color: #666; }
        .no-results p { color: #999; margin-bottom: 20px; }
        .action-buttons {
            margin-top: 20px;
            text-align: center;
        }
        .action-buttons a { margin: 0 10px; }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>Search Results</h1>
        <div class="navbar-links">
            <a href="StudentDashboard.jsp">Dashboard</a>
            <a href="SearchBook.html">Search</a>
            <a href="show-order.jsp">Cart</a>
            <a href="PurchaseHistory.jsp">My Purchases</a>
            <a href="LogoutServlet" class="logout">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="datetime">Current Time: <%= new Date() %></div>
        
        <div class="page-header">
            <h2 class="page-title">Search Results</h2>
            <span class="result-count"><%= numBooks %> book(s) found</span>
        </div>
        
        <% if (numBooks > 0) { %>
            <table>
                <tr>
                    <th>ISBN</th>
                    <th>Title</th>
                    <th>Author</th>
                    <th>Edition</th>
                    <th>Publisher</th>
                    <th>Copyright</th>
                    <th>Price</th>
                    <th>Action</th>
                </tr>
                <% for (int i = 0; i < numBooks; i++) { %>
                <tr>
                    <td><%= books.get(i). getIsbn() %></td>
                    <td><%= books.get(i).getTitle() %></td>
                    <td><%= books.get(i).getAuthor() %></td>
                    <td><%= books.get(i).getEdition() %></td>
                    <td><%= books.get(i).getPublisher() %></td>
                    <td><%= books. get(i).getCopyright() %></td>
                    <td class="price">$<%= String.format("%.2f", books.get(i). getPrice()) %></td>
                    <td>
                        <a href="OrderServlet?selectedBook=<%= i %>" class="btn">Add to Cart</a>
                    </td>
                </tr>
                <% } %>
            </table>
        <% } else { %>
            <div class="no-results">
                <h3>No Books Found</h3>
                <p>Sorry, no books match your search criteria.</p>
                <a href="SearchBook. html" class="btn btn-back">Try Another Search</a>
            </div>
        <% } %>
        
        <div class="action-buttons">
            <a href="SearchBook.html" class="btn btn-back">New Search</a>
            <a href="show-order.jsp" class="btn">View Cart</a>
            <a href="StudentDashboard.jsp" class="btn btn-back">Back to Dashboard</a>
        </div>
    </div>
</body>
</html>