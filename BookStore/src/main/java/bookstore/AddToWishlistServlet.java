package bookstore;

import jakarta.servlet.ServletException;
import jakarta. servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http. HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http. HttpSession;

import java.io.IOException;
import java. sql.Connection;
import java.sql. DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/AddToWishlistServlet")
public class AddToWishlistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATABASE_URL = "jdbc:mysql://localhost:3306/books";
    private static final String DB_USER = "guest";
    private static final String DB_PASSWORD = "guest";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("currentUser");
        
        if (user == null) {
            response.sendRedirect("Login.html");
            return;
        }
        
        String isbn = request.getParameter("isbn");
        String redirectPage = request.getParameter("redirect");
        if (redirectPage == null || redirectPage.isEmpty()) {
            redirectPage = "BrowseBooks.jsp";
        }
        
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet rs = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            // Check if already in wishlist
            String checkQuery = "SELECT COUNT(*) FROM Wishlist WHERE UserID = ? AND ISBN = ?";
            statement = connection.prepareStatement(checkQuery);
            statement. setInt(1, user.getUserID());
            statement.setString(2, isbn);
            rs = statement.executeQuery();
            rs.next();
            
            if (rs.getInt(1) > 0) {
                session.setAttribute("wishlistMessage", "Book is already in your wishlist!");
                session.setAttribute("wishlistMessageType", "info");
            } else {
                rs.close();
                statement.close();
                
                // Get book title from BookInfo
                String getBookQuery = "SELECT Title FROM BookInfo WHERE ISBN = ?";
                statement = connection.prepareStatement(getBookQuery);
                statement. setString(1, isbn);
                rs = statement.executeQuery();
                
                String title = "";
                if (rs.next()) {
                    title = rs.getString("Title");
                }
                
                rs.close();
                statement.close();
                
                // Add to wishlist with title
                String insertQuery = "INSERT INTO Wishlist (UserID, ISBN, Title) VALUES (?, ?, ?)";
                statement = connection. prepareStatement(insertQuery);
                statement.setInt(1, user.getUserID());
                statement. setString(2, isbn);
                statement.setString(3, title);
                
                int result = statement.executeUpdate();
                
                if (result > 0) {
                    session.setAttribute("wishlistMessage", "'" + title + "' added to wishlist!");
                    session.setAttribute("wishlistMessageType", "success");
                } else {
                    session.setAttribute("wishlistMessage", "Failed to add book to wishlist.");
                    session. setAttribute("wishlistMessageType", "error");
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("wishlistMessage", "Error: " + e.getMessage());
            session. setAttribute("wishlistMessageType", "error");
        } finally {
            try {
                if (rs != null) rs. close();
                if (statement != null) statement.close();
                if (connection != null) connection.close();
            } catch (Exception e) {}
        }
        
        response.sendRedirect(redirectPage);
    }
}