<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || ! user.isAdmin()) {
        response. sendRedirect("Login.html");
        return;
    }
    
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Add New User</title>
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
        .form-container h2 {
            margin-bottom: 20px;
            color: #333;
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
        .form-group input, .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            margin-right: 10px;
        }
        .btn-primary { background-color: #4CAF50; color: white; }
        .btn-secondary { background-color: #757575; color: white; }
        . message {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        . message-success { background-color: #d4edda; color: #155724; }
        .message-error { background-color: #f8d7da; color: #721c24; }
    </style>
    <script>
        function validateForm() {
            var username = document.forms["addUserForm"]["username"].value. trim();
            var password = document.forms["addUserForm"]["password"].value.trim();
            var confirmPassword = document.forms["addUserForm"]["confirmPassword"].value. trim();
            
            if (username === "" || password === "") {
                alert("Please fill in username and password");
                return false;
            }
            if (username.length < 3) {
                alert("Username must be at least 3 characters");
                return false;
            }
            if (password.length < 4) {
                alert("Password must be at least 4 characters");
                return false;
            }
            if (password !== confirmPassword) {
                alert("Passwords do not match");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <div class="navbar">
        <h1>Add New User</h1>
        <div>
            <a href="ManageUsers.jsp">Back to Users</a>
            <a href="AdminDashboard.jsp">Dashboard</a>
        </div>
    </div>
    
    <div class="container">
        <div class="form-container">
            <h2>Enter User Details</h2>
            
            <% if (message != null) { %>
                <div class="message message-<%= messageType %>">
                    <%= message %>
                </div>
            <% } %>
            
            <form name="addUserForm" method="post" action="AddUserServlet" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="username">Username *</label>
                    <input type="text" id="username" name="username" placeholder="Enter username" required>
                </div>
                
                <div class="form-group">
                    <label for="password">Password *</label>
                    <input type="password" id="password" name="password" placeholder="Enter password" required>
                </div>
                
                <div class="form-group">
                    <label for="confirmPassword">Confirm Password *</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" placeholder="Confirm password" required>
                </div>
                
                <div class="form-group">
                    <label for="role">Role *</label>
                    <select id="role" name="role" required>
                        <option value="student">Student</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
                
                <button type="submit" class="btn btn-primary">Add User</button>
                <button type="reset" class="btn btn-secondary">Clear</button>
            </form>
        </div>
    </div>
</body>
</html>