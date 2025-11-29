package bookstore;

import jakarta. servlet.RequestDispatcher;
import jakarta. servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http. HttpServlet;
import jakarta.servlet. http.HttpServletRequest;
import jakarta.servlet.http. HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java. io.IOException;
import java.sql. Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/UpdateUserServlet")
public class UpdateUserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String DATABASE_URL = "jdbc:mysql://localhost:3306/books";
    private static final String DB_USER = "guest";
    private static final String DB_PASSWORD = "guest";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (User) session.getAttribute("currentUser");
        if (user == null || ! user.isAdmin()) {
            response. sendRedirect("Login.html");
            return;
        }
        
        int userId = Integer.parseInt(request.getParameter("userId"));
        String username = request. getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        
        Connection connection = null;
        PreparedStatement statement = null;
        
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(DATABASE_URL, DB_USER, DB_PASSWORD);
            
            String query;
            if (password != null && ! password.trim().isEmpty()) {
                // Update with new password
                query = "UPDATE Users SET Username=?, Password=?, Role=? WHERE UserID=?";
                statement = connection.prepareStatement(query);
                statement.setString(1, username);
                statement. setString(2, password);
                statement.setString(3, role);
                statement.setInt(4, userId);
            } else {
                // Update without changing password
                query = "UPDATE Users SET Username=?, Role=?  WHERE UserID=? ";
                statement = connection.prepareStatement(query);
                statement.setString(1, username);
                statement.setString(2, role);
                statement.setInt(3, userId);
            }
            
            int result = statement.executeUpdate();
            
            if (result > 0) {
                request.setAttribute("message", "User updated successfully!");
                request.setAttribute("messageType", "success");
            } else {
                request.setAttribute("message", "Failed to update user.");
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
        
        RequestDispatcher dispatcher = getServletContext().getRequestDispatcher("/ManageUsers.jsp");
        dispatcher.forward(request, response);
    }
}
