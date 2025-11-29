package bookstore;

import jakarta.servlet.ServletException;
import jakarta. servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta. servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql. DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/RemoveFromWishlistServlet")
public class RemoveFromWishlistServlet extends HttpServlet {
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
        
        Connection connection = null;
        PreparedStatement statement = null;
        
        try {
            Class. forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            String deleteQuery = "DELETE FROM Wishlist WHERE UserID = ? AND ISBN = ?";
            statement = connection. prepareStatement(deleteQuery);
            statement.setInt(1, user.getUserID());
            statement. setString(2, isbn);
            
            int result = statement.executeUpdate();
            
            if (result > 0) {
                session. setAttribute("wishlistMessage", "Book removed from wishlist!");
                session.setAttribute("wishlistMessageType", "success");
            } else {
                session.setAttribute("wishlistMessage", "Failed to remove book from wishlist.");
                session. setAttribute("wishlistMessageType", "error");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("wishlistMessage", "Error: " + e.getMessage());
            session.setAttribute("wishlistMessageType", "error");
        } finally {
            try {
                if (statement != null) statement.close();
                if (connection != null) connection.close();
            } catch (Exception e) {}
        }
        
        response.sendRedirect("Wishlist.jsp");
    }
}