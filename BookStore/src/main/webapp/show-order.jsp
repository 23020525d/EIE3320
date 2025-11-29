<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>
<%
    ShoppingCart cart = (ShoppingCart) session.getAttribute("bookstore.cart");
    int numBooks = cart != null ? cart.size() : 0;
    User user = (User) session. getAttribute("currentUser");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Shopping Cart</title>
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
            max-width: 800px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .datetime {
            text-align: center;
            color: #666;
            margin-bottom: 20px;
            font-size: 14px;
        }
        .cart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .cart-title { color: #333; margin: 0; }
        .item-count { color: #666; font-size: 14px; }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            border-radius: 8px;
            overflow: hidden;
            margin-bottom: 20px;
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
        .total-row {
            background-color: #f9f9f9;
            font-weight: bold;
        }
        .total-row td { border-bottom: none; }
        . price { color: #d32f2f; font-weight: bold; }
        . btn {
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            display: inline-block;
            margin-right: 10px;
        }
        .btn-checkout { background-color: #4CAF50; color: white; }
        .btn-checkout:hover { background-color: #45a049; }
        .btn-continue { background-color: #1976D2; color: white; }
        .btn-continue:hover { background-color: #1565C0; }
        .btn-remove { background-color: #d32f2f; color: white; }
        .btn-remove:hover { background-color: #b71c1c; }
        .action-buttons { text-align: center; margin-top: 20px; }
        .empty-cart {
            text-align: center;
            padding: 50px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .empty-cart h3 { color: #666; }
        .empty-cart p { color: #999; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>Shopping Cart</h1>
        <div class="navbar-links">
            <a href="StudentDashboard.jsp">Dashboard</a>
            <a href="SearchBook.html">Search</a>
            <a href="BrowseBooks.jsp">Browse</a>
            <a href="PurchaseHistory.jsp">My Purchases</a>
            <a href="LogoutServlet" class="logout">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="datetime">Current Time: <%= new Date() %></div>
        
        <div class="cart-header">
            <h2 class="cart-title">Your Shopping Cart</h2>
            <span class="item-count"><%= numBooks %> item(s)</span>
        </div>
        
        <% if (numBooks > 0) { %>
            <table>
                <tr>
                    <th>#</th>
                    <th>Title</th>
                    <th>Price</th>
                </tr>
                <% for (int i = 0; i < numBooks; i++) { %>
                <tr>
                    <td><%= i + 1 %></td>
                    <td><%= cart.get(i). getTitle() %></td>
                    <td class="price">$<%= String.format("%.2f", cart.get(i).getPrice()) %></td>
                </tr>
                <% } %>
                <tr class="total-row">
                    <td colspan="2" style="text-align: right;">Total:</td>
                    <td class="price">$<%= String.format("%.2f", cart.getTotalPrice()) %></td>
                </tr>
            </table>
            
            <div class="action-buttons">
                <a href="AdvancedSearch.jsp" class="btn btn-continue">Continue Shopping</a>
                <a href="check-out.jsp" class="btn btn-checkout">Proceed to Checkout</a>
                <a href="remove-all.jsp" class="btn btn-remove">Remove All</a>
            </div>
        <% } else { %>
            <div class="empty-cart">
                <h3>Your Cart is Empty</h3>
                <p>Looks like you haven't added any books yet. </p>
                <a href="AdvancedSearch.jsp" class="btn btn-continue">Start Shopping</a>
            </div>
        <% } %>
    </div>
</body>
</html>