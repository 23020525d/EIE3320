<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !user.isAdmin()) {
        response.sendRedirect("/Login.html");
        return;
    }
    
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
%>
<! DOCTYPE html>
<html>
<head>
    <title>Add New Book</title>
    
    <script>
        function validateForm() {
            var isbn = document.forms["addBookForm"]["isbn"].value.trim();
            var title = document. forms["addBookForm"]["title"].value. trim();
            var author = document.forms["addBookForm"]["author"].value.trim();
            var price = document.forms["addBookForm"]["price"].value;
            
            if (isbn === "" || title === "" || author === "") {
                alert("Please fill in ISBN, Title, and Author");
                return false;
            }
            if (isNaN(price) || price <= 0) {
                alert("Please enter a valid price");
                return false;
            }
            return true;
        }
    </script>
</head>
<body>
    <div class="navbar">
        <h1>Add New Book</h1>
        <div>
            <a href="AdminDashboard.jsp">Dashboard</a>
            <a href="LogoutServlet">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <div class="form-container">
            <h2>Enter Book Details</h2>
            
            <% if (message != null) { %>
                <div class="message message-<%= messageType %>">
                    <%= message %>
                </div>
            <% } %>
            
            <form name="addBookForm" method="post" action="AddBookServlet" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="isbn">ISBN *</label>
                    <input type="text" id="isbn" name="isbn" placeholder="e.g., 0123456789" required>
                </div>
                
                <div class="form-group">
                    <label for="title">Title *</label>
                    <input type="text" id="title" name="title" placeholder="Book title" required>
                </div>
                
                <div class="form-group">
                    <label for="author">Author *</label>
                    <input type="text" id="author" name="author" placeholder="Author name" required>
                </div>
                
                <div class="form-group">
                    <label for="edition">Edition Number</label>
                    <input type="number" id="edition" name="edition" value="1" min="1">
                </div>
                
                <div class="form-group">
                    <label for="publisher">Publisher</label>
                    <input type="text" id="publisher" name="publisher" placeholder="Publisher name">
                </div>
                
                <div class="form-group">
                    <label for="copyright">Copyright Year</label>
                    <input type="text" id="copyright" name="copyright" placeholder="e.g., 2024" maxlength="4">
                </div>
                
                <div class="form-group">
                    <label for="price">Price ($) *</label>
                    <input type="number" id="price" name="price" step="0.01" min="0" placeholder="e.g., 29.99" required>
                </div>
                
                <button type="submit" class="btn btn-primary">Add Book</button>
                <button type="reset" class="btn btn-secondary">Clear</button>
            </form>
        </div>
    </div>
</body>
</html>