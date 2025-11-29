<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java. sql.*" %>
<%@ page import="java.util.*" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || ! currentUser.isAdmin()) {
        response.sendRedirect("Login.html");
        return;
    }
    
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    
    // Fetch all users
    List<User> users = new ArrayList<>();
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        Class. forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/books", "guest", "guest");
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT * FROM Users ORDER BY Role, Username");
        
        while (rs. next()) {
            users.add(new User(
                rs.getInt("UserID"),
                rs.getString("Username"),
                rs.getString("Password"),
                rs. getString("Role")
            ));
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs. close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (Exception e) {}
    }
%>
<! DOCTYPE html>
<html>
<head>
    <title>Manage Users</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        .navbar {
            background-color: #333;
            color: white;
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .navbar h1 { font-size: 24px; }
        .navbar a {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            background-color: #1976D2;
            border-radius: 4px;
            margin-left: 10px;
        }
        .container {
            max-width: 1000px;
            margin: 30px auto;
            padding: 0 20px;
        }
        . message {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .message-success { background-color: #d4edda; color: #155724; }
        .message-error { background-color: #f8d7da; color: #721c24; }
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
            background-color: #4CAF50;
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
            margin-right: 5px;
        }
        .btn-edit { background-color: #1976D2; color: white; }
        .btn-delete { background-color: #d32f2f; color: white; }
        .role-badge {
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: bold;
        }
        .role-admin { background-color: #ff9800; color: white; }
        .role-student { background-color: #2196F3; color: white; }
        .user-count { margin-bottom: 20px; color: #666; }
    </style>
    <script>
        function confirmDelete(userId, username) {
            if (confirm("Are you sure you want to delete user '" + username + "'?")) {
                window.location.href = "DeleteUserServlet?userId=" + userId;
            }
        }
    </script>
</head>
<body>
    <div class="navbar">
        <h1>👥 Manage Users</h1>
        <div>
            <a href="AddUser.jsp">Add User</a>
            <a href="AdminDashboard.jsp">Dashboard</a>
            <a href="LogoutServlet">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <% if (message != null) { %>
            <div class="message message-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <p class="user-count">Total Users: <%= users.size() %></p>
        
        <table>
            <tr>
                <th>User ID</th>
                <th>Username</th>
                <th>Role</th>
                <th>Actions</th>
            </tr>
            <% for (User u : users) { %>
            <tr>
                <td><%= u.getUserID() %></td>
                <td><%= u.getUsername() %></td>
                <td>
                    <span class="role-badge role-<%= u. getRole() %>">
                        <%= u.getRole(). toUpperCase() %>
                    </span>
                </td>
                <td>
                    <a href="EditUser.jsp?userId=<%= u.getUserID() %>" class="btn btn-edit">Edit</a>
                    <% if (u.getUserID() != currentUser.getUserID()) { %>
                        <button class="btn btn-delete" onclick="confirmDelete(<%= u.getUserID() %>, '<%= u.getUsername() %>')">Delete</button>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </table>
    </div>
</body>
</html>