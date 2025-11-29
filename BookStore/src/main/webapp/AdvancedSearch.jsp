<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bookstore.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response. sendRedirect("Login.html");
        return;
    }
    
    // Get filter parameters
    String searchTitle = request.getParameter("title");
    String searchAuthor = request.getParameter("author");
    String searchPublisher = request.getParameter("publisher");
    String minPrice = request.getParameter("minPrice");
    String maxPrice = request.getParameter("maxPrice");
    String sortBy = request.getParameter("sortBy");
    String sortOrder = request.getParameter("sortOrder");
    
    // Set defaults
    if (searchTitle == null) searchTitle = "";
    if (searchAuthor == null) searchAuthor = "";
    if (searchPublisher == null) searchPublisher = "";
    if (minPrice == null) minPrice = "";
    if (maxPrice == null) maxPrice = "";
    if (sortBy == null || sortBy.isEmpty()) sortBy = "Title";
    if (sortOrder == null || sortOrder.isEmpty()) sortOrder = "ASC";
    
    // Fetch filtered books
    List<Book> books = new ArrayList<>();
    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    String errorMsg = null;
    
    boolean hasSearched = request.getParameter("search") != null;
    
    if (hasSearched) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/books", "guest", "guest");
            
            // Build dynamic query
            StringBuilder query = new StringBuilder("SELECT * FROM BookInfo WHERE 1=1");
            List<Object> params = new ArrayList<>();
            
            if (! searchTitle.trim().isEmpty()) {
                query.append(" AND Title LIKE ?");
                params.add("%" + searchTitle. trim() + "%");
            }
            if (!searchAuthor.trim().isEmpty()) {
                query. append(" AND Author LIKE ?");
                params.add("%" + searchAuthor. trim() + "%");
            }
            if (!searchPublisher.trim().isEmpty()) {
                query. append(" AND Publisher LIKE ?");
                params.add("%" + searchPublisher. trim() + "%");
            }
            if (!minPrice. trim().isEmpty()) {
                query.append(" AND Price >= ? ");
                params. add(Double.parseDouble(minPrice. trim()));
            }
            if (!maxPrice.trim().isEmpty()) {
                query.append(" AND Price <= ?");
                params.add(Double.parseDouble(maxPrice.trim()));
            }
            
            // Add sorting - validate sortBy to prevent SQL injection
            String validSortBy = "Title";
            if (sortBy.equals("Title") || sortBy. equals("Author") || 
                sortBy. equals("Price") || sortBy. equals("Publisher") || 
                sortBy.equals("Copyright")) {
                validSortBy = sortBy;
            }
            String validSortOrder = sortOrder.equals("DESC") ? "DESC" : "ASC";
            query.append(" ORDER BY ").append(validSortBy).append(" ").append(validSortOrder);
            
            stmt = conn.prepareStatement(query.toString());
            
            // Set parameters
            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof String) {
                    stmt.setString(i + 1, (String) param);
                } else if (param instanceof Double) {
                    stmt.setDouble(i + 1, (Double) param);
                }
            }
            
            rs = stmt.executeQuery();
            
            while (rs.next()) {
                books.add(new Book(
                    rs.getString("ISBN"),
                    rs.getString("Author"),
                    rs.getString("Title"),
                    rs. getDouble("Price"),
                    rs.getInt("EditionNumber"),
                    rs. getString("Publisher"),
                    rs.getString("Copyright")
                ));
            }
            
            // Store in session for OrderServlet
            session. setAttribute("foundBooks", books);
            
        } catch (Exception e) {
            errorMsg = e.getMessage();
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt. close();
                if (conn != null) conn.close();
            } catch (Exception e) {}
        }
    }
%>
<! DOCTYPE html>
<html>
<head>
    <title>Advanced Search</title>
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
        .navbar h1 { font-size: 24px; margin: 0; }
        .navbar-links a {
            color: white;
            text-decoration: none;
            padding: 8px 16px;
            border-radius: 4px;
            margin-left: 10px;
        }
        .navbar-links a:hover { background-color: rgba(255,255,255,0.1); }
        . navbar-links a.logout { background-color: #d32f2f; }
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .search-form {
            background-color: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }
        .search-form h2 {
            margin: 0 0 20px 0;
            color: #333;
            border-bottom: 2px solid #1976D2;
            padding-bottom: 10px;
        }
        . form-row {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 15px;
        }
        .form-group {
            display: flex;
            flex-direction: column;
        }
        .form-group label {
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
            font-size: 14px;
        }
        .form-group input, . form-group select {
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
        }
        .form-group input:focus, .form-group select:focus {
            border-color: #1976D2;
            outline: none;
        }
        .price-range {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .price-range input {
            width: 100px;
        }
        .btn-row {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            text-decoration: none;
            display: inline-block;
        }
        .btn-primary { background-color: #1976D2; color: white; }
        .btn-primary:hover { background-color: #1565C0; }
        .btn-secondary { background-color: #757575; color: white; }
        . btn-secondary:hover { background-color: #616161; }
        .btn-success { background-color: #4CAF50; color: white; }
        .btn-success:hover { background-color: #45a049; }
        .results-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .results-header h3 { margin: 0; color: #333; }
        .results-count { color: #666; }
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
        th a {
            color: white;
            text-decoration: none;
        }
        th a:hover { text-decoration: underline; }
        tr:hover { background-color: #f5f5f5; }
        .price { color: #d32f2f; font-weight: bold; }
        . btn-cart { 
            padding: 6px 12px;
            background-color: #4CAF50;
            color: white;
            border-radius: 4px;
            text-decoration: none;
            font-size: 13px;
        }
        .btn-cart:hover { background-color: #45a049; }
        .no-results {
            text-align: center;
            padding: 40px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .no-results p { color: #666; }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            padding: 15px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .sort-icon { font-size: 12px; margin-left: 5px; }
    </style>
</head>
<body>
    <div class="navbar">
        <h1>Advanced Search</h1>
        <div class="navbar-links">
            <a href="StudentDashboard.jsp">Dashboard</a>
            <a href="SearchBook.html">Simple Search</a>
            <a href="BrowseBooks. jsp">Browse All</a>
            <a href="show-order.jsp">Cart</a>
            <a href="PurchaseHistory.jsp">My Purchases</a>
            <a href="LogoutServlet" class="logout">Logout</a>
        </div>
    </div>
    
    <div class="container">
        <!-- Search Form -->
        <div class="search-form">
            <h2>Search & Filter Books</h2>
            
            <form method="get" action="AdvancedSearch.jsp">
                <input type="hidden" name="search" value="1">
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="title">Book Title</label>
                        <input type="text" id="title" name="title" value="<%= searchTitle %>" placeholder="Enter title keywords">
                    </div>
                    <div class="form-group">
                        <label for="author">Author</label>
                        <input type="text" id="author" name="author" value="<%= searchAuthor %>" placeholder="Enter author name">
                    </div>
                    <div class="form-group">
                        <label for="publisher">Publisher</label>
                        <input type="text" id="publisher" name="publisher" value="<%= searchPublisher %>" placeholder="Enter publisher">
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Price Range ($)</label>
                        <div class="price-range">
                            <input type="number" name="minPrice" value="<%= minPrice %>" placeholder="Min" min="0" step="0.01">
                            <span>to</span>
                            <input type="number" name="maxPrice" value="<%= maxPrice %>" placeholder="Max" min="0" step="0.01">
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="sortBy">Sort By</label>
                        <select id="sortBy" name="sortBy">
                            <option value="Title" <%= sortBy. equals("Title") ?  "selected" : "" %>>Title</option>
                            <option value="Author" <%= sortBy.equals("Author") ? "selected" : "" %>>Author</option>
                            <option value="Price" <%= sortBy.equals("Price") ? "selected" : "" %>>Price</option>
                            <option value="Publisher" <%= sortBy.equals("Publisher") ? "selected" : "" %>>Publisher</option>
                            <option value="Copyright" <%= sortBy.equals("Copyright") ? "selected" : "" %>>Year</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="sortOrder">Order</label>
                        <select id="sortOrder" name="sortOrder">
                            <option value="ASC" <%= sortOrder.equals("ASC") ? "selected" : "" %>>Ascending (A-Z, Low-High)</option>
                            <option value="DESC" <%= sortOrder.equals("DESC") ? "selected" : "" %>>Descending (Z-A, High-Low)</option>
                        </select>
                    </div>
                </div>
                
                <div class="btn-row">
                    <button type="submit" class="btn btn-primary">Search</button>
                    <a href="AdvancedSearch. jsp" class="btn btn-secondary">Clear Filters</a>
                    <a href="BrowseBooks.jsp" class="btn btn-success">Browse All Books</a>
                </div>
            </form>
        </div>
        
        <% if (errorMsg != null) { %>
            <div class="error">Error: <%= errorMsg %></div>
        <% } %>
        
        <!-- Search Results -->
        <% if (hasSearched) { %>
            <div class="results-header">
                <h3>Search Results</h3>
                <span class="results-count"><%= books.size() %> book(s) found</span>
            </div>
            
            <% if (! books.isEmpty()) { %>
                <table>
                    <tr>
                        <th>
                            <a href="AdvancedSearch. jsp?search=1&title=<%= searchTitle %>&author=<%= searchAuthor %>&publisher=<%= searchPublisher %>&minPrice=<%= minPrice %>&maxPrice=<%= maxPrice %>&sortBy=Title&sortOrder=<%= sortBy. equals("Title") && sortOrder.equals("ASC") ? "DESC" : "ASC" %>">
                                Title <span class="sort-icon"><%= sortBy.equals("Title") ? (sortOrder.equals("ASC") ? "▲" : "▼") : "" %></span>
                            </a>
                        </th>
                        <th>
                            <a href="AdvancedSearch. jsp?search=1&title=<%= searchTitle %>&author=<%= searchAuthor %>&publisher=<%= searchPublisher %>&minPrice=<%= minPrice %>&maxPrice=<%= maxPrice %>&sortBy=Author&sortOrder=<%= sortBy.equals("Author") && sortOrder.equals("ASC") ?  "DESC" : "ASC" %>">
                                Author <span class="sort-icon"><%= sortBy.equals("Author") ? (sortOrder. equals("ASC") ? "▲" : "▼") : "" %></span>
                            </a>
                        </th>
                        <th>Edition</th>
                        <th>
                            <a href="AdvancedSearch.jsp?search=1&title=<%= searchTitle %>&author=<%= searchAuthor %>&publisher=<%= searchPublisher %>&minPrice=<%= minPrice %>&maxPrice=<%= maxPrice %>&sortBy=Publisher&sortOrder=<%= sortBy.equals("Publisher") && sortOrder.equals("ASC") ? "DESC" : "ASC" %>">
                                Publisher <span class="sort-icon"><%= sortBy.equals("Publisher") ? (sortOrder.equals("ASC") ? "▲" : "▼") : "" %></span>
                            </a>
                        </th>
                        <th>
                            <a href="AdvancedSearch.jsp?search=1&title=<%= searchTitle %>&author=<%= searchAuthor %>&publisher=<%= searchPublisher %>&minPrice=<%= minPrice %>&maxPrice=<%= maxPrice %>&sortBy=Copyright&sortOrder=<%= sortBy. equals("Copyright") && sortOrder.equals("ASC") ? "DESC" : "ASC" %>">
                                Year <span class="sort-icon"><%= sortBy.equals("Copyright") ? (sortOrder.equals("ASC") ? "▲" : "▼") : "" %></span>
                            </a>
                        </th>
                        <th>
                            <a href="AdvancedSearch.jsp?search=1&title=<%= searchTitle %>&author=<%= searchAuthor %>&publisher=<%= searchPublisher %>&minPrice=<%= minPrice %>&maxPrice=<%= maxPrice %>&sortBy=Price&sortOrder=<%= sortBy. equals("Price") && sortOrder.equals("ASC") ? "DESC" : "ASC" %>">
                                Price <span class="sort-icon"><%= sortBy. equals("Price") ?  (sortOrder.equals("ASC") ?  "▲" : "▼") : "" %></span>
                            </a>
                        </th>
                        <th>Action</th>
                    </tr>
                    <% for (int i = 0; i < books.size(); i++) { 
                        Book book = books.get(i);
                    %>
                    <tr>
                        <td><%= book.getTitle() %></td>
                        <td><%= book.getAuthor() %></td>
                        <td><%= book.getEdition() %></td>
                        <td><%= book.getPublisher() %></td>
                        <td><%= book. getCopyright() %></td>
                        <td class="price">$<%= String.format("%.2f", book.getPrice()) %></td>
                        <td>
                            <a href="OrderServlet?selectedBook=<%= i %>" class="btn-cart">Add to Cart</a>
                        </td>
                    </tr>
                    <% } %>
                </table>
            <% } else { %>
                <div class="no-results">
                    <h3>No Books Found</h3>
                    <p>Try adjusting your search filters. </p>
                </div>
            <% } %>
        <% } %>
    </div>
</body>
</html>