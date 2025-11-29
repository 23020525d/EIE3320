<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null || ! user.isAdmin()) {
        response.sendRedirect("Login.html");
        return;
    }
    
    String message = (String) request.getAttribute("message");
    String messageType = (String) request.getAttribute("messageType");
    
    // Fetch all books
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
                rs. getString("Title"),
                rs.getDouble("Price"),
                rs.getInt("EditionNumber"),
                rs.getString("Publisher"),
                rs.getString("Copyright")
            ));
        }
    } catch (Exception e) {
        e.printStackTrace();
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
    <title>Manage Books</title>
    
    <script>
        function confirmDelete(formId, title) {
            if (confirm("Are you sure you want to delete '" + title + "'?")) {
                document.getElementById(formId).submit();
            }
            return false;
        }
    </script>
</head>
<body>
    <div class="navbar">
        <h1>Manage Books</h1>
        <div>
            <a href="AddBook. jsp">Add Book</a>
            <a href="AdminDashboard.jsp">Dashboard</a>
            <a href="../LogoutServlet">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <% if (message != null) { %>
            <div class="message message-<%= messageType %>">
                <%= message %>
            </div>
        <% } %>
        
        <p class="book-count">Total Books: <%= books.size() %></p>
        
        <table>
            <tr>
                <th>ISBN</th>
                <th>Title</th>
                <th>Author</th>
                <th>Edition</th>
                <th>Publisher</th>
                <th>Copyright</th>
                <th>Price</th>
                <th>Actions</th>
            </tr>
            <% int index = 0; %>
            <% for (Book book : books) { %>
            <tr>
                <td><%= book.getIsbn() %></td>
                <td><%= book.getTitle() %></td>
                <td><%= book.getAuthor() %></td>
                <td><%= book. getEdition() %></td>
                <td><%= book.getPublisher() %></td>
                <td><%= book.getCopyright() %></td>
                <td>$<%= String.format("%.2f", book.getPrice()) %></td>
                <td>
                    <a href="EditBook.jsp?isbn=<%= book. getIsbn() %>" class="btn btn-edit">Edit</a>
                    
                    <!-- Use form for delete like AddBook.jsp -->
                    <form id="deleteForm<%= index %>" class="action-form" method="post" action="DeleteBookServlet">
                        <input type="hidden" name="isbn" value="<%= book.getIsbn() %>">
                        <button type="button" class="btn btn-delete" 
                                onclick="confirmDelete('deleteForm<%= index %>', '<%= book. getTitle() %>')">
                            Delete
                        </button>
                    </form>
                </td>
            </tr>
            <% index++; %>
            <% } %>
        </table>
    </div>
</body>
</html>