package bookstore;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http. HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io. IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/DeleteUserServlet")
public class DeleteUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATABASE_URL = "jdbc:mysql://localhost:3306/books";
    private static final String DB_USER = "guest";
    private static final String DB_PASSWORD = "guest";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null || !currentUser. isAdmin()) {
            response.sendRedirect("Login.html");
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        
        // Prevent admin from deleting themselves
        if (userId == currentUser.getUserID()) {
            request.setAttribute("message", "You cannot delete your own account!");
            request.setAttribute("messageType", "error");
            request.getRequestDispatcher("/admin/ManageUsers. jsp").forward(request, response);
            return;
        }
        
        Connection connection = null;
        PreparedStatement statement = null;
        
        try {
            Class.forName("com.mysql. cj.jdbc. Driver");
            connection = DriverManager. getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            // Delete user's purchase history first (if table exists)
            try {
                String deletePurchases = "DELETE FROM PurchaseHistory WHERE UserID = ?";
                statement = connection. prepareStatement(deletePurchases);
                statement.setInt(1, userId);
                statement.executeUpdate();
                statement.close();
            } catch (Exception e) {
                // PurchaseHistory table might not exist yet
            }
            
            // Delete user
            String deleteUser = "DELETE FROM Users WHERE UserID = ?";
            statement = connection.prepareStatement(deleteUser);
            statement.setInt(1, userId);
            int result = statement.executeUpdate();
            
            if (result > 0) {
                request.setAttribute("message", "User deleted successfully!");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "Failed to delete user.");
                request.setAttribute("messageType", "error");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("message", "Error: " + e. getMessage());
            request.setAttribute("messageType", "error");
        } finally {
            try {
                if (statement != null) statement.close();
                if (connection != null) connection. close();
            } catch (Exception e) {}
        }
        
        request. getRequestDispatcher("/admin/ManageUsers. jsp").forward(request, response);
    }
}
