<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%
    // Check if user is logged in and is admin
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !user.isAdmin()) {
        response.sendRedirect("Login.html");
        return;
    }
%>
<! DOCTYPE html>
<html>
<head>
    <title>Admin Dashboard</title>
    
</head>
<body>
    <div class="navbar">
        <h1>Admin Dashboard</h1>
        <a href="LogoutServlet">Logout</a>
    </div>
    
    <div class="container">
        <div class="welcome-msg">
            <h2>Welcome, <%= user.getUsername() %>!</h2>
            <p>You are logged in as Administrator</p>
        </div>
        
        <div class="dashboard-grid">
            <!-- Book Management Card -->
            <div class="dashboard-card">
                <h3>Book Management</h3>
                <ul>
                    <li><a href="AddBook.jsp">Add New Book</a></li>
                    <li><a href="ManageBooks.jsp">View / Edit / Delete Books</a></li>
                </ul>
            </div>
            
            <!-- User Management Card -->
            <div class="dashboard-card">
                <h3>User Management</h3>
                <ul>
                    <li><a href="ManageUsers.jsp">Manage Users</a></li>
                    <li><a href="AddUser.jsp">Add New User</a></li>
                </ul>
            </div>
            
            <!-- Reports Card -->
            <div class="dashboard-card">
                <h3>Reports</h3>
                <ul>
                    <li><a href="SalesReport.jsp">Sales Report</a></li>
                    <li><a href="InventoryReport.jsp">Inventory Report</a></li>
                </ul>
            </div>
            
            <!-- Quick Links Card -->
            <div class="dashboard-card">
                <h3>Quick Links</h3>
                <ul>
                    <li><a href="SearchBook.html">Browse Books (User View)</a></li>
                </ul>
            </div>
        </div>
    </div>
</body>
</html>