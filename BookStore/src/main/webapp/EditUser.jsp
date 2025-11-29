<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java. sql.*" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null || !currentUser. isAdmin()) {
        response.sendRedirect("../Login. html");
        return;
    }
    
    int userId = Integer.parseInt(request. getParameter("userId"));
    User editUser = null;
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    
    // Fetch user details
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class. forName("com. mysql.cj. jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/books", "guest", "guest");
        stmt = conn.prepareStatement("SELECT * FROM Users WHERE UserID = ?");
        stmt.setInt(1, userId);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            editUser = new User(
                rs.getInt("UserID"),
                rs.getString("Username"),
                rs. getString("Password"),
                rs.getString("Role")
            );
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
    
    if (editUser == null) {
        response.sendRedirect("ManageUsers.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit User</title>
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
        . container {
            max-width: 500px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .form-container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .form-group input, . form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .form-group input[readonly] {
            background-color: #e9e9e9;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            margin-right: 10px;
            text-decoration: none;
        }
        .btn-primary { background-color: #4CAF50; color: white; }
        .btn-secondary { background-color: #757575; color: white; display: inline-block; }
        .message {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        . message-success { background-color: #d4edda; color: #155724; }
        .message-error { background-color: #f8d7da; color: #721c24; }
        . note {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>✏️ Edit User</h1>
        <div>
            <a href="ManageUsers. jsp">Back to Users</a>
            <a href="AdminDashboard.jsp">Dashboard</a>
        </div>
    </div>
    
    <div class="container">
        <div class="form-container">
            <h2>Edit User: <%= editUser.getUsername() %></h2>
            
            <% if (message != null) { %>
                <div class="message message-<%= messageType %>">
                    <%= message %>
                </div>
            <% } %>
            
            <form method="post" action="../UpdateUserServlet">
                <input type="hidden" name="userId" value="<%= editUser.getUserID() %>">
                
                <div class="form-group">
                    <label>User ID</label>
                    <input type="text" value="<%= editUser.getUserID() %>" readonly>
                </div>
                
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" value="<%= editUser.getUsername() %>" required>
                </div>
                
                <div class="form-group">
                    <label for="password">New Password</label>
                    <input type="password" id="password" name="password" placeholder="Leave blank to keep current password">
                    <p class="note">Leave blank if you don't want to change the password</p>
                </div>
                
                <div class="form-group">
                    <label for="role">Role</label>
                    <select id="role" name="role" required>
                        <option value="student" <%= editUser.getRole(). equals("student") ? "selected" : "" %>>Student</option>
                        <option value="admin" <%= editUser.getRole().equals("admin") ? "selected" : "" %>>Admin</option>
                    </select>
                </div>
                
                <button type="submit" class="btn btn-primary">Update User</button>
                <a href="ManageUsers.jsp" class="btn btn-secondary">Cancel</a>
            </form>
        </div>
    </div>
</body>
</html>