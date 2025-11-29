<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java.sql.*" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || !user. isAdmin()) {
        response.sendRedirect("../Login. html");
        return;
    }
    
    String isbn = request.getParameter("isbn");
    Book book = null;
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    
    // Fetch book details
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/books", "guest", "guest");
        stmt = conn.prepareStatement("SELECT * FROM BookInfo WHERE ISBN = ? ");
        stmt. setString(1, isbn);
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            book = new Book(
                rs.getString("ISBN"),
                rs.getString("Author"),
                rs.getString("Title"),
                rs.getDouble("Price"),
                rs.getInt("EditionNumber"),
                rs.getString("Publisher"),
                rs. getString("Copyright")
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
    
    if (book == null) {
        response.sendRedirect("ManageBooks.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Book</title>
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
            max-width: 600px;
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
        .form-group input {
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
        }
        .btn-primary { background-color: #4CAF50; color: white; }
        .btn-secondary { background-color: #757575; color: white; }
        . message {
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .message-success { background-color: #d4edda; color: #155724; }
        . message-error { background-color: #f8d7da; color: #721c24; }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>Edit Book</h1>
        <div>
            <a href="ManageBooks. jsp">Back to Books</a>
            <a href="AdminDashboard.jsp">Dashboard</a>
        </div>
    </div>
    
    <div class="container">
        <div class="form-container">
            <h2>Edit Book Details</h2>
            
            <% if (message != null) { %>
                <div class="message message-<%= messageType %>">
                    <%= message %>
                </div>
            <% } %>
            
            <form method="post" action="UpdateBookServlet">
                <div class="form-group">
                    <label>ISBN (cannot be changed)</label>
                    <input type="text" name="isbn" value="<%= book.getIsbn() %>" readonly>
                </div>
                
                <div class="form-group">
                    <label>Title</label>
                    <input type="text" name="title" value="<%= book.getTitle() %>" required>
                </div>
                
                <div class="form-group">
                    <label>Author</label>
                    <input type="text" name="author" value="<%= book.getAuthor() %>" required>
                </div>
                
                <div class="form-group">
                    <label>Edition Number</label>
                    <input type="number" name="edition" value="<%= book.getEdition() %>" min="1">
                </div>
                
                <div class="form-group">
                    <label>Publisher</label>
                    <input type="text" name="publisher" value="<%= book.getPublisher() %>">
                </div>
                
                <div class="form-group">
                    <label>Copyright Year</label>
                    <input type="text" name="copyright" value="<%= book.getCopyright() %>" maxlength="4">
                </div>
                
                <div class="form-group">
                    <label>Price ($)</label>
                    <input type="number" name="price" value="<%= book.getPrice() %>" step="0.01" min="0" required>
                </div>
                
                <button type="submit" class="btn btn-primary">Update Book</button>
                <a href="ManageBooks.jsp" class="btn btn-secondary" style="text-decoration:none; display:inline-block;">Cancel</a>
            </form>
        </div>
    </div>
</body>
</html>